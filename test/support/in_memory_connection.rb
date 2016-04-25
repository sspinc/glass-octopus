class InMemoryConnection
  def initialize(messages=[])
    @messages = messages
  end

  def fetch_message(&block)
    @messages.each(&block)
  end

  def close
  end
end
