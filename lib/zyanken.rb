# frozen_string_literal: true

# じゃんけんapp
class Zyanken
  ZYANKENHASH = { '1': 'グー', '2': 'チョキ', '3': 'パー' }.freeze
  ACHIMUITEHASH = { '1': '上', '2': '下', '3': '左', '4': '右' }.freeze
  def initialize
    @my_hand = nil
    @enemy_hand = nil
    @my_point = nil
    @enemy_point = nil
  end

  def zyanken_app
    loop do
      fetch_hand

      puts 'ほい!'
      puts "私: #{ZYANKENHASH[@my_hand.to_sym]}"
      puts "相手: #{ZYANKENHASH[@enemy_hand.to_sym]}"
      puts '----------------------------------'

      zyanken_result = fetch_zyanken_result

      # じゃんけん あいこの場合
      next if zyanken_result.nil?

      fetch_point

      puts "あなた: #{ACHIMUITEHASH[@my_point.to_sym]}"
      puts "相手: #{ACHIMUITEHASH[@enemy_point.to_sym]}"

      # じゃんけん 勝ちの場合
      return puts 'あなたは勝ちました' if zyanken_result && @my_point == @enemy_point

      # じゃんけん 敗けの場合
      return puts 'あなたは負けました' if @my_point == @enemy_point

      puts '引き分けです'
      puts '----------------------------------'
    end
  end

  private

  # 自分と相手のじゃんけんを獲得
  def fetch_hand
    @enemy_hand = rand(1..3).to_s
    loop do
      puts 'じゃんけん...'
      puts '自分が出す手を選んでください'
      puts '1はグーです, 2はチョキです, 3はパーです'
      puts '----------------------------------'

      hand = gets.chomp
      # バリデーション
      break @my_hand = hand if %w[1 2 3].include?(hand)

      puts '不正な値です'
      puts '----------------------------------'
    end
    true
  end

  # 自分と相手のあっち向いてホイの方向を獲得
  def fetch_point
    @enemy_point = rand(1..4).to_s
    loop do
      puts 'あっち向いて~'
      puts '1は上, 2は下, 3は左, 4は右'
      puts '----------------------------------'

      point = gets.chomp
      # バリデーション
      break @my_point = point if %w[1 2 3 4].include?(point)

      puts '不正な値です'
      puts '----------------------------------'
    end
    true
  end

  # じゃんけんの結果を獲得
  def fetch_zyanken_result
    if @my_hand == @enemy_hand
      puts 'あいこです'
      puts '仕切り直しです'
      puts '----------------------------------'
      return nil
    end

    if { '1': '2', '2': '3', '3': '1' }[@my_hand.to_sym] == @enemy_hand
      puts 'じゃんけんに勝ちました'
      puts 'あなたが指す方向を選んでください'
      puts '----------------------------------'
      return true
    end

    puts 'じゃんけんに負けました'
    puts 'あなたが向く方向を選んでください'
    puts '----------------------------------'
    false
  end
end
