require 'java'
require 'spec_helper'
require 'redstorm-starter/split_sentence_bolt'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'

describe SplitSentenceBolt do

  it "should process tuple" do
    # out bolt expect a 1-tuple with field "words"
    tuple = Testing.testTuple(Values.new("this is a   test sentence"), MkTupleParam.new.tap{|p| p.setFields("words")})
    collector = mock("OutputCollector")

    # the output of the on_receive block will be fed as Values using
    # the collector.emit method
    result = []
    collector.should_receive(:emit).exactly(5).times do |values|
      result << values[0]
    end

    bolt = SplitSentenceBolt.new
    bolt.prepare(nil, nil, collector)
    bolt.execute(tuple)

    result.should == ["this", "is", "a", "test", "sentence"]
  end
end
