require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::ValueType do
  let(:schema) {
    FieldDefinitions::FilterSchema::ValueType.define(:integer)
  }

  it "supports `eq` operator" do
    expect(schema.call(eq: 1)).to be_success
    expect(schema.call(eq: nil)).not_to be_success
  end

  it "supports `not_eq` operator" do
    expect(schema.call(not_eq: 1)).to be_success
    expect(schema.call(not_eq: nil)).not_to be_success
  end

  it "supports `gt` operator" do
    expect(schema.call(gt: 1)).to be_success
    expect(schema.call(gt: nil)).not_to be_success
  end

  it "supports `gteq` operator" do
    expect(schema.call(gteq: 1)).to be_success
    expect(schema.call(gteq: nil)).not_to be_success
  end

  it "supports `lt` operator" do
    expect(schema.call(lt: 1)).to be_success
    expect(schema.call(lt: nil)).not_to be_success
  end

  it "supports `lteq` operator" do
    expect(schema.call(lteq: 1)).to be_success
    expect(schema.call(lteq: nil)).not_to be_success
  end

  it "supports `between` operator" do
    expect(schema.call(between: [ 1, 2 ])).to be_success
    expect(schema.call(between: nil)).not_to be_success
    expect(schema.call(between: [ 1 ])).not_to be_success
    expect(schema.call(between: [ 1, 2, 3 ])).not_to be_success
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
      "gt",
      "gteq",
      "lt",
      "lteq",
      "between",
      "is_null"
    )
  end
end
