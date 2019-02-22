class Interaction < ApplicationRecord
  belongs_to :medication_one, class_name: "Medication"
  belongs_to :medication_two, class_name: "Medication"
end
