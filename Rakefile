require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = ENV.key?("VERBOSE")
  t.warning = false
end

namespace :test do
  desc "Run all tests including integration tests"
  task :all do
    ENV["TEST_KAFKA_INTEGRATION"] = "yes"
    Rake::Task[:test].invoke
  end
end

namespace :docker do
  require "socket"

  desc "Start docker containers"
  task :up do
    start
    wait(9093)
    docker_compose("run --rm kafka_0_10 kafka-topics.sh --zookeeper zookeeper --create --topic test_topic --replication-factor 1 --partitions 1")
    wait(9092)
    docker_compose("run --rm kafka_0_8 bash -c '$KAFKA_HOME/bin/kafka-topics.sh --zookeeper kafka_0_8 --create --topic test_topic --replication-factor 1 --partitions 1'")
  end

  desc "Stop and remove docker containers"
  task :down do
    docker_compose("down")
  end

  desc "Reset docker containers"
  task :reset => [:down, :up]

  def start
    docker_compose("up -d")
  end

  def stop
    docker_compose("down")
  end

  def docker_compose(args)
    env = {
      "ADVERTISED_HOST"          => docker_machine_ip,
      "KAFKA_0_8_EXTERNAL_PORT"  => "9092",
      "KAFKA_0_10_EXTERNAL_PORT" => "9093",
      "ZOOKEEPER_EXTERNAL_PORT"  => "2181",
    }
    system(env, "docker-compose #{args}")
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

  def wait(port)
    Socket.tcp(docker_machine_ip, port, connect_timeout: 5).close
  rescue Errno::ECONNREFUSED
    puts "waiting for #{docker_machine_ip}:#{port}"
    sleep 1
    retry
  end
end
