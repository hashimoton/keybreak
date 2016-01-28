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

Keybreak.execute_with_controller do |c, sum|
  c.on(:keystart) {sum = 0}
  c.on(:keyend) {|key| puts "total #{key}:#{sum}"}
 
  Keybreak.execute_with_controller do |sub_c, sub_sum|
    sub_c.on(:keystart) {sub_sum = 0}
    sub_c.on(:keyend) do |keys|
      puts "#{keys[1]}:#{sub_sum}"
      sum += sub_sum
    end
    
    DATA.each do |line|
      key, sub_key, value = line.chomp.split("\t")
      sub_c.feed([key, sub_key])
      c.feed(key)
      sub_sum += value.to_i
    end
  end
end

__END__
a	a1	1
b	b1	2
b	b2	3
c	c1	4
c	c1	5
c	c2	6
d	d1	7
e	e1	8
e	e1	9
