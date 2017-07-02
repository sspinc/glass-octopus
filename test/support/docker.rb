module Docker
  module_function

  def kafka_0_10_host
    "#{docker_machine_ip}:#{kafka_0_10_port}"
  end

  def kafka_0_10_port
    "9093"
  end

  def kafka_0_8_host
    "#{docker_machine_ip}:#{kafka_0_8_port}"
  end

  def kafka_0_8_port
    "9092"
  end

  def zookeeper_host
    "#{docker_machine_ip}:#{zookeeper_port}"
  end

  def zookeeper_port
    "2181"
  end

  def docker_machine_ip
    @docker_ip ||= begin
                     active = %x{docker-machine active}.chomp
                     %x{docker-machine ip #{active}}.chomp
                   end
  end
end
