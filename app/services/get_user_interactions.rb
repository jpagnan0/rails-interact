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

  def names(interaction)
    c = []
    interaction['interactionPair'].select do |pair|
      pair['interactionConcept'].map do |concept|
        c << concept['minConceptItem']['name']
      end
    end
    c
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
          description: interaction_description(interaction),
          name_one: names(interaction)[0],
          name_two: names(interaction)[1]
        }
      end
    interaction_pairs
  end

  def fetch_interactions_from_api
    user_rxcuis = @user.medications.pluck(:rxcui).join('+')
    res = RestClient.get interactions_url(user_rxcuis)
    @results = parse_interaction_results(res)
  end

  def interaction_med_ids
    if !@results
      return {}
    end
      @results.map do |interaction|
        {
          medication_one_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_one]).id,
          medication_two_id: Medication.find_by(rxcui: interaction[:interaction_pair][:medication_two]).id,
          comment: interaction[:comment],
          description: interaction[:description],
          name_one: interaction[:name_one],
          name_two: interaction[:name_two]
        }

    end.flatten
  end

  def create_interactions
    # if !@results
    #   []
    # else
    #   Interaction.create(interaction_med_ids) unless @results
    # end
    if !@results
      return {}
    else
      Interaction.create(interaction_med_ids)
    end

  end

end
