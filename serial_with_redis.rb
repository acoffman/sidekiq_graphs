require '~/git/sidekiq_testing/test_operation'
require '~/git/sidekiq_testing/redis_graph'
require '~/git/sidekiq_testing/graph'
require '~/git/sidekiq_testing/extensions/string'

number_of_nodes = ARGV[0].to_i

g = Graph.new

n1 = g.create_node( 'PrintNode', 0 )
(1..number_of_nodes).each do |node_num|
  n2 = g.create_node( 'PrintNode', node_num )
  g.link( n1, n2 )
  n1 = n2
end
RedisGraph.store(g)
