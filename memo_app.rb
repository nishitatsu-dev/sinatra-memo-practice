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
    rewrite_file
    @id += 1
  end

  def delete_memo(id)
    @memos.delete(id)
    rewrite_file
  end

  def rewrite_file
    open('data.txt', 'w') do |f|
      f.write @memos.to_json
    end
  end

  def select_memo(params)
    id = params[:id].to_i
    title = @memos.dig(id, :title).to_s
    content = @memos.dig(id, :content).to_s
    [id, title, content]
  end

  def read_memo
    loaded_data = File.read('data.txt')
    return if loaded_data == ''

    memos = JSON::Parser.new(loaded_data, symbolize_names: true).parse
    @memos = memos.transform_keys { |k| k.to_s.to_i }
    @id = @memos.keys[-1] + 1  # メモIDの最新を取得し、１送る
  end
end

my_memos = MemoData.new
my_memos.read_memo

get '/memo/index' do
  @my_all_memos = my_memos.memos
  erb :index
end

get '/memo/:id' do
  @id, @title, @content = my_memos.select_memo(params)
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
  @id, @title, content = my_memos.select_memo(params)
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
