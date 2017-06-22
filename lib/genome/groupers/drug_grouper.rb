module Genome
  module Groupers
    class DrugGrouper

      def run
        begin
          newly_added_claims_count = 0
          # drug_claims_not_in_groups.find_in_batches do |claims|
          drug_claims_not_in_groups[0..100].all do |claims|
            ActiveRecord::Base.transaction do
              grouped_claims = add_members(claims)
              newly_added_claims_count += grouped_claims.length
              if grouped_claims.length > 0
                add_attributes(grouped_claims)
              end
            end
          end
        end # until newly_added_claims_count == 0
      end

      def add_members(claims)
        grouped_claims = []
        claims.each do |drug_claim|
          grouped_claims << group_drug_claim(drug_claim)
        end
        return grouped_claims.compact
      end

      def group_drug_claim(drug_claim)
        # check drug names
        #   - against claim name
        #   - against claim aliases
        if (drug = DataModel::Drug.where('upper(name) in (?) or chembl_id IN (?)', drug_claim.names, drug_claim.names)).one?
          add_drug_claim_to_drug(drug_claim, drug.first)
          return drug_claim
        elsif drug.many?
          direct_multimatch << drug_claim
          return nil
        end

        # check molecule names and aliases
        #   - against claim name
        #   - against claim aliases
        if (molecule = DataModel::ChemblMolecule.where('upper(pref_name) in (?) or chembl_id IN (?)', drug_claim.names, drug_claim.names)).one?
          drug = create_drug_from_molecule(molecule.first)
          add_drug_claim_to_drug(drug_claim, drug)
          return drug_claim
        elsif molecule.many?
          @molecule_multimatch << drug_claim
          return nil
        end

        if (molecule_id = DataModel::ChemblMoleculeSynonym.where('upper(synonym) in (?)', drug_claim.names).pluck(:chembl_molecule_id).to_set).one?
          molecule = DataModel::ChemblMolecule.where(id: molecule_id.first).first
          drug = create_drug_from_molecule(molecule)
          add_drug_claim_to_drug(drug_claim, drug)
          return drug_claim
        elsif molecule_id.many?
          @molecule_multimatch << drug_claim
          return nil
        end

        # check drug aliases (indirect)
        #   - against claim name
        #   - against claim aliases

        if (drug_id = DataModel::DrugAlias.where('upper(alias) in (?)', drug_claim.names).pluck(:drug_id).to_set).one?
          drug = DataModel::Drug.where(id: drug_id.first).first
          add_drug_claim_to_drug(drug_claim, drug)
          return drug_claim
        end

      end

      def direct_multimatch
        @direct_multimatch ||= Set.new
      end

      def molecule_multimatch
        @molecule_multimatch ||= Set.new
      end

      def indirect_multimatch
        @indirect_multimatch ||= Set.new
      end

      def drug_claims_not_in_groups
        nil # Find all drug claims not in groups and not in direct_multimatch, molecule_multimatch or indirect_multimatch
        DataModel::DrugClaim.where(drug_id: nil).keep_if do |drug_claim|
          !(
            direct_multimatch.member? drug_claim or
            molecule_multimatch.member? drug_claim or
            indirect_multimatch.member? drug_claim
          )
        end
      end
    end
  end
end
