class InteractionSearchResultsApiV1Presenter
  def initialize(search_results)
    @search_results = search_results
  end

  def matched_results
    @matched_results ||= @search_results
      .select { |r| r.is_definite? && r.has_interactions? }
      .flat_map { |r| r.interactions.map {|identifier, interactions| InteractionSearchResultApiV1Presenter.new(r, identifier, interactions) }}
  end

  def unmatched_results
    @unmatched_results ||= @search_results
      .select { |r| r.is_ambiguous? || !r.has_results? }
  end

end
