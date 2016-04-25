module GlassOctopus
  module Middleware
    autoload :ActiveRecord, "glass_octopus/middleware/active_record"
    autoload :CommonLogger, "glass_octopus/middleware/common_logger"
    autoload :JsonParser, "glass_octopus/middleware/json_parser"
    autoload :Mongoid, "glass_octopus/middleware/mongoid"
    autoload :NewRelic, "glass_octopus/middleware/new_relic"
    autoload :Sentry, "glass_octopus/middleware/sentry"
  end
end
