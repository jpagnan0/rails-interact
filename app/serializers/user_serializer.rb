class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username
  #has_many :medications
  #has_many :interactions
end
