class NotifyNodeComplete
  def call(worker_instance, params, queue)
    yield
    RedisGraph.mark_node_as_completed(params['args'][0]['node_id'])
  end
end