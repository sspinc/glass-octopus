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
    return @docker_ip if defined? @docker_ip

    if ENV.key?("ADVERTISED_HOST")
      @docker_ip = ENV["ADVERTISED_HOST"]
    else
      active = %x{docker-machine active}.chomp
      @docker_ip = %x{docker-machine ip #{active}}.chomp
    end
  end
end
