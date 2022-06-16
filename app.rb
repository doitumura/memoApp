# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require_relative 'common'

MEMOS_JSON_FILE_PATH = 'data/memos.json'
MEMO_ID_FILE_PATH = 'data/memo_id.txt'

helpers do
  def html_escape(text)
    ERB::Util.html_escape(text)
  end
end

['/', '/memos'].each do |path|
  get path do
    read_memos(MEMOS_JSON_FILE_PATH)
    erb :index
  end
end

get '/memos/create' do
  erb :create
end

post '/memos' do
  memo_id = generate_new_id(MEMO_ID_FILE_PATH)
  new_memo = {
    'title' => params[:title],
    'contents' => params[:contents]
  }
  write_memo(MEMOS_JSON_FILE_PATH, memo_id, new_memo)

  redirect '/'
end

get '/memos/:id' do
  read_memo(MEMOS_JSON_FILE_PATH, params[:id])

  erb :show
end

get '/memos/edit/:id' do
  read_memo(MEMOS_JSON_FILE_PATH, params[:id])

  erb :edit
end

patch '/memos/:id' do
  edit_memo = {
    'title' => params[:title],
    'contents' => params[:contents]
  }
  write_memo(MEMOS_JSON_FILE_PATH, params[:id], edit_memo)

  redirect '/'
end

delete '/memos/:id' do
  delete_memo(MEMOS_JSON_FILE_PATH, params[:id])

  redirect '/'
end
