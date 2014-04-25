require "spec_helper"

describe Mongoid::Criteria::Scopable do

  context "when the document is paranoid" do

    context "when calling a class method" do

      let(:criteria) do
        Fish.fresh
      end

      it "includes the deleted_at criteria in the selector" do
        expect(criteria.selector).to eq({
          "deleted_at" => nil, "fresh" => true
        })
      end
    end

    context "when chaining a class method to unscoped" do

      let(:criteria) do
        Fish.unscoped.fresh
      end

      it "does not include the deleted_at in the selector" do
        expect(criteria.selector).to eq({ "fresh" => true })
      end
    end

    context "when chaining a class method to deleted" do

      let(:criteria) do
        Fish.deleted.fresh
      end

      it "includes the deleted_at $ne criteria in the selector" do
        expect(criteria.selector).to eq({
          "deleted_at" => { "$ne" => nil }, "fresh" => true
        })
      end
    end

    context "when chaining a where to unscoped" do

      let(:criteria) do
        Fish.unscoped.where(fresh: true)
      end

      it "includes no default scoping information in the selector" do
        expect(criteria.selector).to eq({ "fresh" => true })
      end
    end
  end
end
