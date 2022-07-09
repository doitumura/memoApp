# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

helpers do
  def html_escape(text)
    ERB::Util.html_escape(text)
  end
end

def read_memos(connection)
  @memos = []
  connection.exec('SELECT * FROM MEMOS ORDER BY ID') do |result|
    result.each do |row|
      memo = { id: row['id'], title: row['title'], content: row['content'] }
      @memos.push memo
    end
  end
end

def read_memo(memo_id, connection)
  memo = {}
  connection.prepare('read_memo', 'SELECT * FROM MEMOS WHERE ID = $1')
  connection.exec_prepared('read_memo', [memo_id]) do |result|
    result.each do |row|
      memo = { id: row['id'], title: row['title'], content: row['content'] }
    end
  end
  connection.exec('DEALLOCATE READ_MEMO')
  memo
end

def write_memo(title, content, connection)
  connection.prepare('write_memo', "INSERT INTO MEMOS(ID, TITLE, CONTENT) VALUES(NEXTVAL('MEMOS_SEQUENCE'), $1, $2);")
  connection.exec_prepared('write_memo', [title, content])
  connection.exec('DEALLOCATE WRITE_MEMO')
end

def edit_memo(memo_id, title, content, connection)
  connection.prepare('edit_memo', 'UPDATE MEMOS SET(TITLE, CONTENT) = ($1, $2) WHERE ID = $3;')
  connection.exec_prepared('edit_memo', [title, content, memo_id])
  connection.exec('DEALLOCATE EDIT_MEMO')
end

def delete_memo(memo_id, connection)
  connection.prepare('delete_memo', 'DELETE FROM MEMOS WHERE ID = $1;')
  connection.exec_prepared('delete_memo', [memo_id])
  connection.exec('DEALLOCATE DELETE_MEMO')
end

unless defined?(connection)
  connection = PG.connect(dbname: 'memo_db')

  connection.exec("SELECT TABLENAME FROM PG_TABLES WHERE TABLENAME='memos';") do |result|
    if result.ntuples.zero?
      connection.exec('CREATE TABLE MEMOS(ID SERIAL PRIMARY KEY, TITLE VARCHAR, CONTENT VARCHAR);')
      connection.exec('CREATE SEQUENCE MEMOS_SEQUENCE START 1 INCREMENT 1;')
    end
  end
end

['/', '/memos'].each do |path|
  get path do
    read_memos(connection)

    erb :index
  end
end

get '/memos/create' do
  erb :create
end

post '/memos' do
  write_memo(params[:title], params[:content], connection)

  redirect '/'
end

get '/memos/:id' do
  @memo = read_memo(params[:id], connection)

  erb :show
end

get '/memos/:id/edit' do
  @memo = read_memo(params[:id], connection)

  erb :edit
end

patch '/memos/:id' do
  edit_memo(params[:id], params[:title], params[:content], connection)

  redirect '/'
end

delete '/memos/:id' do
  delete_memo(params[:id], connection)

  redirect '/'
end
