require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::StringType do
  let(:schema) {
    FieldDefinitions::FilterSchema::StringType.define
  }

  it "supports `eq` operator" do
    expect(schema.call(eq: "foo")).to be_success
    expect(schema.call(eq: nil)).not_to be_success
  end

  it "supports `not_eq` operator" do
    expect(schema.call(not_eq: "foo")).to be_success
    expect(schema.call(not_eq: nil)).not_to be_success
  end

  it "supports `is_null` operator" do
    expect(schema.call(is_null: true)).to be_success
    expect(schema.call(is_null: false)).to be_success
    expect(schema.call(is_null: nil)).not_to be_success
  end

  it "supports `contains` operator" do
    expect(schema.call(contains: "foo")).to be_success
    expect(schema.call(contains: nil)).not_to be_success
  end

  it "supports `not_contains` operator" do
    expect(schema.call(not_contains: "foo")).to be_success
    expect(schema.call(not_contains: nil)).not_to be_success
  end

  it "supports `starts_with` operator" do
    expect(schema.call(starts_with: "foo")).to be_success
    expect(schema.call(starts_with: nil)).not_to be_success
  end

  it "handles only operators" do
    expect(schema.key_map.map(&:name)).to contain_exactly(
      "eq",
      "not_eq",
      "contains",
      "not_contains",
      "starts_with",
      "is_null"
    )
  end

  it "supports custom type" do
    schema = FieldDefinitions::FilterSchema::StringType.define(
      FieldDefinitions::Types::UpcaseString
    )

    result = schema.call(eq: "kh")

    expect(result).to be_success
    expect(result.to_h).to eq(eq: "KH")
  end
end
