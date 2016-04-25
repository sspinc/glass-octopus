require "delegate"

module GlassOctopus
  class EnvWrapper < SimpleDelegator
    def array(key, default: [], delim: ",")
      if value = self[key]
        value.split(delim)
      else
        default
      end
    end

    def integer(key, default: nil)
      Integer(fetch(key, default))
    end

    def boolean(key, default: nil)
      case value = self[key]
      when nil then default
      when "1", "on", "y", "yes", "t", "true" then true
      else false
      end
    end
  end

  ENV = EnvWrapper.new(::ENV)
end
