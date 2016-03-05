# coding: utf-8
# Print start and end of each key and sub key
# =>
# a START
#   a1 START
#   a1 END
# a END
# b START
#   b1 START
#   b1 END
#   b2 START
#   b2 END
# b END
# c START
#   c1 START
#   c1 END
#   c2 START
#   c2 END
# c END
# d START
#   d1 START
#   d1 END
# d END
# e START
#   e1 START
#   e1 END
# e END

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

c.on(:keystart) {|key| puts "#{key} START"}.
  on(:keyend) do |key|
    sub_c.flush
    puts "#{key} END"
  end

sub_c.on(:keystart) {|key| puts "  #{key} START"}.
  on(:keyend) {|key| puts "  #{key} END" }

c.execute do
  RECORDS.each_line do |line|
    key, sub_key, value = line.split("\t")
    feed(key)
    sub_c.feed(sub_key)
  end
end

# EOF
