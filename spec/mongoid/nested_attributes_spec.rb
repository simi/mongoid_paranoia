require "spec_helper"

describe Mongoid::Attributes::Nested do
  describe "##{name}_attributes=" do
    context "when the parent document is new" do
      context "when the relation is an embeds many" do
        context "when ids are passed" do

          let(:person) do
            Person.create
          end

          let(:address_one) do
            Address.new(street: "Unter den Linden")
          end

          let(:address_two) do
            Address.new(street: "Kurfeurstendamm")
          end

          let(:phone_one) do
            ParanoidPhone.new(number: "1")
          end

          let(:phone_two) do
            ParanoidPhone.new(number: "2")
          end

          before do
            person.addresses << [ address_one, address_two ]
          end

          context "when destroy attributes are passed" do
            context "when the ids match" do
              context "when allow_destroy is true" do
                context "when the child is paranoid" do

                  before(:all) do
                    Person.send(:undef_method, :paranoid_phones_attributes=)
                    Person.accepts_nested_attributes_for :paranoid_phones,
                      allow_destroy: true
                  end

                  after(:all) do
                    Person.send(:undef_method, :paranoid_phones_attributes=)
                    Person.accepts_nested_attributes_for :paranoid_phones
                  end

                  [ 1, "1", true, "true" ].each do |truth|

                    context "when passed a #{truth} with destroy" do
                      context "when the parent is persisted" do

                        let!(:persisted) do
                          Person.create do |p|
                            p.paranoid_phones << [ phone_one, phone_two ]
                          end
                        end

                        context "when setting, pulling, and pushing in one op" do

                          before do
                            persisted.paranoid_phones_attributes =
                              {
                              "bar" => { "id" => phone_one.id, "_destroy" => truth },
                              "foo" => { "id" => phone_two.id, "number" => "3" },
                              "baz" => { "number" => "4" }
                            }
                          end

                          # The destroy is deferred until parent save (matching stock
                          # Mongoid behavior for non-paranoid embedded docs). Pre-save the
                          # in-memory collection still contains the doc flagged for destruction.

                          it "flags the marked document for destruction" do
                            expect(phone_one.flagged_for_destroy?).to be true
                          end

                          it "does not soft-delete the marked document until save" do
                            expect(phone_one).not_to be_destroyed
                            expect(phone_one.reload.deleted_at).to be_nil
                          end

                          it "keeps the marked document in the relation pending save" do
                            expect(persisted.paranoid_phones.size).to eq(3)
                          end

                          it "applies the update to the unmarked document" do
                            expect(persisted.paranoid_phones.find(phone_two.id).number).to eq("3")
                          end

                          it "adds the new document to the relation" do
                            expect(persisted.paranoid_phones.last.number).to eq("4")
                          end

                          it "counts only persisted (non-pending) docs" do
                            # phone_one and phone_two are persisted; the new phone is not
                            # persisted until parent save runs.
                            expect(persisted.paranoid_phones.count).to eq(2)
                          end

                          context "when saving the parent" do

                            before do
                              persisted.save
                            end

                            it "deletes the marked document from the relation" do
                              expect(persisted.reload.paranoid_phones.count).to eq(2)
                            end

                            it "does not delete the unmarked document" do
                              expect(persisted.reload.paranoid_phones.first.number).to eq("3")
                            end

                            it "persists the new document to the relation" do
                              expect(persisted.reload.paranoid_phones.last.number).to eq("4")
                            end
                          end
                        end
                      end
                    end
                  end
                end

                context "regression: deferred destroy on parent validation failure" do
                  # Before the fix, assigning _destroy: true on a paranoid embedded doc
                  # immediately persisted a soft-delete via update_one, regardless of
                  # whether the parent's subsequent save succeeded. This left orphaned
                  # soft-deletes if the parent was rejected by validations or if save
                  # was never called (e.g. a read-only preview endpoint).

                  before(:all) do
                    Person.send(:undef_method, :paranoid_phones_attributes=)
                    Person.accepts_nested_attributes_for :paranoid_phones, allow_destroy: true
                  end

                  after(:all) do
                    Person.send(:undef_method, :paranoid_phones_attributes=)
                    Person.accepts_nested_attributes_for :paranoid_phones
                  end

                  let!(:persisted) do
                    Person.create do |p|
                      p.paranoid_phones << ParanoidPhone.new(number: "1")
                    end
                  end
                  let(:phone) { persisted.paranoid_phones.first }

                  it "does not soft-delete when assign_attributes is not followed by save" do
                    persisted.assign_attributes(paranoid_phones_attributes: [{ id: phone.id, _destroy: "1" }])
                    expect(phone.reload.deleted_at).to be_nil
                    expect(persisted.reload.paranoid_phones.count).to eq(1)
                  end

                  it "does not soft-delete when the parent save fails validation" do
                    invalid = Class.new(StandardError)
                    Person.validate { errors.add(:base, "nope") if @reject_save }
                    persisted.instance_variable_set(:@reject_save, true)
                    expect {
                      persisted.update_attributes!(paranoid_phones_attributes: [{ id: phone.id, _destroy: "1" }])
                    }.to raise_error(Mongoid::Errors::Validations)
                    expect(phone.reload.deleted_at).to be_nil
                    expect(persisted.reload.paranoid_phones.count).to eq(1)
                    Person._validate_callbacks.clear
                  end

                  it "soft-deletes when the parent save succeeds" do
                    persisted.update_attributes!(paranoid_phones_attributes: [{ id: phone.id, _destroy: "1" }])
                    expect(phone.reload.deleted_at).not_to be_nil
                    expect(persisted.reload.paranoid_phones.count).to eq(0)
                    expect(persisted.reload.paranoid_phones.unscoped.count).to eq(1)
                  end
                end

                context "when the child has defaults" do

                  before(:all) do
                    Person.accepts_nested_attributes_for :appointments, allow_destroy: true
                  end

                  after(:all) do
                    Person.send(:undef_method, :appointments_attributes=)
                  end
                  context "when the parent is persisted" do
                    context "when the child returns false in a before callback" do
                      context "when the child is paranoid" do

                        before(:all) do
                          Person.accepts_nested_attributes_for :paranoid_phones, allow_destroy: true
                        end

                        after(:all) do
                          Person.send(:undef_method, :paranoid_phones=)
                          Person.accepts_nested_attributes_for :paranoid_phones
                        end

                        let!(:persisted) do
                          Person.create(age: 42)
                        end

                        let!(:phone) do
                          persisted.paranoid_phones.create
                        end

                        before do
                          persisted.paranoid_phones_attributes =
                            { "foo" => { "id" => phone.id, "number" => 42, "_destroy" => true }}
                        end

                        it "does not destroy the child" do
                          expect(persisted.reload.paranoid_phones).not_to be_empty
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
