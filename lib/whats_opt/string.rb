module WhatsOpt
  
  refine String do
    def snakize
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr('-.', '_').
      gsub(/\s/, '_').
      gsub(/__+/, '_').
      downcase
    end
  end
  
end