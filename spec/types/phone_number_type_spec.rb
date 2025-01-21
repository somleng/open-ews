require "rails_helper"

RSpec.describe PhoneNumberType do
  it "handles phone number types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
    end

    expect(klass.new(number: nil).number).to eq(nil)
    expect(klass.new(number: "invalid").number).to eq(nil)
    expect(klass.new(number: "1294").number).to eq("1294")
    expect(klass.new(number: "+855 97 222 2222").number).to eq("855972222222")
  end
end
