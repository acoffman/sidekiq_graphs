require 'sidekiq'
require 'redis'
require 'pry'
require 'pry-nav'
require 'pry-remote'

class TestMiddleware
  def call(*args)
    puts "Hi, I'm middleware"
    yield
  end
end

# If your client is single-threaded, we just need a single connection in our $REDIS connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'x', :size => 1, :url => 'redis://localhost:6379' }
end

# Sidekiq server is multi-threaded so our $REDIS connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'x', :url => 'redis://localhost:6379' }
  config.server_middleware do |chain|
    chain.add TestMiddleware
  end
end

$REDIS = Redis.new(host: 'localhost', port: 6379) # Start up sidekiq via

module Convergable

  def self.included( base )
    base.class_eval do
      alias_method :perform_original, :perform

      def perform( *args )
        perform_original( *args[0..-2] )
        converge( args[-1] )
      end
    end
  end


  def converge( parallel_key )
    remaining_count = $REDIS.decr( parallel_key )
    puts "\n#{remaining_count} jobs to go!\n"
    if remaining_count == 0
      $REDIS.del( parallel_key )
      next_job
    end
  end

  def next_job
    raise "You must implement next_job"
  end

end

class StartParallel
  include Sidekiq::Worker

  def perform( count )
    parallel_key = "abcdef"
    count.times do |x|
      $REDIS.incr( parallel_key )
      SleepOne.perform_async( x, parallel_key )
    end
  end
end

class FinishParallel
  include Sidekiq::Worker

  def perform( message )
    puts message
  end
end

class SleepOne
  include Sidekiq::Worker

  def perform( id )
    #sleep 1
    puts "\nJob ##{id}\n"
  end

  def next_job
    FinishParallel.perform_async( "All done!" )
  end

  include Convergable
end
