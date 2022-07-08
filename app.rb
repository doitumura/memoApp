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
  connection.exec('select * from memos') do |result|
    result.each do |row|
      memo = { id: row['id'], title: row['title'], content: row['content'] }
      @memos.push memo
    end
  end
end

def read_memo(memo_id, connection)
  memo = {}
  connection.prepare('read_memo', 'select * from memos where id = $1')
  connection.exec_prepared('read_memo', [memo_id]) do |result|
    result.each do |row|
      memo = { id: row['id'], title: row['title'], content: row['content'] }
    end
  end
  connection.exec('DEALLOCATE read_memo')
  memo
end

def write_memo(title, content, connection)
  connection.prepare('write_memo', "insert into memos(id, title, content) values(nextval('memos_sequence'), $1, $2);")
  connection.exec_prepared('write_memo', [title, content])
  connection.exec('DEALLOCATE write_memo')
end

def edit_memo(memo_id, title, content, connection)
  connection.prepare('edit_memo', 'update memos set(title, content) = ($1, $2) where id = $3;')
  connection.exec_prepared('edit_memo', [title, content, memo_id])
  connection.exec('DEALLOCATE edit_memo')
end

def delete_memo(memo_id, connection)
  connection.prepare('delete_memo', 'delete from memos where id = $1;')
  connection.exec_prepared('delete_memo', [memo_id])
  connection.exec('DEALLOCATE delete_memo')
end

unless defined?(connection)
  connection = PG.connect(dbname: 'memo_db')

  connection.exec("select tablename from pg_tables where tablename='memos';") do |result|
    if result.ntuples.zero?
      connection.exec('create table memos(id serial primary key, title varchar, content varchar);')
      connection.exec('create sequence memos_sequence start 1 increment 1;')
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
