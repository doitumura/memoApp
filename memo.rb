# frozen_string_literal: true

class Memo
  def initialize
    @connection = PG.connect(dbname: 'memo_db')

    @connection.exec("CREATE TABLE IF NOT EXISTS memos(id SERIAL PRIMARY KEY, title VARCHAR, content VARCHAR);")
  end

  def read_all
    memos = []
    @connection.exec('SELECT * FROM memos ORDER BY id') do |result|
      result.each do |row|
        memo = { id: row['id'], title: row['title'], content: row['content'] }
        memos.push memo
      end
    end
    memos
  end

  def read(memo_id)
    memo = {}
    @connection.prepare('read_memo', 'SELECT * FROM memos WHERE id = $1')
    @connection.exec_prepared('read_memo', [memo_id]) do |result|
      result.each do |row|
        memo = { id: row['id'], title: row['title'], content: row['content'] }
      end
    end
    @connection.exec('DEALLOCATE read_memo')
    memo
  end

  def write(title, content)
    @connection.prepare('write_memo', "INSERT INTO memos(title, content) VALUES($1, $2);")
    @connection.exec_prepared('write_memo', [title, content])
    @connection.exec('DEALLOCATE write_memo')
  end

  def edit(memo_id, title, content)
    @connection.prepare('edit_memo', 'UPDATE memos SET(title, content) = ($1, $2) WHERE id = $3;')
    @connection.exec_prepared('edit_memo', [title, content, memo_id])
    @connection.exec('DEALLOCATE edit_memo')
  end

  def delete(memo_id)
    @connection.prepare('delete_memo', 'DELETE FROM memos WHERE id = $1;')
    @connection.exec_prepared('delete_memo', [memo_id])
    @connection.exec('DEALLOCATE delete_memo')
  end
end
