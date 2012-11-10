require '~/git/sidekiq_testing/test_operation'
require '~/git/sidekiq_testing/redis_graph'
require '~/git/sidekiq_testing/graph'
require '~/git/sidekiq_testing/extensions/string'


[10, 50, 100, 500, 1000, 5000, 10_000, 50_000, 100_000, 500_000].each do |num|
  t = Time.now
  g = Graph.new

  n1 = g.create_node( 'PrintNode', 0 )
  (1..num).each do |node_num|
    n2 = g.create_node( 'PrintNode', node_num )
    g.link( n1, n2 )
    n1 = n2
  end
  RedisGraph.store(g)
  puts "#{num}\t#{Time.now - t}"
end

