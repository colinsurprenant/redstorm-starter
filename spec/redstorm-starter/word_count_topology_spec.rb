require 'java'
require 'spec_helper'
require 'redstorm-starter/word_count_topology'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'
java_import 'backtype.storm.testing.MkClusterParam'
java_import 'backtype.storm.testing.TestJob'
java_import 'backtype.storm.testing.MockedSources'
java_import 'backtype.storm.testing.CompleteTopologyParam'

describe WordCountTopology do

  it "should run topology" do
    cluster_param = MkClusterParam.new
    cluster_param.set_supervisors(2)
    conf = Backtype::Config.new
    # conf.put(Backtype::Config.STORM_LOCAL_MODE_ZMQ, false)
    # conf.put(Backtype::Config.SUPERVISOR_ENABLE, false)
    conf.put(Backtype::Config.TOPOLOGY_ACKER_EXECUTORS, 0)
    cluster_param.set_daemon_conf(conf)

    TestJob.new.tap do |job|
      def job.run(cluster)
        topology = WordCountTopology.build_topology

        mocked_sources = MockedSources.new
        mocked_sources.add_mock_data("random_sentence_spout", Values.new("just a test  sentence   test"))

        conf = Backtype::Config.new
        conf.set_num_workers(2)

        param = CompleteTopologyParam.new
        param.set_mocked_sources(mocked_sources)
        param.set_storm_conf(conf)

        result = Testing.complete_topology(cluster, topology, param)
        sleep(1) # seems to solve the FileNotFoundException, see https://github.com/nathanmarz/storm/issues/356

        result_tuples(result, "random_sentence_spout").should == [["just a test  sentence   test"]]
        result_tuples(result, "split_sentence_bolt").should == [["just"], ["a"], ["test"], ["sentence"], ["test"]]
        # below tuple order is unknown, sort to compare
        result_tuples(result, "word_count_bolt").sort.should == [["just", 1], ["a", 1], ["test", 1], ["sentence", 1], ["test", 2]].sort
      end

      Testing.with_local_cluster(cluster_param, job)
    end

  end
end
