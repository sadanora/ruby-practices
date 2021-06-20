# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def print_three_column(file_names)
  slice_number = ((file_names.length % 3).zero? ? (file_names.length / 3) : (file_names.length / 3 + 1))
  file_names = file_names.each_slice(slice_number).to_a
  file_name_deficiency = (file_names[-2].length - file_names[-1].length)
  file_name_deficiency.times { file_names[-1].push('') } if file_names[-1].length != file_names[-2].length
  string_size = file_names.flatten.max_by(&:length).length + 7

  file_names.transpose.each do |file_name|
    print file_name[0] + ' ' * (string_size - file_name[0].length)
    print file_name[1] + ' ' * (string_size - file_name[1].length)
    print file_name[2]
    print "\n"
  end
end

def print_long_format(file_names)
  blocks = file_names.map { |file_name| File.lstat("#{Dir.pwd}/#{file_name}").blocks }
  total = blocks.inject(0) { |result, n| result + n }
  puts "total #{total}"

  @long_format = init_long_format(file_names)
  calc_str_length(@long_format)
  @long_format.each do |x|
    print x['permission']
    print format("%#{@nlink_len}s", x['nlink'])
    print format("%#{@owner_name_len}s", x['owner_name'])
    print format("%#{@group_name_len}s", x['group_name'])
    print format("%#{@file_size_len}s", x['file_size'])
    print format('%3s', x['month'])
    print format('%3s', x['day'])
    print "#{format('%6s', x['time'].rjust(6))} #{x['file_name']}"
    print "\n"
  end
end

def init_long_format(file_names)
  file_names.map do |file_name|
    lstat = File.lstat("#{Dir.pwd}/#{file_name}")
    mode = lstat.mode.to_s(8).rjust(6, '0')
    dt = lstat.mtime.to_datetime
    {
      'permission' => convert_permission(lstat.ftype) + convert_permission(mode[-3]) + convert_permission(mode[-2]) + convert_permission(mode[-1]),
      'nlink' => lstat.nlink,
      'owner_name' => Etc.getpwuid(lstat.uid).name,
      'group_name' => Etc.getgrgid(lstat.gid).name,
      'file_size' => lstat.size,
      'month' => lstat.mtime.month,
      'day' => lstat.mtime.day,
      'time' => dt < (DateTime.now << 6) || dt > DateTime.now ? dt.strftime('%Y') : dt.strftime('%H:%M'),
      'file_name' => file_name
    }
  end
end

def calc_str_length(_long_format)
  @nlink_len = @long_format.map { |x| x['nlink'].to_s.length }.max + 2
  @owner_name_len = @long_format.map { |x| x['owner_name'].to_s.length }.max + 1
  @group_name_len = @long_format.map { |x| x['group_name'].to_s.length }.max + 2
  @file_size_len = @long_format.map { |x| x['file_size'].to_s.length }.max + 2
end

def convert_permission(key)
  {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's',
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[key]
end

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
  print_three_column(file_names)
end
