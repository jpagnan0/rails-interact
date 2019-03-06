class GetUserInteractions
  attr_reader :user, :results

  def initialize(user)
    @user = user
  end

  def execute
    fetch_interactions_from_api
    create_interactions
  end

  # private
  def interactions_url(user_rxcuis)
    url = "https://rxnav.nlm.nih.gov/REST/interaction/list.json?rxcuis=#{user_rxcuis}"
    url
  end

  def interaction_description(interaction)
    interaction["interactionPair"].select do |pair|
      pair["interactionConcept"]
    end.map do |concept|
      concept["description"]
    end[0]
  end

  def parse_interaction_results(res)
    interaction_group=JSON.parse(res)["fullInteractionTypeGroup"].select do |group|
      group["fullInteractionType"]
    end.map do |group|
      group["fullInteractionType"]
    end.flatten
    interaction_pairs = interaction_group.map do |interaction|
      {
        comment: interaction["comment"],
        interaction_pair: {medication_one: interaction["minConcept"][0]["rxcui"], medication_two: interaction["minConcept"][1]["rxcui"]},
        description: interaction_description(interaction),
        # interaction_pair: interaction["interactionPair"]
      }
    end
    interaction_pairs
  end

  def fetch_interactions_from_api
    # byebug
    user_rxcuis=@user.medications.pluck(:rxcui).join("+")
    res = RestClient.get interactions_url(user_rxcuis)
    # byebug
    @results = parse_interaction_results(res)

    # JSON.parse(res)["fullInteractionTypeGroup"]
    # interaction_group = @results.select do |group|
    #   group["fullInteractionType"]
    # end.map do |group|
    #   group["fullInteractionType"]
    # end.flatten

    # render json: @results
  end

  # def rxcui_one
  #   rxcui=nil
  #   @results.select do |interaction|
  #     rxcui=interaction[:interaction_pair][:medication_one]
  #   end
  #   rxcui
  # end
  #
  # def rxcui_two
  #   rxcui=nil
  #   @results.select do |interaction|
  #     rxcui=interaction[:interaction_pair][:medication_two]
  #   end
  #   rxcui
  # end

  def interaction_med_ids
    @results.map do |interaction|
      {
        comment: interaction[:comment],
        description: interaction[:description],
        medication_one_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_one]).id ,
        medication_two_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_two]).id
      }
    end
  end

  def create_interactions
    binding.pry

    # medication_one_id = Medication.find_by(rxcui: rxcui_one).id
    # medication_two_id = Medication.find_by(rxcui: rxcui_two).id
    Interaction.create(interaction_med_ids)
    # binding.pry
    # byebug
    # Interaction.create()
  end
end
