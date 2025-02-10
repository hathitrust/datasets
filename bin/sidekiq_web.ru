require "rack/session"
require "securerandom"
require "sidekiq/web"
require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

secret_key = SecureRandom.hex(32)

use Rack::Session::Cookie, secret: secret_key, same_site: true, max_age: 86400

run Sidekiq::Web
