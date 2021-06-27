#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def main
  options = ARGV.getopts('a', 'l', 'r')

  file_names = if options ['a']
                 Dir.glob('*', File::FNM_DOTMATCH).sort
               else
                 Dir.glob('*').sort
               end

  file_names = file_names.reverse if options ['r']

  if options['l']
    print_long_format(file_names)
  else
    print_column_format(file_names)
  end
end

COLUMN_COUNT = 3
BLANK_COUNT = 7
FILE_TYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze
FILE_PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze
SIX_MONTHS_AGO = Time.now - (60 * 60 * 24 * 181)

def print_column_format(file_names)
  file_name_length = file_names.flatten.max_by(&:length).length + BLANK_COUNT
  slice_number = (file_names.length / COLUMN_COUNT.to_f).ceil
  nested_file_names = file_names.each_slice(slice_number).to_a
  if file_names.length > COLUMN_COUNT
    file_name_deficiency = nested_file_names[-2].length - nested_file_names[-1].length
    file_name_deficiency.times { nested_file_names[-1].push('') }
  end

  nested_file_names.transpose.each do |nested_file_name|
    nested_file_name.each do |file_name|
      print file_name.ljust(file_name_length)
    end
    print "\n"
  end
end

def print_long_format(file_names)
  total = file_names.sum { |file_name| File.lstat("#{Dir.pwd}/#{file_name}").blocks }
  puts "total #{total}"
  file_info_list = build_file_info_list(file_names)
  nlink_length, owner_name_length, group_name_length, file_size_length = detect_max_lengths(file_info_list)
  file_info_list.each do |hash|
    print "#{hash[:file_type]}#{hash[:permission]}".rjust(10)
    print (hash[:nlink]).to_s.rjust(nlink_length)
    print " #{hash[:owner_name]}".ljust(owner_name_length)
    print "  #{hash[:group_name]}".ljust(group_name_length)
    print (hash[:file_size]).to_s.rjust(file_size_length)
    print (hash[:month]).to_s.rjust(3)
    print (hash[:day]).to_s.rjust(3)
    print (hash[:time]).to_s.rjust(6)
    print " #{hash[:file_name]}"
    print "\n"
  end
end

def build_file_info_list(file_names)
  file_names.map do |file_name|
    lstat = File.lstat("#{Dir.pwd}/#{file_name}")
    mode = lstat.mode.to_s(8).rjust(6, '0')
    file_type = FILE_TYPE[lstat.ftype]
    permission = FILE_PERMISSION[mode[-3]] + FILE_PERMISSION[mode[-2]] + FILE_PERMISSION[mode[-1]]
    mtime = lstat.mtime
    time = lstat.mtime < SIX_MONTHS_AGO ? mtime.strftime('%Y') : mtime.strftime('%H:%M')
    {
      file_type: file_type,
      permission: permission,
      nlink: lstat.nlink,
      owner_name: Etc.getpwuid(lstat.uid).name,
      group_name: Etc.getgrgid(lstat.gid).name,
      file_size: lstat.size,
      month: lstat.mtime.month,
      day: lstat.mtime.day,
      time: time,
      file_name: file_name
    }
  end
end

def detect_max_lengths(file_info_list)
  nlink_length = file_info_list.map { |h| h[:nlink].to_s.length }.max + 2
  owner_name_length = file_info_list.map { |h| h[:owner_name].length }.max + 1
  group_name_length = file_info_list.map { |h| h[:group_name].length }.max + 2
  file_size_length = file_info_list.map { |h| h[:file_size].to_s.length }.max + 2
  [nlink_length, owner_name_length, group_name_length, file_size_length]
end

main
