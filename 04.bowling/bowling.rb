#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each { |s| shots << (s == 'X' ? 10 : s.to_i) }

frames = []
frame = []
shots.each do |shot|
  if frames.length > 9 # 10フレーム用の処理。10フレームを迎えていたら最後のframeにshotを追加する。
    frames.last << shot
  elsif shot == 10 # ストライク
    frame << 10
    frames << frame # framesにframeを追加する
    frame = [] # 次のフレームのために配列を空にする
  elsif frame.count == 1 # 2投目用の処理。frameの中身が1つだったら2投目を追加。
    frame << shot
    frames << frame
    frame = []
  else
    frame << shot
  end
end

point = 0
frames.each_with_index do |f, i|
  point += if frames[i] == [10] && frames[i + 1] == [10] && (i < 9)
             20 + frames[i + 2][0]
           elsif f == [10] && (i < 9)
             10 + frames[i + 1][0] + frames[i + 1][1]
           elsif f.sum == 10 && (i < 9)
             f.sum + frames[i + 1][0]
           else
             f.sum
           end
end

puts point
