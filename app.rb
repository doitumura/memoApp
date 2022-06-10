require 'sinatra'
require 'sinatra/reloader'
require 'json'

MEMOS_JSON_FILE_PATH = 'data/memos.json'
MEMO_ID_FILE_PATH = 'data/memo_id.txt'

['/', '/memos'].each do |path|
  get path do
    @memos = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
    erb :index
  end
end

get '/memos/create' do
  erb :create
end

post '/memos' do
  memo_id = (File.open(MEMO_ID_FILE_PATH, 'r').read.to_i + 1).to_s
  File.open(MEMO_ID_FILE_PATH, 'w') do |file|
    file.write(memo_id)
  end

  memo_json = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
  new_memo = {"title"=>params[:title], "contents"=>params[:contents]}
  memo_json[0][memo_id] = new_memo
  memo_json = JSON.generate(memo_json)
  File.open(MEMOS_JSON_FILE_PATH, 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end

get '/memos/:id' do
  memo_json = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
  @id = params[:id].to_s
  @memo = memo_json[0][@id]

  erb :show
end

get '/memos/edit/:id' do
  memo_json = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
  @id = params[:id].to_s
  @memo = memo_json[0][@id]

  erb :edit
end

patch '/memos/:id' do
  memo_json = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
  edit_memo = {"title"=>params[:title], "contents"=>params[:contents]}
  memo_json[0][params[:id].to_s] = edit_memo
  memo_json = JSON.generate(memo_json)
  File.open(MEMOS_JSON_FILE_PATH, 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end

delete '/memos/:id' do
  memo_json = JSON.parse(File.open(MEMOS_JSON_FILE_PATH, 'r').read)
  memo_json[0].delete(params[:id].to_s)
  memo_json = JSON.generate(memo_json)
  File.open(MEMOS_JSON_FILE_PATH, 'w+') do |file|
    file.write(memo_json)
  end

  redirect '/'
end
