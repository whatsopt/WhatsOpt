class RenameMdaInAttachmentsAndRoles < ActiveRecord::Migration[5.1]
  def up
    Attachment.all.each do |attach|
      if attach.container_type == 'MultiDisciplinaryAnalysis'
        attach.update_column :container_type, 'Analysis'
      end  
    end
    Role.all.each do |role|
      if role.resource_type == 'MultiDisciplinaryAnalysis'
        role.update_column :resource_type, 'Analysis'
      end  
    end
  end
  
  def down
    Attachment.all.each do |attach|
      if attach.container_type == 'Analysis'
        attach.update_column :container_type, 'MultiDisciplinaryAnalysis'
      end  
    end    
    Role.all.each do |role|
      if role.resource_type == 'Analysis'
        role.update_column :resource_type, 'MultiDisciplinaryAnalysis'
      end  
    end
  end
end
