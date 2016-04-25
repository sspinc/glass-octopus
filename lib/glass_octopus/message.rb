module GlassOctopus
  # Represents a message from a Kafka topic.
  Message = Struct.new(:topic, :partition, :offset, :key, :value)
end
