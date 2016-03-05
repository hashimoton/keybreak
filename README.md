# Keybreak

Keybreak is a utility module for key break processing in Ruby.

## Introduction

### Key break processing

The "key break processing" means, assuming a sorted sequence of records which can be grouped by a column,
doing the same process for each group.

The column used for the grouping is a "key".
In processing the record sequence, when the key's value in a record changes from the previous record,
it is called "key break" (also known as ["control break"](https://en.wikipedia.org/wiki/Control_break)).


### Motivation

A typical key break processing is counting the number of records for each key like below:

```ruby
RECORDS =<<EOD
a	1
b	2
b	3
c	4
c	5
c	6
d	7
e	8
e	9
EOD

count = 0
prev_key = nil

RECORDS.each_line do |line|
  key = line.split("\t")[0]
  
  if !prev_key.nil? && key != prev_key
    puts "#{prev_key}:#{count}"
    count = 0
  end
  
  count += 1
  prev_key = key
end

if !prev_key.nil?
    puts "#{prev_key}:#{count}"
end
```

Note that you have to write "puts" once again after the iteration.
This is quite troublesome even for such a simple task, and is very my motivation.

With Keybreak module, the code goes like below:

```ruby
require "keybreak"

RECORDS =<<EOD
a	1
b	2
b	3
c	4
c	5
c	6
d	7
e	8
e	9
EOD

Keybreak.execute_with_controller do |c, count|
  c.on(:keystart) {count = 0}
  c.on(:keyend) {|key| puts "#{key}:#{count}"}

  RECORDS.each_line do |line|
    key = line.split("\t")[0]
    c.feed(key)
    count += 1
  end
end
```

You need to register event handlers as a key break consists of two events:
First, the end of current key sequence (:keyend).
Next, the start of new key sequence (:keystart).

Then call feed() in your record loop.
The method holds current key, detects a key break, and calls the event handlers accordingly.
The block given to execute_with_controller makes sure to process the end of the last key.

In many cases, taking a functional approach such as Enumerable#map, Enumerable#slice_when, etc. would achieve the task simply.
But sometimes, a procedural code is needed.
Keybreak module may assist you to make your key break processing code simpler.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keybreak'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keybreak


## Usage

In your ruby source, write the line below:

```ruby
require "keybreak"
```

Here are some examples of typical key break processing.
See [examples](https://github.com/hashimoton/keybreak/tree/master/examples) for full code.

### Print first values for each key

Register a :keystart handler which prints the given key and value.

```ruby
RECORDS =<<EOD
a	1
b	2
b	3
c	4
c	5
c	6
d	7
e	8
e	9
EOD

Keybreak.execute_with_controller do |c|
  c.on(:keystart) {|key, value| puts "#{key}:#{value}"}

  RECORDS.each_line do |line|
    key, value = line.split("\t")
    c.feed(key, value)
  end
end
```

The result will be:

```
a:1
b:2
c:4
d:7
e:8
```

### Print last values for each key

Borrows RECORDS from above example.

Register a :keyend handler which prints the given key and value.

```ruby
Keybreak.execute_with_controller do |c|
  c.on(:keyend) {|key, value| puts "#{key}:#{value}"}

  RECORDS.each_line do |line|
    key, value = line.split("\t")
    c.feed(key, value)
  end
end
```

The result will be:

```
a:1
b:3
c:6
d:7
e:9
```

### Print sum of values for each key

Clear sum when a key starts.
Print sum when the key ends.

```ruby
Keybreak.execute_with_controller do |c, sum|
  c.on(:keystart) {sum = 0}
  c.on(:keyend) {|key| puts "#{key}:#{sum}"}

  RECORDS.each_line do |line|
    key, value = line.split("\t")
    c.feed(key)
    sum += value.to_i
  end
end
```

The result will be:

```
a:1
b:5
c:15
d:7
e:17
```


### Print sum of values for each key and sub key

Nest Keybreak.execute_with_controller.

Call flush() for sub key in the :keyend handler of the key
so that an end of key triggers an end of sub key.

```ruby
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

Keybreak.execute_with_controller do |c, sum|
  Keybreak.execute_with_controller do |sub_c, sub_sum|
    c.on(:keystart) {sum = 0}
    c.on(:keyend) do |key|
      sub_c.flush
      puts "total #{key}:#{sum}"
    end
  
    sub_c.on(:keystart) {sub_sum = 0}
    sub_c.on(:keyend) do |key|
      puts "#{key}:#{sub_sum}"
      sum += sub_sum
    end

    RECORDS.each_line do |line|
      key, sub_key, value = line.split("\t")
      c.feed(key)
      sub_c.feed(sub_key)
      sub_sum += value.to_i
    end
  end
end
```

The result will be:

```
a1:1
total a:1
b1:2
b2:3
total b:5
c1:9
c2:6
total c:15
d1:7
total d:7
e1:17
total e:17
```

### Print sum of values for each key where empty key means continuation

Sometimes we face the empty keys which mean to continue the value in the previous record.
The pivot table of MS Excel is an example.
Keybreak module can handle this case by providing a block for detecting a keybreak.

```ruby
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
  Keybreak.execute_with_controller do |sub_c, sub_sum|
    c.on(:detection) {|key| !key.empty?}
    c.on(:keystart) {sum = 0}
    c.on(:keyend) do |key|
      sub_c.flush
      puts "total #{key}:#{sum}"
    end
  
    sub_c.on(:detection) {|key| !key.empty?}
    sub_c.on(:keystart) {sub_sum = 0}
    sub_c.on(:keyend) do |key|
      puts "#{key}:#{sub_sum}"
      sum += sub_sum
    end
 
    RECORDS.each_line do |line|
      key, sub_key, value = line.split("\t")
      c.feed(key)
      sub_c.feed(sub_key)
      sub_sum += value.to_i
    end
  end
end
```

The result will be the same as the previous example.

By default, the below block is used for the key break detections.

```
{|key, prev_key| key != prev_key}
```

## Development


### Test

Run the tests in spec directory:

```
$ cd keybreak
$ rake spec
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hashimoton/keybreak.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

