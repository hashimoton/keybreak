# coding: utf-8
# Print minimum and maximum value for each key
# =>
# a:min=1,max=1
# b:min=2,max=3
# c:min=4,max=6
# d:min=7,max=7
# e:min=8,max=9

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

Keybreak.execute_with_controller do |c, values|
  c.on(:keystart) {values = []}.
    on(:keyend) {|key| puts "#{key}:min=#{values.min},max=#{values.max}"}

  RECORDS.each_line do |line|
    key, value = line.split(" ")
    c.feed(key)
    values.push(value.to_i)
  end
end

# EOF
