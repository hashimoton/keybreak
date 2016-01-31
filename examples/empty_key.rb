# coding: utf-8
# Print sum of values for each key where empty key means continuation
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
	b2	3
c	c1	4
		5
	c2	6
d	d1	7
e	e1	8
		9
EOD

Keybreak.execute_with_controller do |c, sum|
  c.on(:detection) {|key| !key.empty?}
  c.on(:keystart) {sum = 0}
  c.on(:keyend) {|key| puts "total #{key}:#{sum}"}
 
  Keybreak.execute_with_controller do |sub_c, sub_sum|
    sub_c.on(:detection) {|keys| !keys.all? {|key| key.empty?}}
    sub_c.on(:keystart) {sub_sum = 0}
    sub_c.on(:keyend) do |keys|
      puts "#{keys[1]}:#{sub_sum}"
      sum += sub_sum
    end
 
    RECORDS.each_line do |line|
      key, sub_key, value = line.split("\t")
      sub_c.feed([key, sub_key])
      c.feed(key)
      sub_sum += value.to_i
    end
  end
end

# EOF
