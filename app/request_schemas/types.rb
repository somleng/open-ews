module Types
  include Dry::Types()

  UpcaseString = Types::String.constructor do |str|
    str ? str.upcase : str
  end
end
