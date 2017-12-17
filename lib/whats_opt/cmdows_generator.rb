require 'nokogiri'

class WhatsOpt::CmdowsGenerator

  class CmdowsValidationError < StandardError
  end
  
  SCHEMA_FILE = File.join(File.dirname(__FILE__), 'cmdows.xsd')
  XSD = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
  
  def initialize(mda)
    @mda = mda
    _build
  end
  
  def generate
    doc = @builder.doc
    XSD.validate(doc).each do |error|
      raise CmdowsValidationError.new(error.message)
    end
    filename = "#{@mda.file_basename}.cmdows"
    return doc.to_xml, filename 
  end
  
  def _build
    @builder = Nokogiri::XML::Builder.new do |xml|
      xml.cmdows do
        _generate_header(xml)
        xml.executableBlocks do
          xml.designCompetences do
            _generate_design_competences(xml)
          end
        end
        xml.parameters do
          _generate_parameters(xml)
        end
      end
    end
  end
  
  def _generate_header(xml)
    xml.header do
      xml.creator @mda.owner
      xml.description @mda.name
      xml.timestamp DateTime.now
      xml.fileVersion "1.0"
      xml.cmdowsVersion "0.7"
    end
  end
  
  def _generate_design_competences(xml) 
    @mda.disciplines.analyses.each do |disc|
      xml.designCompetence uID: disc.id do
        xml.ID disc.id
        xml.modeID "undefined"
        xml.instanceID "#{disc.name}-#{disc.id}"
        xml.version "undefined"
        xml.label disc.name
        _generate_inputs_outputs(xml, disc)
      end
    end
  end
    
  def _generate_inputs_outputs(xml, disc)
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
  
  def _generate_parameters(xml)
    vars = {}
    @mda.disciplines.each do |d|
      d.variables.each do |v|
        vars[v.name] = v
      end
    end
    vars.each do |name, var|
      xml.parameter uID: name do |xml|
        xml.label name
      end
    end  
  end
  
end