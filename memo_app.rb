# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require 'json'

set :environment, :production

class MemoData
  attr_accessor :memos, :id

  def initialize
    @memos = {}
    @id = 0
  end

  def add_memo(title, content)
    @memos[@id] = { title: title, content: content }
    open('data.txt', 'a') do |f|
      f.write "{\"id\":#{@id},#{@memos[@id].to_json[1..]}\n"
    end
    @id += 1
  end

  def delete_memo(id)
    @memos.delete(id)
    rewrite_file
  end

  def rewrite_file
    open('data.txt', 'w') do |f|
      @memos.each do |id, value|
        f.write "{\"id\":#{id},#{value.to_json[1..]}\n"
      end
    end
  end

  def select_memo_data(params)
    id = params[:id].to_i
    title = @memos.dig(id, :title).to_s
    content = @memos.dig(id, :content).to_s
    [id, title, content]
  end
end

my_memos = MemoData.new
loaded_data = File.read('data.txt')
unless loaded_data == ''
  ids = loaded_data.scan(/(?<={"id":)\d+(?=,)/).map(&:to_i)
  titles = loaded_data.scan(/(?<="title":").+(?=",)/)
  contents = loaded_data.scan(/(?<="content":").+(?="})/)
  memos = {}
  ids.each_with_index do |id, n|
    memos[id] = { title: titles[n], content: contents[n] }
  end
  my_memos.memos = memos
  my_memos.id = ids[-1] + 1
end

get '/memo/index' do
  @my_all_memos = my_memos.memos
  erb :index
end

get '/memo/:id' do
  @id, @title, @content = my_memos.select_memo_data(params)
  erb :memo
end

get '/memo' do
  erb :form
end

post '/memo' do
  title = CGI.escapeHTML(params[:title])
  content = CGI.escapeHTML(params[:content].rstrip).gsub(/\r\n|\r|\n/, '<br>')
  my_memos.add_memo(title, content)
  redirect '/memo/index'
end

delete '/memo/:id' do
  id = params[:id].to_i
  my_memos.delete_memo(id)
  redirect '/memo/index'
end

get '/memo/:id/edit' do
  @id, @title, content = my_memos.select_memo_data(params)
  @content = content.gsub(/<br>/, "\n")
  erb :edit
end

patch '/memo/:id/edit' do
  id = params[:id].to_i
  title = CGI.escapeHTML(params[:title])
  content = CGI.escapeHTML(params[:content].rstrip).gsub(/\r\n|\r|\n/, '<br>')
  my_memos.memos[id] = { title: title, content: content }
  my_memos.rewrite_file
  redirect '/memo/index'
end
