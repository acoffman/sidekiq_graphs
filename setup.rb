require '~/git/sidekiq_testing/redis_graph'
require '~/git/sidekiq_testing/graph'
require '~/git/sidekiq_testing/extensions/string'
g = Graph.new
n1 = g.create_node( 'test', 'some_id' )
n2 = g.create_node( 'test', 'some_id' )
n3 = g.create_node( 'test', 'some_id' )
n4 = g.create_node( 'test', 'some_id' )
g.link(n1, n2)
g.link(n1, n3)
g.link(n2, n4)
g.link(n3, n4)
RedisGraph.store(g)
