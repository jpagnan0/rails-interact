class Api::V1::InteractionsController < ApplicationController
  def index
    @interactions = Interaction.all
    render json: @interactions
  end
end
