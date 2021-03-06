class InteractionPresenter < SimpleDelegator
  attr_accessor :interaction

  def initialize(interaction)
    @interaction = interaction
    super
  end

  def display_name
    "#{@interaction.gene.name} AND #{@interaction.drug.name}"
  end

  def na_or_types
    types = interaction.interaction_types.map{|t| {type: t.type, directionality: t.directionality}}.reject{|t| t['type'] == "n/a"}
    types.count > 0 ? types : [{type: "n/a", directionality: nil}]
  end

  def as_json(opts = {})
    {
      id: interaction.id,
      gene_name: interaction.gene.name,
      entrez_id: interaction.gene.entrez_id,
      drug_name: interaction.drug.name,
      concept_id: interaction.drug.concept_id,
      publications: interaction.publications.map(&:pmid),
      interaction_types: interaction.interaction_types.map(&:type),
      interaction_direction: interaction.interaction_types.map(&:directionality),
      sources: interaction.sources.map(&:source_db_name),
      score: interaction.interaction_score.round(2),
    }
  end
end
