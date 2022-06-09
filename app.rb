require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb :index
end

get '/memos' do
  erb :index
end
