require 'sinatra'
require 'sinatra/reloader'
require 'json'

['/', '/memos'].each do |path|
  get path do
    @memos = JSON.parse(File.open('memos.json', 'r').read)
    erb :index
  end
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

get '/memos/:id' do
  memo_json = JSON.parse(File.open('memos.json', 'r').read)
  @id = params[:id].to_s
  @memo = memo_json[0][@id]

  erb :show
end

get '/memos/edit/:id' do
  memo_json = JSON.parse(File.open('memos.json', 'r').read)
  @id = params[:id].to_s
  @memo = memo_json[0][@id]

  erb :edit
end

patch '/memos/:id' do
  memo_json = JSON.parse(File.open('memos.json', 'r').read)
  edit_memo = {"title"=>params[:title], "contents"=>params[:contents]}
  memo_json[0][params[:id].to_s] = edit_memo
  memo_json = JSON.generate(memo_json)
  File.open('memos.json', 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end

delete '/memos/:id' do
  memo_json = JSON.parse(File.open('memos.json', 'r').read)
  memo_json[0].delete(params[:id].to_s)
  memo_json = JSON.generate(memo_json)
  File.open('memos.json', 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end
