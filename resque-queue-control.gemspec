# -*- encoding: utf-8 -*-
require File.expand_path('../lib/resque_queue_control/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Arthur Gunawan"]
  gem.email         = ["acgun3@gmail.com"]
  gem.summary       = %q{A resque plugin that allows greater control over queues.}
  gem.homepage      = "https://github.com/agunawan/resque_queue_control"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "resque_queue_control"
  gem.require_paths = ["lib"]
  gem.version       = Resque::Plugins::QueueControl::VERSION

  gem.add_dependency 'resque', '~> 1.20'
  gem.add_development_dependency 'mock_redis'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.description   = <<desc
A resque plugin that allows greater control over queues.

Example:

  require 'resque/plugins/lonely_job'

  class StrictlySerialJob
    extend Resque::Plugins::QueueControl

    @queue = :serial_work

    def self.perform
      # only one at a time in this block, no parallelism allowed for this
      # particular queue
    end
  end
desc
end
