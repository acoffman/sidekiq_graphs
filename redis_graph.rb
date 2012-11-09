require 'redis'
require 'pry'
require 'pry-nav'
require 'pry-remote'

class RedisGraph

  def self.store( graph )
    redis.pipelined do
      graph.nodes.values.each do |node|
        edges_id = edges_id_for_node_id( node.id )
        graph.edges[node.id].each do |edge|
          redis.sadd( edges_id, edge )
        end
        redis.hset( node.id, 'edges', edges_id )
        node_attrs.each do |attr|
          redis.hset( node.id, attr, node.send( attr ) )
        end
      end
    end
  end

  def self.mark_node_as_completed( node_id )
    edges = redis.smembers( edges_id_for_node_id( node_id ) )
    edges.each do |edge|

    end
  end

  def self.fetch_node( node_id )
    attributes = redis.hgetall( node_id )
    edges = redis.smembers( attributes['edges'] )
  end

  def self.visit_node( node_id )
  end

  private
    def self.edges_id_for_node_id( node_id )
      "#{node_id}:edges"
    end

    def self.redis
      @redis ||= Redis.new( host: 'localhost', port: 6379 )
    end

    def self.node_attrs
      ['indegree', 'worker_class', 'workflow_identifier']
    end
end
