module GlassOctopus
  class OptionsInvalid < StandardError
    attr_reader :errors

    def initialize(errors)
      super("Invalid consumer options: #{errors.join(", ")}")
      @errors = errors
    end
  end
end
