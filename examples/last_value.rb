# coding: utf-8
# Print last values for each key
# =>
# a:1
# b:3
# c:6
# d:7
# e:9

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "keybreak"

RECORDS =<<EOD
a  1
b  2
b  3
c  4
c  5
c  6
d  7
e  8
e  9
EOD

Keybreak.execute_with_controller do |c|
  c.on(:keyend) {|key, value| puts "#{key}:#{value}"}

  RECORDS.each_line do |line|
    key, value = line.split(" ")
    c.feed(key, value)
  end
end

