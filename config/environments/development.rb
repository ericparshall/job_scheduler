class NoCompression
   def compress(string)
     # do nothing
     string
   end
end

JobScheduler::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
#  config.assets.compress = false
  config.assets.compress = true
#  config.assets.js_compressor = NoCompression.new
  # Expands the lines which load the assets
  #config.assets.debug = true
  
  config.eager_load = false
  
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :postmark
  config.action_mailer.postmark_settings = { :api_key => '701e29bc-cabc-43ba-853b-e5248dc3a0ae' }
  config.action_mailer.default_options = {from: 'eric@parshall.us'}
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true
  config.url_host = "http://localhost:3000"
  
  config.assets.precompile += %w( angular_group.js jquery_group.js )
end
