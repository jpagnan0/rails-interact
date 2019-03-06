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
    interaction['interactionPair'].select do |pair|
      pair['interactionConcept']
    end.map do |concept|
      concept['description']
    end[0]
  end

  def parse_interaction_results(res)
    json = JSON.parse(res)
    # if !!json['fullInteractionTypeGroup']
      interaction_group = json['fullInteractionTypeGroup'].select do |group|
        group['fullInteractionType']
      end.map do |group|
        group['fullInteractionType']
      end.flatten
      interaction_pairs = interaction_group.map do |interaction|
        {
          comment: interaction['comment'],
          interaction_pair: { medication_one: interaction['minConcept'][0]['rxcui'], medication_two: interaction['minConcept'][1]['rxcui'] },
          description: interaction_description(interaction)
          # interaction_pair: interaction["interactionPair"]
        }
      end
    #   {}
    # end
    interaction_pairs
  end

  def fetch_interactions_from_api
    # byebug
    user_rxcuis = @user.medications.pluck(:rxcui).join('+')
    res = RestClient.get interactions_url(user_rxcuis)
    # byebug
    @results = parse_interaction_results(res)
    # binding.pry
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
    if !@results
      return {}
    end
      @results.map do |interaction|
        # binding.pry
        {
          medication_one_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_one]).id,
          medication_two_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_two]).id,
          comment: interaction[:comment],
          description: interaction[:description]
        }

    end.flatten
  end

  def create_interactions
    if !@results
      return {}
    else
      Interaction.create(interaction_med_ids)
    end
    # interaction_med_ids
    # binding.pry
    # medication_one_id = Medication.find_by(rxcui: rxcui_one).id
    # medication_two_id = Medication.find_by(rxcui: rxcui_two).id
    # Interaction.where(:medication_one_id => interaction_med_ids[:medication_one_id], :medication_two_id => interaction_med_ids[:medication_two_id]).first_or_create do |interaction|
    #  interaction.comment = interaction_med_ids[:comment]
    #  interaction.description = interaction_med_ids[:description]
  end
  # binding.pry
  # byebug
  # Interaction.create()
end
