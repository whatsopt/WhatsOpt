class Connection < ApplicationRecord  
  belongs_to :from, class_name: 'Variable'
  belongs_to :to, class_name: 'Variable'
end
