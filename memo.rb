# frozen_string_literal: true

class Memo
  attr_accessor :connection

  def initialize
    self.connection = PG.connect(dbname: 'memo_db')

    connection.exec("CREATE TABLE IF NOT EXISTS memos(ID SERIAL PRIMARY KEY, TITLE VARCHAR, CONTENT VARCHAR);")
  end

  def read_all
    memos = []
    connection.exec('SELECT * FROM MEMOS ORDER BY ID') do |result|
      result.each do |row|
        memo = { id: row['id'], title: row['title'], content: row['content'] }
        memos.push memo
      end
    end
    memos
  end

  def read(memo_id)
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

  def write(title, content)
    connection.prepare('write_memo', "INSERT INTO MEMOS(TITLE, CONTENT) VALUES($1, $2);")
    connection.exec_prepared('write_memo', [title, content])
    connection.exec('DEALLOCATE WRITE_MEMO')
  end

  def edit(memo_id, title, content)
    connection.prepare('edit_memo', 'UPDATE MEMOS SET(TITLE, CONTENT) = ($1, $2) WHERE ID = $3;')
    connection.exec_prepared('edit_memo', [title, content, memo_id])
    connection.exec('DEALLOCATE EDIT_MEMO')
  end

  def delete(memo_id)
    connection.prepare('delete_memo', 'DELETE FROM MEMOS WHERE ID = $1;')
    connection.exec_prepared('delete_memo', [memo_id])
    connection.exec('DEALLOCATE DELETE_MEMO')
  end
end
