class AddDefaultJobToExistingOperations < ActiveRecord::Migration[5.2]
  def up
    Operation.includes(:cases).where(job: nil).each do |ope|
      if ope.cases.empty?
        say "Create pending job for #{ope.name}"
        ope.create_job(status: 'PENDING', pid: -1, log: "")
      else
        say "Create done job for #{ope.name}"
        ope.create_job(status: 'DONE', pid: -1, log: "wop upload...\nData uploaded")
      end
    end
  end
  
  def down
  end
end
