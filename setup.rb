require './redis_graph'
require './graph'
require './extensions/string'
require './test_operation'

g = Graph.new
n1 = g.create_node( 'PrintNode', 'some_id' )
n2 = g.create_node( 'PrintNode', 'some_id' )
n3 = g.create_node( 'PrintNode', 'some_id' )
n4 = g.create_node( 'PrintNode', 'some_id' )
g.link(n1, n2)
g.link(n1, n3)
g.link(n2, n4)
g.link(n3, n4)
RedisGraph.store(g)
