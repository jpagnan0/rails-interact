class RxNav

  def self.rxnav_url
    url = 'https://rxnav.nlm.nih.gov/REST/drugs.json'
    url
  end

  def self.parse_search_results(res)
    medication_result = JSON.parse(res)["drugGroup"]["conceptGroup"] #[1]["conceptProperties"]
    medication_group = medication_result.select do |group|
      group["conceptProperties"]
      # group.keys.length <= 1
    end.map do |group|
      group["conceptProperties"]
    end.flatten

    # binding.pry
    # medication_group.select! do |h|
    #   if h.keys.length <= 1
    #     # binding.pry
    #   end
    # end
    medication_info = medication_group.map do |info|
      {
        name_alt: info["synonym"],
        rxcui: info["rxcui"],
        name: info["name"]
      }
      # h.filter do |k|
      #   (k=="rxcui") || (k=="name") || (k=="synonym")
      # end
    end
    medication_info
  end
  # binding.pry
  def self.search_medication(term)
    res = RestClient.get rxnav_url, params: { name: term }
    self.parse_search_results(res)
  end

end
