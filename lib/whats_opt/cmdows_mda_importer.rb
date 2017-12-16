require 'nokogiri'
require 'whats_opt/mda_importer'

module WhatsOpt 
    
  class CmdowsMdaImporter < MdaImporter
  
    class CmdowsValidationError < StandardError
    end
    
    class ImportError < StandardError
    end
    
    SCHEMA_FILE = File.join(File.dirname(__FILE__), 'cmdows.xsd')
    XSD = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
    
    def initialize(filename)
      @filename = filename
      @doc = Nokogiri::XML(filename)
      XSD.validate(@doc).each do |error|
        raise CmdowsValidationError.new(error.message)
      end
    end
    
    def get_mda_attributes
      return {name: @filename.camelcase}
    end 
    
    def get_disciplines_attributes
      @doc.xpath('/cmdows//designcompetence') do |dc|
        p dc
      end
    end
    
    def get_variables_attributes
    end
    
  end
end