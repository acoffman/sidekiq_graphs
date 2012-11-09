require 'uuid'
require 'set'

class Graph
  attr_reader :id, :nodes, :edges
  @@uuid = UUID.new

  def initialize( id = @@uuid.generate)
    @id = id
    @node_counter = 0
    @nodes = {}
    @edges = Hash.new {|h, k| h[k] = Set.new }
  end

  def create_node( worker_class, workflow_identifier )
    Node.new(@node_counter, @id, worker_class, workflow_identifier).tap do |node|
      @nodes[node.id] = node
      @node_counter += 1
    end
  end

  def link( parent, child )
    child.indegree += 1 if @edges[parent.id].add?( child.id )
  end

end

class Node
  attr_reader :id, :worker_class, :workflow_identifier
  attr_accessor :indegree

  def initialize( node_num, graph_id, worker_class, workflow_identifier, indegree = 0 )
    @id = "#{graph_id}:#{node_num}"
    @node_num = node_num
    @graph_id = graph_id
    @worker_class = worker_class
    @workflow_identifier = workflow_identifier
    @indegree = indegree
  end

end
