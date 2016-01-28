# coding: utf-8
# Print number of each key
# =>
# a:1
# b:2
# c:3
# d:1
# e:2

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "keybreak"

Keybreak.execute_with_controller do |c, count|
  c.on(:keystart) {count = 0}
  c.on(:keyend) {|key| puts "#{key}:#{count}"}

  DATA.each do |line|
    key = line.chomp.split("\t")[0]
    c.feed(key)
    count += 1
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
