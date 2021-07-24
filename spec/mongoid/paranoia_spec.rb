require "spec_helper"

describe Mongoid::Paranoia do
  context 'configuring the paranoid_field setting' do
    before do
      Mongoid::Paranoia.configure do |c|
        c.paranoid_field = :myFieldName
      end
    end

    describe '.configure' do
      before do
        class ParanoidConfigured
          include Mongoid::Document
          include Mongoid::Paranoia
        end
      end

      it 'allows custom setting of the paranoid_field' do
        paranoid_configured = ParanoidConfigured.new
        expect(paranoid_configured.attribute_names).to include('myFieldName')
      end

      after(:each) do
        Mongoid::Paranoia.reset
      end
    end

    describe '.reset' do
      before do
        Mongoid::Paranoia.reset

        # the configuration gets set at include time
        # so you need to reset before defining a new class
        class ParanoidConfiguredReset
          include Mongoid::Document
          include Mongoid::Paranoia
        end
      end

      it 'restores the paranoid_field to the default setting' do
        paranoid_configured = ParanoidConfiguredReset.new
        expect(paranoid_configured.attribute_names).to include('deleted_at')
      end
    end
  end

  describe ".scoped" do

    it "returns a scoped criteria" do
      expect(ParanoidPost.scoped.selector).to eq({ "deleted_at" => nil })
    end
  end

  describe ".deleted" do

    context "when called on a root document" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.destroy
      end

      let(:deleted) do
        ParanoidPost.deleted
      end

      it "returns the deleted documents" do
        expect(deleted).to eq([ post ])
      end
    end

    context "when called on an embedded document" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create
      end

      before do
        phone.destroy
        person.reload
      end

      it "returns the deleted documents" do
        expect(person.paranoid_phones.deleted.to_a).to eq([ phone ])
      end

      it "returns the correct count" do
        expect(person.paranoid_phones.deleted.count).to eq(1)
      end
    end
  end

  describe "#destroy!" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.destroy!
      end

      let(:raw) do
        ParanoidPost.collection.find(_id: post.id).first
      end

      it "hard deletes the document" do
        expect(raw).to be_nil
      end

      it "executes the before destroy callbacks" do
        expect(post.before_destroy_called).to be_truthy
      end

      it "executes the after destroy callbacks" do
        expect(post.after_destroy_called).to be_truthy
      end

      it "executes the before remove callbacks" do
        expect(post.before_remove_called).to be_truthy
      end

      it "executes the after remove callbacks" do
        expect(post.after_remove_called).to be_truthy
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      before do
        phone.destroy!
      end

      let(:raw) do
        Person.collection.find(_id: person.id).first
      end

      it "hard deletes the document" do
        expect(raw["paranoid_phones"]).to be_empty
      end

      it "executes the before destroy callbacks" do
        expect(phone.before_destroy_called).to be_truthy
      end

      it "executes the after destroy callbacks" do
        expect(phone.after_destroy_called).to be_truthy
      end
    end

    context "when the document has a dependent relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:author) do
        post.authors.create(name: "poe")
      end

      before do
        post.destroy!
      end

      it "cascades the dependent option" do
        expect {
          author.reload
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

  describe "#destroy" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.destroy
      end

      let(:raw) do
        ParanoidPost.collection.find(_id: post.id).first
      end

      it "soft deletes the document" do
        expect(raw["deleted_at"]).to be_within(1).of(Time.now)
      end

      it "is still marked as persisted" do
        expect(post.persisted?).to eq(true)
      end

      it "does not return the document in a find" do
        expect {
          ParanoidPost.find(post.id)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it "executes the before destroy callbacks" do
        expect(post.before_destroy_called).to be_truthy
      end

      it "executes the after destroy callbacks" do
        expect(post.after_destroy_called).to be_truthy
      end

      it "does not execute the before remove callbacks" do
        expect(post.before_remove_called).to be_falsey
      end

      it "does not execute the after remove callbacks" do
        expect(post.after_remove_called).to be_falsey
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      before do
        phone.destroy
      end

      let(:raw) do
        Person.collection.find(_id: person.id).first
      end

      it "soft deletes the document" do
        expect(raw["paranoid_phones"].first["deleted_at"]).to be_within(1).of(Time.now)
      end

      it "does not return the document in a find" do
        expect {
          person.paranoid_phones.find(phone.id)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it "does not include the document in the relation" do
        expect(person.paranoid_phones.scoped).to be_empty
      end

      it "executes the before destroy callbacks" do
        expect(phone.before_destroy_called).to be_truthy
      end

      it "executes the after destroy callbacks" do
        expect(phone.after_destroy_called).to be_truthy
      end
    end

    context "when the document has a dependent: :delete relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:author) do
        post.authors.create(name: "poe")
      end

      before do
        post.destroy
      end

      it "cascades the dependent option" do
        expect {
          author.reload
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when the document has a dependent: :restrict relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:title) do
        post.titles.create
      end

      before do
        begin
          post.destroy
        rescue Mongoid::Errors::DeleteRestriction
        end
      end

      it "does not destroy the document" do
        expect(post).not_to be_destroyed
      end
    end
  end

  describe "#destroyed?" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      context "when the document is hard deleted" do

        before do
          post.destroy!
        end

        it "returns true" do
          expect(post).to be_destroyed
        end
      end

      context "when the document is soft deleted" do

        before do
          post.destroy
        end

        it "returns true" do
          expect(post).to be_destroyed
        end

        it "returns true for deleted scope document" do
          expect(ParanoidPost.deleted.last).to be_destroyed
        end
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      context "when the document is hard deleted" do

        before do
          phone.destroy!
        end

        it "returns true" do
          expect(phone).to be_destroyed
        end
      end

      context "when the document is soft deleted" do

        before do
          phone.destroy
        end

        it "returns true" do
          expect(phone).to be_destroyed
        end
      end
    end
  end

  describe "#deleted?" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      context "when the document is hard deleted" do

        before do
          post.destroy!
        end

        it "returns true" do
          expect(post).to be_deleted
        end
      end

      context "when the document is soft deleted" do

        before do
          post.destroy
        end

        it "returns true" do
          expect(post).to be_deleted
        end
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      context "when the document is hard deleted" do

        before do
          phone.destroy!
        end

        it "returns true" do
          expect(phone).to be_deleted
        end
      end

      context "when the document is soft deleted" do

        before do
          phone.destroy
        end

        it "returns true" do
          expect(phone).to be_deleted
        end
      end

      context "when the document has non-dependent relation" do
        let(:post) do
          ParanoidPost.create(title: "test")
        end

        let!(:tag) do
          post.tags.create(text: "tagie")
        end

        before do
          post.delete
        end

        it "doesn't cascades the dependent option" do
          expect(tag.reload).to eq(tag)
        end

      end
    end
  end

  describe "#delete!" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.delete!
      end

      let(:raw) do
        ParanoidPost.collection.find(_id: post.id).first
      end

      it "hard deletes the document" do
        expect(raw).to be_nil
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      before do
        phone.delete!
      end

      let(:raw) do
        Person.collection.find(_id: person.id).first
      end

      it "hard deletes the document" do
        expect(raw["paranoid_phones"]).to be_empty
      end
    end

    context "when the document has a dependent relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:author) do
        post.authors.create(name: "poe")
      end

      before do
        post.delete!
      end

      it "does not cascade the dependent option" do
        expect {
          author.reload
        }.to_not raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

  describe "#delete" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.delete
      end

      let(:raw) do
        ParanoidPost.collection.find(_id: post.id).first
      end

      it "soft deletes the document" do
        expect(raw["deleted_at"]).to be_within(1).of(Time.now)
      end

      it "does not return the document in a find" do
        expect {
          ParanoidPost.find(post.id)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      before do
        phone.delete
      end

      let(:raw) do
        Person.collection.find(_id: person.id).first
      end

      it "soft deletes the document" do
        expect(raw["paranoid_phones"].first["deleted_at"]).to be_within(1).of(Time.now)
      end

      it "does not return the document in a find" do
        expect {
          person.paranoid_phones.find(phone.id)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it "does not include the document in the relation" do
        expect(person.paranoid_phones.scoped).to be_empty
      end
    end

    context "when the document has a dependent relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:author) do
        post.authors.create(name: "poe")
      end

      before do
        post.delete
      end

      it "does not cascade the dependent option" do
        expect {
          author.reload
        }.to_not raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when the document has a dependent: :restrict relation" do

      let(:post) do
        ParanoidPost.create(title: "test")
      end

      let!(:title) do
        post.titles.create
      end

      before do
        begin
          post.delete
        rescue Mongoid::Errors::DeleteRestriction
        end
      end

      it "ignores restrict and destroys the document" do
        expect(post).to be_destroyed
      end
    end
  end

  describe "#remove" do

    let(:post) do
      ParanoidPost.new
    end

    let!(:time) do
      Time.now
    end

    before do
      post.remove
    end

    it "sets the deleted flag" do
      expect(post).to be_destroyed
    end
  end

  describe "#restore" do

    context "when the document is a root" do

      let(:post) do
        ParanoidPost.create(title: "testing")
      end

      before do
        post.delete
        post.restore
      end

      it "removes the deleted at time" do
        expect(post.deleted_at).to be_nil
      end

      it "persists the change" do
        expect(post.reload.deleted_at).to be_nil
      end

      it "marks document again as persisted" do
        expect(post.persisted?).to be_truthy
      end

      context "will run callback" do

        it "before restore" do
          expect(post.before_restore_called).to be_truthy
        end

        it "after restore" do
          expect(post.after_restore_called).to be_truthy
        end

        it "around restore" do
          expect(post.around_before_restore_called).to be_truthy
          expect(post.around_after_restore_called).to be_truthy
        end
      end
    end

    context "when the document is embedded" do

      let(:person) do
        Person.create
      end

      let(:phone) do
        person.paranoid_phones.create(number: "911")
      end

      before do
        phone.delete
        phone.restore
      end

      it "removes the deleted at time" do
        expect(phone.deleted_at).to be_nil
      end

      it "persists the change" do
        expect(person.reload.paranoid_phones.first.deleted_at).to be_nil
      end
    end
  end

  describe "#restore_relations" do

    subject { ParaBase.create }

    let!(:para_has_one)     { subject.para_has_one = ParaHasOne.create       }
    let!(:para_has_many)    { 2.times.map { subject.para_has_many.create }   }
    let!(:para_habtm)       { 3.times.map { subject.para_habtm.create }      }
    let!(:para_belongs_to)  { subject.para_belongs_to = ParaBelongsTo.create }
    let!(:para_embeds_one)  { subject.para_embeds_one = ParaEmbedsOne.new    }
    let!(:para_embeds_many) { 2.times.map { subject.para_embeds_many.build } }

    let!(:norm_has_one)     { subject.norm_has_one = NormHasOne.create       }
    let!(:norm_has_many)    { 2.times.map { subject.norm_has_many.create }   }
    let!(:norm_habtm)       { 3.times.map { subject.norm_habtm.create }      }
    let!(:norm_belongs_to)  { subject.norm_belongs_to = NormBelongsTo.create }
    let!(:norm_embeds_one)  { subject.norm_embeds_one = NormEmbedsOne.new    }
    let!(:norm_embeds_many) { 2.times.map { subject.norm_embeds_many.build } }

    let(:prepare) do
      subject.destroy
      subject.restore
    end

    context "restores paranoid associations" do
      before { prepare }

      it { expect{ subject.restore_relations}.to change{ ParaHasOne.count    }.by(1) }
      it { expect{ subject.restore_relations}.to change{ ParaHasMany.count   }.by(2) }
      it { expect{ subject.restore_relations}.to change{ ParaHabtm.count     }.by(3) }
      it { expect{ subject.restore_relations}.to change{ ParaBelongsTo.count }.by(1) }
    end

    context "does not affect embedded paranoid documents" do
      before { prepare }

      it { expect{ subject.restore_relations}.to_not change{ subject.para_embeds_one } }
      it { expect{ subject.restore_relations}.to_not change{ subject.para_embeds_many.count } }
    end

    context "does not affect non-paranoid documents" do
      before { prepare }

      it { expect{ subject.restore_relations}.to_not change{ NormHasOne.count    } }
      it { expect{ subject.restore_relations}.to_not change{ NormHasMany.count   } }
      it { expect{ subject.restore_relations}.to_not change{ NormHabtm.count     } }
      it { expect{ subject.restore_relations}.to_not change{ NormBelongsTo.count } }
      it { expect{ subject.restore_relations}.to_not change{ subject.norm_embeds_one } }
      it { expect{ subject.restore_relations}.to_not change{ subject.norm_embeds_many.count } }
    end

    context "recursion" do

      let!(:para_habtm_norm_has_one)  { subject.para_habtm.first.norm_has_one = NormHasOne.create  } # not restored
      let!(:para_habtm_para_has_one)  { subject.para_habtm.first.para_has_one = ParaHasOne.create  } # restored
      let!(:para_habtm_norm_has_many) { 2.times.map { subject.para_habtm.first.norm_has_many  = NormHasMany.create } } # not restored
      let!(:para_habtm_para_has_many) { 3.times.map { subject.para_habtm.second.para_has_many = ParaHasMany.create } } # restored

      # Untestable due to infinite recursion condition in #destroy
      # let!(:para_habtm_norm_habtm)    { 3.times.map { subject.para_habtm.second.norm_habtm.create } } # not restored
      # let!(:para_habtm_recursive)     { 2.times.map { subject.para_habtm.first.recursive.create }   } # restored

      before do
        subject.destroy
        subject.restore
      end

      it { expect{ subject.restore_relations}.to change { ParaHasOne.count  }.by(2) }
      it { expect{ subject.restore_relations}.to change { ParaHasMany.count }.by(3) }

      # Untestable due to infinite recursion condition in #destroy
      # it { expect{ ParaHabtm.unscoped.each(&:restore)}.to change { ParaHabtm.count }.by(5) }

      it { expect{ subject.restore_relations}.to_not change { NormHasOne.count  } }
      it { expect{ subject.restore_relations}.to_not change { NormHasMany.count } }
      it { expect{ subject.restore_relations}.to_not change { NormHabtm.count   } }
    end
  end

  describe ".scoped" do

    let(:scoped) do
      ParanoidPost.scoped
    end

    it "returns a scoped criteria" do
      expect(scoped.selector).to eq({ "deleted_at" => nil })
    end
  end

  describe "#set" do

    let!(:post) do
      ParanoidPost.create
    end

    let(:time) do
      20.days.ago
    end

    let!(:set) do
      post.set(:deleted_at => time)
    end

    it "persists the change" do
      expect(post.reload.deleted_at).to be_within(1).of(time)
    end
  end

  describe ".unscoped" do

    let(:unscoped) do
      ParanoidPost.unscoped
    end

    it "returns an unscoped criteria" do
      expect(unscoped.selector).to eq({})
    end
  end

  describe "#to_param" do

    let(:post) do
      ParanoidPost.new(title: "testing")
    end

    context "when the document is new" do

      it "still returns nil" do
        expect(post.to_param).to be_nil
      end
    end

    context "when the document is not deleted" do

      before do
        post.save
      end

      it "returns the id as a string" do
        expect(post.to_param).to eq(post.id.to_s)
      end
    end

    context "when the document is deleted" do

      before do
        post.save
        post.delete
      end

      it "returns the id as a string" do
        expect(post.to_param).to eq(post.id.to_s)
      end
    end
  end
end
