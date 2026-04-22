require "geminabox"

Geminabox.data = "/geminabox-data"
Geminabox.rubygems_proxy = true
Geminabox.allow_remote_failure = true

username = ENV.fetch("GEMINABOX_USERNAME", "admin")
password = ENV.fetch("GEMINABOX_PASSWORD") { raise "GEMINABOX_PASSWORD is required" }

use Rack::Auth::Basic, "Geminabox" do |user, pass|
  Rack::Utils.secure_compare(user, username) &
    Rack::Utils.secure_compare(pass, password)
end

run Geminabox::Server
