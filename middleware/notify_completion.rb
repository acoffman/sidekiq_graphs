class NotifyNodeComplete
  def call(worker_instance, params, queue)
    yield
    RedisGraph.visit_node(params['args'][0]['node_id'])
  end
end