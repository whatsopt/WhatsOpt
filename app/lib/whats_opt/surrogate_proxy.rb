require 'thrift'
require 'securerandom'
require_relative 'surrogate_server/surrogate_store'

module WhatsOpt
  class SurrogateProxy

    cattr_reader :pid 
    attr_reader :surrogate_id

    PYTHON = APP_CONFIG["python_cmd"] || "python"
    OUTDIR = File.join(Rails.root, 'upload', 'surrogate_store')

    def initialize(surrogate_id: nil, host: 'localhost', port: 41400, server_start: true)
      socket = Thrift::Socket.new('localhost', 41400)
      @transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(@transport)
      @client = SurrogateServer::SurrogateStore::Client.new(protocol)
    
      @surrogate_id = surrogate_id || SecureRandom.uuid

      if server_start && !server_available?
        @@pid = spawn("#{PYTHON} #{File.join(Rails.root, 'surrogate_server', 'run_surrogate_server.py')} --outdir #{OUTDIR}", 
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

    def self.kill_server
      if @@pid
        Process.kill("TERM", @@pid)
        Process.waitpid @@pid
        @@pid = nil
      end      
    end

    def shutdown_server
      _send { @client.shutdown }
      SurrogateProxy.kill_server
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
      begin
        @transport.open()
        yield
      rescue => e
        #puts e
        Rails.logger.warn e
        false
      else
        true
      ensure
        @transport.close()
      end
    end

  end
end