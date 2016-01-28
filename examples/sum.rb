# coding: utf-8
# Print sum of values for each key
# =>
# a:1
# b:5
# c:15
# d:7
# e:17

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "keybreak"

Keybreak.execute_with_controller do |c, sum|
  c.on(:keystart) {sum = 0}
  c.on(:keyend) {|key| puts "#{key}:#{sum}"}

  DATA.each do |line|
    key, value = line.chomp.split("\t")
    c.feed(key)
    sum += value.to_i
  end
end

__END__
a	1
b	2
b	3
c	4
c	5
c	6
d	7
e	8
e	9
