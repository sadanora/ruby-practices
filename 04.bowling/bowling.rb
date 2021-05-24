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
  elsif
    frame << shot
  end
end

point = 0
frames.each_with_index do |frame, idx|
          if frames[idx] == [10] && frames[idx + 1] == [10] && (idx < 9)
            point += 20 + frames[idx + 2][0]
          elsif frame == [10] && (idx < 9)
            point += 10 + frames[idx + 1][0] + frames[idx + 1][1]
          elsif frame.sum == 10 && (idx < 9)
            point += frame.sum + frames[idx + 1][0]
          else
            point += frame.sum
          end
end

puts point
