require '~/git/sidekiq_testing/test_operation'
require '~/git/sidekiq_testing/redis_graph'
require '~/git/sidekiq_testing/graph'
require '~/git/sidekiq_testing/extensions/string'


t = Time.now
g = Graph.new

num = ARGV[0].to_i
n0 = g.create_node( 'PrintNode', 'Begin' )
nn = g.create_node( 'PrintNode', 'All done!' )
(1..num).each do |node_num|
  n2 = g.create_node( 'PrintNode', node_num )
  g.link( n0, n2 )
  g.link( n2, nn )
end

RedisGraph.store(g)
puts "#{num}\t#{Time.now - t}"

