require 'java'
require 'spec_helper'
require 'redstorm-starter/word_count_bolt'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'

describe WordCountBolt do

  it "should process tuple" do
    # our bolt expect a 1-tuple with field "word"
    tuples = ["foo", "bar", "baz", "foo", "foo"].map{|word| Testing.testTuple(Values.new(word), MkTupleParam.new.tap{|p| p.setFields("word")})}
    collector = mock("OutputCollector")

    # the output of the on_receive block will be fed as Values using
    # the collector.emit method
    result = []
    collector.should_receive(:emit).exactly(5).times do |values|
      result << values.to_a
    end

    bolt = WordCountBolt.new
    bolt.prepare(nil, nil, collector)
    tuples.each{|tuple| bolt.execute(tuple)}

    result.should == [["foo", 1], ["bar", 1], ["baz", 1], ["foo", 2], ["foo", 3]]
  end
end
