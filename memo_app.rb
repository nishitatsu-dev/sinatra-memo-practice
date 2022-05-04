# frozen_string_literal: true

require 'sinatra'
require 'cgi'

set :environment, :production

class MemoData
  attr_accessor :memos, :id

  def initialize
    @memos = {}
    @id = 0
  end

  def add_memo(title, entry)
    @memos[@id] = { title: title, entry: entry }
    open('data.txt', 'a') do |f|
      f.write "#{@id},#{@memos[@id]}\n"
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
        f.write "#{id},#{value}\n"
      end
    end
  end
end

my_memos = MemoData.new
loaded_data = File.read('data.txt')
unless loaded_data == ''
  ids = loaded_data.scan(/^\d+/).map(&:to_i)
  titles = loaded_data.scan(/(?<={:title=>").+(?=", :entry=>)/)
  entries = loaded_data.scan(/(?<=:entry=>").+(?="})/)
  memos = {}
  ids.each_with_index do |id, n|
    memos[id] = { title: titles[n], entry: entries[n] }
  end
  my_memos.memos = memos
  my_memos.id = ids[-1] + 1
end

get '/memo/index' do
  @title_list = "<ul>\n"
  my_memos.memos.each do |id, memo|
    @title_list += "<li><a href=\"/memo/#{id}\">#{memo[:title]}</a></li>\n"
  end
  @title_list += "</ul>\n"
  erb :index
end

get '/memo/:id' do
  memos = my_memos.memos
  @id = params[:id].to_i
  @title = memos.dig(@id, :title).to_s
  @entry = memos.dig(@id, :entry).to_s
  erb :memo
end

get '/memo' do
  erb :form
end

post '/memo' do
  title = CGI.escapeHTML(params[:title])
  entry = CGI.escapeHTML(params[:entry].rstrip)
  my_memos.add_memo(title, entry)
  redirect '/memo/index'
end

delete '/memo/:id' do
  id = params[:id].to_i
  my_memos.delete_memo(id)
  redirect '/memo/index'
end

get '/memo/:id/edit' do
  memos = my_memos.memos
  @id = params[:id].to_i
  @title = memos.dig(@id, :title).to_s
  @entry = memos.dig(@id, :entry).to_s
  erb :edit
end

patch '/memo/:id/edit' do
  id = params[:id].to_i
  title = CGI.escapeHTML(params[:title])
  entry = CGI.escapeHTML(params[:entry].rstrip)
  my_memos.memos[id] = { title: title, entry: entry }
  my_memos.rewrite_file
  redirect '/memo/index'
end
