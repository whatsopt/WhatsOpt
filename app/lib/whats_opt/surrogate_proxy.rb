require 'thrift'
require 'securerandom'
require_relative 'surrogate_server/surrogate_store'

module WhatsOpt
  class SurrogateProxy

    attr_reader :surrogate_id, :pid, :host, :port

    PYTHON = APP_CONFIG["python_cmd"] || "python"
    OUTDIR = File.join(Rails.root, 'upload', 'surrogate_store')

    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 41400

    def initialize(surrogate_id: nil, host: DEFAULT_HOST, port: DEFAULT_PORT, server_start: true)
      @host = host
      @port = port
      socket = Thrift::Socket.new(@host, @port)
      @transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(@transport)
      @client = SurrogateServer::SurrogateStore::Client.new(protocol)
    
      @surrogate_id = surrogate_id || SecureRandom.uuid

      if server_start && !server_available?
        @pid = spawn("#{PYTHON} #{File.join(Rails.root, 'surrogate_server', 'run_surrogate_server.py')} --outdir #{OUTDIR}", 
                     [:out, :err] => File.join(Rails.root, 'upload', 'logs', 'surrogate_server.log'))
        retries = 0
        while retries < 5 && !server_available?  # wait for server start
          retries += 1
          sleep(1)
        end
      end
    end

    def server_available?
      _send { @client.ping }
    end

    def self.shutdown_server(host: DEFAULT_HOST, port: DEFAULT_PORT)
      socket = Thrift::Socket.new(host, port)
      transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(transport)
      client = SurrogateServer::SurrogateStore::Client.new(protocol)
      transport.open()
      client.shutdown
    rescue => e
      Rails.logger.warn e
      false
    else
      true
    ensure
      transport.close()
    end

    def self.kill_server(pid)
      if pid
        Process.kill("TERM", pid)
        Process.waitpid pid
      end      
    end

    def create_surrogate(surrogate_kind, x, y)
      _send { @client.create_surrogate(@surrogate_id, surrogate_kind, x, y) }
    end

    def predict_values(x)
      values = []
      _send { 
        values = @client.predict_values(@surrogate_id, x) 
      }
      values
    end

    def destroy_surrogate()
      _send { @client.destroy_surrogate(@surrogate_id) }
    end

    def _send 
      @transport.open()
      yield
    rescue SurrogateServer::SurrogateException => e
      #puts "#{e}: #{e.msg}"
      Rails.logger.warn "#{e}: #{e.msg}"
      raise
    rescue Thrift::TransportException => e
      #puts "#{e}"
      Rails.logger.warn e
      false
    else
      true
    ensure
      @transport.close()
    end

  end
end