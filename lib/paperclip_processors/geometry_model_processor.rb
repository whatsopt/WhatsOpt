require 'whats_opt/openvsp_geometry_converter'

module Paperclip
  class GeometryModelProcessor < Processor

    def make
      @converter = WhatsOpt::OpenvspGeometryConverter.new(@file, {:format => :x3d})
      @converter.convert
    end

  end
end
