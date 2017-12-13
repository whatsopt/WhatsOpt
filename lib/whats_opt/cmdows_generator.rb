require 'nokogiri'

class WhatsOpt::CmdowsGenerator

  SCHEMA_FILE = File.join(File.dirname(__FILE__), 'cmdows.xsd')
  XSD = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
  
  def initialize(mda)
    @mda = mda
    _build
  end
  
  def generate
    doc = @builder.doc
    XSD.validate(doc).each do |error|
      puts error.message
    end 
  end
  
  
  def _build
    @builder = Nokogiri::XML::Builder.new do |xml|
      xml.cmdows do
        xml.header
        xml.executableBlocks do
          xml.designCompetences do
            _generate_design_competences(xml)
          end
        end
      end
    end
  end
  
  def _generate_design_competences(xml) 
    @mda.disciplines.each do |disc|
      xml.designCompetence uID: disc.id do
        xml.label disc.name
        _generate_parameters(xml, disc)
      end
    end
  end
  
  def _generate_parameters(xml, disc)
    xml.inputs do
      disc.input_variables.each do |ivar|
        xml.input do
          xml.parameterUID ivar.name
        end
      end
    end
    xml.outputs do
      disc.output_variables.each do |ivar|
        xml.output do
          xml.parameterUID ivar.name
        end
      end
    end
  end
  
end