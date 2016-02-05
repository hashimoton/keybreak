# coding: utf-8
# Print sum of values for each key and sub key
# =>
# a1:1
# total a:1
# b1:2
# b2:3
# total b:5
# c1:9
# c2:6
# total c:15
# d1:7
# total d:7
# e1:17
# total e:17

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "keybreak"

RECORDS =<<EOD
a	a1	1
b	b1	2
b	b2	3
c	c1	4
c	c1	5
c	c2	6
d	d1	7
e	e1	8
e	e1	9
EOD

c = Keybreak::Controller.new
sub_c = Keybreak::Controller.new

sum = 0
c.on(:keystart) {sum = 0}
c.on(:keyend) do |key|
  sub_c.flush
  puts "total #{key}:#{sum}"
end

sub_sum = 0
sub_c.on(:keystart) {sub_sum = 0}
sub_c.on(:keyend) do |key|
  puts "#{key}:#{sub_sum}"
  sum += sub_sum
end

c.execute do
  RECORDS.each_line do |line|
    key, sub_key, value = line.split("\t")
    c.feed(key)
    sub_c.feed(sub_key)
    sub_sum += value.to_i
  end
end

# EOF
