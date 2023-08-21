# frozen_string_literal: true

require "tempfile"

class WhatsOpt::AnalysisDiff
  def self.compare(mda1, mda2)
    mda1_file = Tempfile.new("#{mda1.impl.basename}_#{mda1.id}__")
    str1 = JSON.pretty_generate(AnalysisDiffSerializer.new(mda1).as_json)
    mda1_file.write(str1)
    mda1_file.flush
    mda2_file = Tempfile.new("#{mda2.impl.basename}_#{mda2.id}__")
    str2 = JSON.pretty_generate(AnalysisDiffSerializer.new(mda2).as_json)
    mda2_file.write(str2)
    mda2_file.flush
    res = `diff --unified=100 #{mda1_file.path} #{mda2_file.path}`
    res
ensure
  mda1_file.close
  mda1_file.unlink
  mda2_file.close
  mda2_file.unlink
  end
end
