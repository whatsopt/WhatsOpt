# frozen_string_literal: true

require "thrift"
require "securerandom"
require "administration"

module WhatsOpt
  class ServiceProxy
    attr_reader :id, :pid, :host, :port

    PYTHON = APP_CONFIG["python_cmd"] || "python"
    OUTDIR = File.join(Rails.root, "upload", "store")
    LOGDIR = File.join(Rails.root, "log")

    DEFAULT_HOST = "localhost"
    DEFAULT_PORT = 41400
    DEFAULT_DEV_PORT = 41401

    def initialize(id: nil, host: DEFAULT_HOST, port: DEFAULT_PORT, server_start: true)
      @host = host
      @port = if Rails.application.config.relative_url_root.to_s =~ /dev/
                DEFAULT_DEV_PORT
              else
                port
              end
      socket = Thrift::Socket.new(@host, @port)
      @transport = Thrift::BufferedTransport.new(socket)
      @protocol = Thrift::BinaryProtocol.new(@transport)

      @admin_protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "AdministrationService"
      )
      @admin_client = Services::Administration::Client.new(@admin_protocol)

      @id = id || SecureRandom.uuid

      self._initialize

      if server_start && !server_available?
        cmd = "#{PYTHON} #{File.join(Rails.root, 'services', 'run_server.py')} --outdir #{OUTDIR} --logdir #{LOGDIR} --port #{@port}"
        Rails.logger.info cmd
        @pid = spawn(cmd, [:out, :err] => File.join(Rails.root, "log", "whatsopt_server.log"))
        retries = 0
        while retries < 10 && !server_available?  # wait for server start
          retries += 1
          sleep(1)
        end
      end
    end

    def _initialize
      raise "not yet implemented"
    end

    def self.shutdown_server(host: DEFAULT_HOST, port: DEFAULT_PORT)
      socket = Thrift::Socket.new(host, port)
      transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(transport)
      admin_protocol = Thrift::MultiplexedProtocol.new(
        protocol, "AdministrationService"
      )
      client = Services::Administration::Client.new(admin_protocol)
      transport.open()
      client.shutdown
    rescue => e
      Rails.logger.warn e
    else
      transport.close()
      self.kill_server(@pid)
    end

    def self.kill_server(pid)
      if pid
        Process.kill("TERM", pid)
        Process.waitpid pid
      end
    end

    def server_available?
      _send { @admin_client.ping }
    end

    def _send
      @transport.open()
      yield
    rescue Services::SurrogateException => e
      # puts "#{e}: #{e.msg}"
      Rails.logger.warn "#{e}: #{e.msg}"
      raise
    rescue Thrift::TransportException => e
      # puts "#{e}"
      Rails.logger.warn e
      false
    else
      true
    ensure
      @transport.close()
    end
  end
end
