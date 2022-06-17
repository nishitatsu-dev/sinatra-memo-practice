# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require 'pg'

set :environment, :production

class MemoData
  attr_accessor :memos, :id

  def initialize
    @memos = {}
    read_memo
  end

  def add_memo(title, content)
    id = @memos.keys.map(&:to_i).max.to_i + 1
    @memos[id] = { title: title, content: content }
    begin
      connect_db
      @connection.exec(format('INSERT INTO inventory (id, title, content) VALUES(%<id>d, %<title>s, %<content>s);',
                              id: id, title: "\'#{title}\'", content: "\'#{content}\'"))
      puts 'Inserted 1 row of data.'
    rescue PG::Error => e
      puts e.message
    ensure
      @connection&.close
    end
  end

  def delete_memo(id)
    @memos.delete(id)
    begin
      connect_db
      @connection.exec(format('DELETE FROM inventory WHERE id = %d;', id))
      puts 'Deleted 1 row of data.'
    rescue PG::Error => e
      puts e.message
    ensure
      @connection&.close
    end
  end

  def modify_memo(id, title, content)
    @memos[id] = { title: title, content: content }
    begin
      connect_db
      @connection.exec(format('UPDATE inventory SET title = %<title>s, content = %<content>s WHERE id = %<id>d;',
                              title: "\'#{title}\'", content: "\'#{content}\'", id: id))
      puts 'Updated 1 row of data.'
    rescue PG::Error => e
      puts e.message
    ensure
      @connection&.close
    end
  end

  def select_memo(params)
    id = params[:id].to_i
    title = CGI.escapeHTML(@memos.dig(id, :title))
    content = CGI.escapeHTML(@memos.dig(id, :content))
    [id, title, content]
  end

  def read_memo
    begin
      connect_db
      @connection.exec('CREATE TABLE IF NOT EXISTS inventory (id serial PRIMARY KEY, title VARCHAR(50), content VARCHAR(500));')
      puts 'Checked the table exists.'
      loaded_data = @connection.exec('SELECT * from inventory;')
    rescue PG::Error => e
      puts e.message
    ensure
      @connection&.close
    end
    return if loaded_data.ntuples.zero?

    loaded_data.each do |row|
      id = row['id'].to_i
      @memos[id] = { title: row['title'], content: row['content'] }
    end
  end

  def connect_db
    host = 'localhost'
    database = 'memo_app_nishitatsu'

    @connection = PG::Connection.new(host: host, dbname: database, port: '5432')
    puts 'Successfully created connection to database'
  end
end

my_memos = MemoData.new

get '/memo/index' do
  @my_all_memos = my_memos.memos
  erb :index
end

get '/memo/:id' do
  @id, @title, content = my_memos.select_memo(params)
  @content = content.gsub(/\r\n|\r|\n/, '<br>')
  erb :memo
end

get '/memo' do
  erb :form
end

post '/memo' do
  title = params[:title].rstrip
  content = params[:content].rstrip
  my_memos.add_memo(title, content)
  redirect '/memo/index'
end

delete '/memo/:id' do
  id = params[:id].to_i
  my_memos.delete_memo(id)
  redirect '/memo/index'
end

get '/memo/:id/edit' do
  @id, @title, @content = my_memos.select_memo(params)
  erb :edit
end

patch '/memo/:id/edit' do
  id = params[:id].to_i
  title = params[:title].rstrip
  content = params[:content].rstrip
  my_memos.modify_memo(id, title, content)
  redirect '/memo/index'
end
