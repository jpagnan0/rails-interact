class User < ApplicationRecord
  has_many :user_medications
  has_many :medications, through: :user_medications
  has_many :interactions, through: :medications, source: :medication_one_interactions
  has_many :interactions, through: :medications, source: :medication_two_interactions
  # create method to find
end
