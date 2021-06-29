# frozen_string_literal: true

require 'tempfile'

class WhatsOpt::AnalysisDiff

    def self.compare(mda1, mda2)
        mda1_file = Tempfile.new("#{mda1.basename}_#{mda1.id}")
        str1 = JSON.pretty_generate(AnalysisDiffSerializer.new(mda1).as_json)
        mda1_file.write(str1)
        mda1_file.flush
        mda2_file = Tempfile.new("#{mda2.basename}_#{mda2.id}")
        str2 = JSON.pretty_generate(AnalysisDiffSerializer.new(mda2).as_json)
        mda2_file.write(str2)
        mda2_file.flush
        res = `diff -u #{mda1_file.path} #{mda2_file.path}`
        res
    ensure 
        mda1_file.close
        mda2_file.close
    end

end