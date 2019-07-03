require 'thrift'
require_relative 'surrogate_server/surrogate_store'

module WhatsOpt
  class SurrogateProxy

    def initialize(surrogate_id, host='localhost', port=41400)
      socket = Thrift::Socket.new('localhost', 41400)
      @transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(@transport)
      @client = SurrogateServer::SurrogateStore::Client.new(protocol)
    
      @surrogate_id = surrogate_id
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
        print e 
      end
      @transport.close()
    end

  end
end