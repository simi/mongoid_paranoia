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

                          it "removes the first document from the relation" do
                            expect(persisted.paranoid_phones.size).to eq(2)
                          end

                          it "does not delete the unmarked document" do
                            expect(persisted.paranoid_phones.first.number).to eq("3")
                          end

                          it "adds the new document to the relation" do
                            expect(persisted.paranoid_phones.last.number).to eq("4")
                          end

                          it "has the proper persisted count" do
                            expect(persisted.paranoid_phones.count).to eq(1)
                          end

                          it "soft deletes the removed document" do
                            expect(phone_one).to be_destroyed
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
