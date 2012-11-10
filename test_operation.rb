require 'sidekiq'

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'x', :size => 1, :url => 'redis://localhost:6379' }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'x', :url => 'redis://localhost:6379' }
end

class PrintNode
  include Sidekiq::Worker

  def perform( msg )
    puts "I'm running: #{msg}"
  end
end
