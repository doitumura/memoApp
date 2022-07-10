# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'
require_relative 'memo.rb'

helpers do
  def html_escape(text)
    ERB::Util.html_escape(text)
  end
end

unless defined?(memo)
  memo = Memo.new()
end

['/', '/memos'].each do |path|
  get path do
    @memos = memo.read_all()

    erb :index
  end
end

get '/memos/create' do
  erb :create
end

post '/memos' do
  memo.write(params[:title], params[:content])

  redirect '/'
end

get '/memos/:id' do
  @memo = memo.read(params[:id])

  erb :show
end

get '/memos/:id/edit' do
  @memo = memo.read(params[:id])

  erb :edit
end

patch '/memos/:id' do
  memo.edit(params[:id], params[:title], params[:content])

  redirect '/'
end

delete '/memos/:id' do
  memo.delete(params[:id])

  redirect '/'
end
