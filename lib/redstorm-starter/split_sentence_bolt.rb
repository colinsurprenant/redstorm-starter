require 'red_storm'

class SplitSentenceBolt < RedStorm::DSL::Bolt
  on_receive {|tuple| tuple[:words].split.map{|word| [word]}}
end
