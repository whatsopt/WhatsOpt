require 'nokogiri'
require 'whats_opt/mda_importer'

module WhatsOpt 
    
  class CmdowsMdaImporter < MdaImporter
  
    class CmdowsValidationError < MdaImportError
    end
    
    SCHEMA_FILE = File.join(File.dirname(__FILE__), 'cmdows.xsd')
    XSD = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
    
    def initialize(filename, mda_name=nil)
      @filename = filename
      @mda_name = mda_name || File.basename(@filename, '.cmdows')
      @doc = Nokogiri::XML(File.read(filename))
      XSD.validate(@doc).each do |error|
        raise CmdowsValidationError.new(error.message)
      end
    end
    
    def get_mda_attributes
      {name: @mda_name}
    end 
    
    def get_disciplines_attributes
      discattrs = []
      disc_ids = @doc.xpath('//designCompetence/@uID').map(&:content)
      disc_ids.each do |duid|
        label = @doc.xpath('//designCompetence[@uID="'+duid+'"]/label') 
        discattrs << { id: duid, name: label.text }
      end
      unless discattrs.detect{|d| d['name'] == WhatsOpt::Discipline::DRIVER_NAME}
        discattrs.unshift({name: WhatsOpt::Discipline::DRIVER_NAME})
      end
      discattrs
    end
    
    def get_variables_attributes
      varattrs = {}
      disc_ids = @doc.xpath('//designCompetence/@uID').map(&:content)
      input_params_ids = []
      output_params_ids = []
      disc_ids.each do |duid|
        base = '//designCompetence[@uID="'+duid+'"]'
        input_params_ids = @doc.xpath(base+'/inputs/input/parameterUID').map(&:text)
        output_params_ids = @doc.xpath(base+'/outputs/output/parameterUID').map(&:text)
        varattrs[duid] = []
        input_params_ids.each do |pid|
          label = @doc.xpath('//parameters/parameter[@uID="'+pid+'"]/label').text
          varattrs[duid] << {name: label, :shape=>"1", :type=>"Float", :units=>"", :desc=>"", io_mode: "in"}
        end
        output_params_ids.each do |pid|
          label = @doc.xpath('//parameters/parameter[@uID="'+pid+'"]/label').text
          varattrs[duid] << {name: label, :shape=>"1", :type=>"Float", :units=>"", :desc=>"", io_mode: "out"}
        end
      end
      unless varattrs.key?(WhatsOpt::Discipline::DRIVER_NAME)
        varattrs[WhatsOpt::Discipline::DRIVER_NAME]=[]
      end
      varattrs
    end
    
  end
end