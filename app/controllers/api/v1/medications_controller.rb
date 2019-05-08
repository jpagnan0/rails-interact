class Api::V1::MedicationsController < ApplicationController
  def index
    @medications = Medication.all
    render json: @medications
  end
  def create
    # byebug
    m=Medication.find_or_create_by({rxcui: params[:rxcui], name: params[:name], name_alt: params[:name_alt]})
    UserMedication.find_or_create_by( medication_id: m.id, user_id: params[:id])
    # binding.pry
    render json: User.find(params[:id]).medications
  end

end
