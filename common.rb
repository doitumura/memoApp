# frozen_string_literal: true

def generate_new_id(file_path)
  memo_id = (File.open(file_path, 'r').read.to_i + 1).to_s
  File.open(file_path, 'w') do |file|
    file.write(memo_id)
  end

  memo_id
end

def write_memo(file_path, memo_id, memo)
  memos = JSON.parse(File.open(file_path, 'r').read)
  memos[0][memo_id] = memo
  memos_json = JSON.generate(memos)

  File.open(file_path, 'w+') do |file|
    file.write(memos_json)
  end
end

def delete_memo(file_path, memo_id)
  memos = JSON.parse(File.open(file_path, 'r').read)
  memos[0].delete(memo_id)
  memos_json = JSON.generate(memos)

  File.open(file_path, 'w+') do |file|
    file.write(memos_json)
  end
end

def read_memos(file_path)
    @memos = JSON.parse(File.open(file_path, 'r').read)
end

def read_memo(file_path, memo_id)
  memos = JSON.parse(File.open(file_path, 'r').read)
  @id = memo_id
  @memo = memos[0][@id]
end
