# -*- encoding: utf-8 -*-
require File.expand_path('../lib/resque_queue_control/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Arthur Gunawan"]
  gem.email         = ["acgun3@gmail.com"]
  gem.summary       = %q{A resque plugin that allows greater control over queues.}
  gem.homepage      = "https://github.com/agunawan/resque-queue-control"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "resque-queue-control"
  gem.require_paths = ["lib"]
  gem.version       = Resque::QueueControl::VERSION

  gem.add_dependency 'resque', '~> 1.20'
  gem.add_development_dependency 'mock_redis'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.description   = <<desc
A resque plugin that allows greater control over queues.

Built from the work done in the resque-pause and resque-lonely_job gems.

Example:

  require 'resque/plugins/queue_control'

  class QueueControlJob
    extend Resque::Plugins::QueueControl

    def self.perform(*args)

    end
  end
desc
end
