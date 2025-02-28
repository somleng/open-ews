require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::ListType do
  let(:schema) {
    FieldDefinitions::FilterSchema::ListType.define(:string, [ "foo", "bar" ])
  }

  it "supports `eq` operator" do
    expect(schema.call(eq: "foo")).to be_success
    expect(schema.call(eq: nil)).not_to be_success
    expect(schema.call(eq: "invalid")).not_to be_success
  end

  it "supports `not_eq` operator" do
    expect(schema.call(not_eq: "foo")).to be_success
    expect(schema.call(not_eq: nil)).not_to be_success
    expect(schema.call(not_eq: "invalid")).not_to be_success
  end

  it "supports `is_null` operator" do
    expect(schema.call(is_null: true)).to be_success
    expect(schema.call(is_null: false)).to be_success
    expect(schema.call(is_null: nil)).not_to be_success
  end

  it "handles only operators" do
    expect(schema.key_map.map(&:name)).to contain_exactly(
      "eq",
      "not_eq",
      "is_null"
    )
  end
end
