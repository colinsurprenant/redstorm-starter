require 'java'

$:.unshift File.dirname(__FILE__) + '/../lib/'
$:.unshift File.dirname(__FILE__) + '/../spec'

require 'rspec'

# TODO
# below jar loading and classpath stuff should be handled in RedStorm
# see https://github.com/colinsurprenant/redstorm/issues/85

# load Storm jars
storm_jars = File.dirname(__FILE__) + '/../target/dependency/storm/default/*.jar'
Dir.glob(storm_jars).each{|f| require f}

# add our java classes to the classpath
$CLASSPATH << File.dirname(__FILE__) + '/../target/classes/'

# This hack get rif of the "Use RbConfig instead of obsolete and deprecated Config"
# deprecation warning that is triggered by "java_import 'backtype.storm.Config'".
Object.send :remove_const, :Config
Config = RbConfig

# see https://github.com/colinsurprenant/redstorm/issues/7
module Backtype
  java_import 'backtype.storm.Config'
end

java_import 'redstorm.storm.jruby.JRubyBolt'
java_import 'redstorm.storm.jruby.JRubySpout'
java_import 'redstorm.storm.jruby.JRubyBatchBolt'
java_import 'redstorm.storm.jruby.JRubyBatchCommitterBolt'
java_import 'redstorm.storm.jruby.JRubyBatchSpout'
java_import 'redstorm.storm.jruby.JRubyTransactionalSpout'
java_import 'redstorm.storm.jruby.JRubyTransactionalBolt'
java_import 'redstorm.storm.jruby.JRubyTransactionalCommitterBolt'


# convert output of Testing.read_tuples from Java ArrayList of ArrayList to Ruby Array of Array.
def result_tuples(result, id)
  Testing.read_tuples(result, id.to_s).map{|tuples| tuples.to_a}
end

