require 'red_storm'

class WordCountBolt < RedStorm::DSL::Bolt
  on_init {@counts = Hash.new{|h, k| h[k] = 0}}

  on_receive do |tuple|
    word = tuple[:word].to_s
    @counts[word] += 1

    [word, @counts[word]]
  end
end
