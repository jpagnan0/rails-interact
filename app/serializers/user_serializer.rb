class UserSerializer < ActiveModel::Serializer
  attributes :id, :username
  has_many :medications
  has_many :interactions
end
