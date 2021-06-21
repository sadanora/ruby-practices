#!/usr/bin/env ruby
# frozen_string_literal: true

def add_shot_to_frame(frame, shot)
  frame << shot
end

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each { |s| shots << (s == 'X' ? 10 : s.to_i) }

frames = []
frame = []
shots.each do |shot|
  if frames.length > 9 # 10フレーム用の処理。10フレームを迎えていたら最後のframeにshotを追加する。
    frames.last << shot
  elsif shot == 10 || frame.count == 1
    add_shot_to_frame(frame, shot)
    frames << frame
    frame = []
  else
    add_shot_to_frame(frame, shot)
  end
end

point = 0
frames.each_with_index do |f, i|
  point += if frames[i] == [10] && frames[i + 1] == [10]
             20 + frames[i + 2][0]
           elsif f == [10]
             10 + frames[i + 1][0] + frames[i + 1][1]
           elsif f.sum == 10 && (i < 9)
             f.sum + frames[i + 1][0]
           else
             f.sum
           end
end

puts point
