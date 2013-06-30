require 'red_storm'
require 'redstorm-starter/random_sentence_spout'
require 'redstorm-starter/split_sentence_bolt'
require 'redstorm-starter/word_count_bolt'

class WordCountTopology < RedStorm::DSL::Topology
  spout RandomSentenceSpout, :parallelism => 2 do
    output_fields :words
  end

  bolt SplitSentenceBolt, :parallelism => 2 do
    output_fields :word
    source RandomSentenceSpout, :shuffle
  end

  bolt WordCountBolt, :parallelism => 2 do
    output_fields :word, :count
    source SplitSentenceBolt, :fields => ["word"]
  end

  configure do |env|
    debug true
    max_task_parallelism 2
    num_workers 2
    max_spout_pending 1000
  end
end
