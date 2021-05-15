#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each { |s| shots << (s == 'X' ? 10 : s.to_i) }

frames = []
n = 0
shots.each do
  if shots[n] == 10
    frames.push([10, 0])
    n += 1
  elsif  n < shots.length
    frames.push([shots[n], shots[n + 1]])
    n += 2
  end
end

# 最終フレームにnilがあれば0番目の値を前のフレームに連結する
if frames.last[1].nil?
  frames[9].concat(frames[10])
  frames.delete_at(10)
  frames[9].delete_at(-1)
end

point = 0
frames.each_with_index do |frame, idx|
  point += if frame == [10, 0] && frames[idx + 1] == [10, 0] && frames[idx + 2] == [10, 0] && (idx < 8)
             30
           elsif frame == [10, 0] && frames[idx + 1] == [10, 0] && (idx < 9)
             20 + frames[idx + 2][0]
           elsif frame == [10, 0] && (idx < 9)
             10 + frames[idx + 1][0] + frames[idx + 1][1]
           elsif frame.sum == 10 && (idx < 9)
             frame.sum + frames[idx + 1][0]
           else
             frame.sum
           end
end

puts point
