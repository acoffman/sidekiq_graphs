require 'redis'

class RedisGraph

  def self.store( graph )
    redis.pipelined do
      graph.nodes.each do |node|

        edges_id = edges_id_for_node_id( node.id )
        indegree_id = indegree_id_for_node_id( node.id )

        #add each edge to the set of outbound edges
        #for this node
        graph.edges[node.id].each do |edge|
          redis.sadd( edges_id, edge )
        end

        #set up the indegree counter
        redis.incrby( indegree_id, node.indegree )

        #store the ids for the indegree counter and edges set in the node
        redis.hset( node.id, 'edges', edges_id )
        redis.hset( node.id, 'indegree', indegree_id )

        #store any aribtrary attributes on the node
        Node.node_attrs.each do |attr|
          redis.hset( node.id, attr, node.send( attr ) )
        end
      end
    end
  end

  def self.delete_graph( graph )
    redis.del( graph.nodes.flat_map do |node|
      [node.id, edges_id_for_node_id( node.id ), indegree_id_for_node_id( node.id)]
    end )
  end

  def self.delete_node( node )
    keys = [node.id, edges_id_for_node_id( node.id ), indegree_id_for_node_id( node.id)]
    redis.del(keys)
  end

  def self.mark_node_as_completed( node_id )
    edges = redis.smembers( edges_id_for_node_id( node_id ) )
    #'edges' are node_ids
    edges.each { |edge| visit_node( edge ) }
  end

  def self.fetch_node( node_id )
    attributes = redis.hgetall( node_id )
    edges = redis.smembers( attributes['edges'] )
  end

  def self.visit_node( node_id )
      #decrement the indegree of the node
      remaining_indegree = redis.decr( indegree_id_for_node_id( edge ) )
      if remaining_indegree == 0
        #create a new instance of the node's worker class and queue it up as 'ready'
        worker = StringHelpers.constantize( redis.hget(node_id, 'worker_class') ).new
        arg = redis.hget( node_id, 'workflow_identifier' )
        worker.perform_async( arg )
      end
  end

  private
    def self.edges_id_for_node_id( node_id )
      "#{node_id}:edges"
    end

    def self.indegree_id_for_node_id( node_id )
      "#{node_id}:indegree"
    end

    def self.redis
      @redis ||= Redis.new( host: 'localhost', port: 6379 )
    end

end
