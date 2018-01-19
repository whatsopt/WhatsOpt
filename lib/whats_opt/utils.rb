require 'yaml'

module WhatsOpt
  
  def shape_of str
    if str =~ /\[(.*)\]/
      ary = YAML.load(str)
      "(#{ary.size},#{_dim(ary.first)})"
    else
      "1" 
    end  
  end 
     
  def _dim ary 
    if ary.is_a? Array
      res = "#{ary.size}"
      sub = _dim(ary.first)
      unless sub.blank?
        res += ",#{sub}"
      end
      res
    else
      ""
    end
  end
  
end