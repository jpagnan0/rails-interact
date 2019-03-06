class Api::V1::UserMedicationsController < ApplicationController
  # def index
  #   @user_medications = RxNav.search_medication(params[:medication_name])
  #   render json: @search_results
  # end
  def index
    @user_meds = UserMedication.all
    render json: @user_meds
  end
  def create
    # byebug
    m=Medication.find_or_create_by({rxcui: user_medications_params[:rxcui], name:user_medications_params[:name], name_alt: user_medications_params[:name_alt]})
    UserMedication.find_or_create_by( medication_id: m.id, user_id: user_medications_params[:user_id])
    @user_meds = User.find_by(id: user_medications_params[:user_id]).medications
    render json: @user_meds
  end


  # private
  def user_medications_params
    params.permit(:rxcui, :name, :name_alt, :user_id)
  end
end
