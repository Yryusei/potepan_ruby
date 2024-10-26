# frozen_string_literal: true

require 'csv'
require 'active_support/all'
# メモapp
class Memo
  def initialize
    @choice_word = ''
    @choice_allow_values = []
    @file_name = ''
    @file_datas = []
    @row_num = 0
    @file_hash = {}
    @edit_mode = false
    @edit_row_mode = false
  end

  # memoアプリ
  def memo_app
    Dir.mkdir('./csv_db', 0o666) unless File.directory?('./csv_db')

    @choice_word = '1で新規ファイルを作成, 2で既存のファイルを編集 3でファイルを消す exitで終了'
    @choice_allow_values = %w[1 2 3 exit]
    memo_choice = fetch_choice

    # メモ新規作成
    return write_memo if memo_choice == '1'

    @edit_mode = true
    # メモ削除
    return del_memo if memo_choice == '3'

    # 終了
    return if memo_choice == 'exit'

    # 編集するファイルを選択
    select_edit_file

    @choice_word = '1で行末に追加, 2で行の編集, 3で行の削除, exitで終了'
    @choice_allow_values = %w[1 2 3 exit]
    edit_choice = fetch_choice if memo_choice == '2'

    # 行末に追加
    if edit_choice == '1'
      @file_datas = @file_hash.values
      write_memo
    end

    @edit_row_mode = true
    # 行の編集
    return edit_row if edit_choice == '2'

    # 行の削除
    del_row if edit_choice == '3'
  end

  private

  # ファイルを選択する
  def select_edit_file
    @file_name = create_file_name
    puts '----------------------------------'
    CSV.foreach("./csv_db/#{@file_name}.csv") do |row|
      @row_num += 1
      @file_hash[@row_num.to_s.to_sym] = row
      puts "#{@row_num}: #{row}"
    end
    puts '----------------------------------'
  end

  # 行の編集
  def edit_row
    @choice_word = "1 ~ #{@row_num} までの編集する行数を選択してください"
    @choice_allow_values = (1..@row_num).to_a.map(&:to_s)
    row_choice = fetch_choice
    puts '----------------------------------'
    puts "#{row_choice}の行目を編集します"
    puts @file_hash[row_choice.to_sym]
    puts '----------------------------------'
    puts '編集したい内容を書いて下さい。 列で分ける際は [ , ](カンマ) を入力して下さい'
    puts 'enterで保存されます'
    @file_hash[row_choice.to_sym] = [_clean_file_data(gets.chomp)]
    @file_datas = @file_hash.values
    write_memo
  end

  # 行の削除
  def del_row
    return puts '消す行がありません' if @row_num.zero?

    @choice_word = "1 ~ #{@row_num} までの削除する行数を選択してください"
    @choice_allow_values = (1..@row_num).to_a.map(&:to_s)
    row_choice = fetch_choice
    @file_hash[row_choice.to_sym] = ['']
    @file_datas = @file_hash.values
    write_memo
  end

  # 選択肢を返却
  def fetch_choice
    loop do
      puts @choice_word
      choice = gets.chomp

      # バリデーション
      return choice if @choice_allow_values.include?(choice)

      puts '不正な値です'
      puts '----------------------------------'
    end
  end

  # ファイルに書き込み
  def write_memo
    _add_file_data unless @edit_row_mode

    CSV.open("./csv_db/#{@file_name}.csv", 'w') do |csv|
      csv.flock(File::LOCK_EX)
      @file_datas.each do |data|
        csv << data
      end
    end
    File.chmod(0o666, "./csv_db/#{@file_name}.csv")

    puts '書き込みました'
  end

  # ファイルデータに追加する
  def _add_file_data
    @file_name = create_file_name if @file_name.blank?

    puts 'メモしたい内容を記入してください'
    puts '完了したら 空行を入力してして下さい'

    loop do
      file_data = gets.chomp
      return if file_data == ''

      @file_datas << [_clean_file_data(file_data)]
    end
  end

  # 削除処理
  def del_memo
    @file_name = create_file_name
    File.delete("./csv_db/#{@file_name}.csv")
    puts 'ファイルを消去成功'
  end

  # @file_name を作成
  def create_file_name
    word = @edit_mode ? 'そのファイルは存在しません' : 'そのファイルは存在します'
    puts '現在のファイル一覧'
    puts '---------------------'
    puts Dir.entries('./csv_db')
    puts '---------------------'

    loop do
      puts 'ファイル名を入力してください'
      @file_name = gets.chomp
      next if @file_name == ''

      file_status = file_exists?

      # 新規作成時に使用
      return @file_name if !@edit_mode && !file_status

      # 編集時に使用
      return @file_name if @edit_mode && file_status

      puts word
      puts '終了は exit を入力してください 再入力の際はenterを入力して下さい'
      exit if gets.chomp == 'exit'

      puts '----------------------------------'
    end
  end

  # ファイルが存在するのか
  def file_exists?
    # 拡張子の削除
    @file_name = @file_name.sub(/\.[^.]+$/, '')
    # フォルダー名に使えない記号の削除
    @file_name = @file_name.sub(%r{[￥\/:*?"<>|]}, '')
    # スペースの削除
    @file_name = @file_name.sub(/\s+/, '')
    File.exist?("./csv_db/#{@file_name}.csv")
  end

  # file_data をリファクタリングする
  def _clean_file_data(file_data)
    # バックスラッシュの削除
    file_data.sub(%r{/+}, '')
  end
end
