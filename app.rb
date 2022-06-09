require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/' do
  erb :index
end

get '/memos' do
  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos' do
  memo_id = (File.open('memoID.txt', 'r').read.to_i + 1).to_s
  File.open('memoID.txt', 'w') do |file|
    file.write(memo_id)
  end

  memo_json = JSON.parse(File.open('memos.json', 'r').read)
  new_memo = {"title"=>params[:title], "contents"=>params[:contents]}
  memo_json[0][memo_id] = new_memo
  memo_json = JSON.generate(memo_json)
  File.open('memos.json', 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end
