module SchemaTypes
  include Dry.Types()

  Number = String.constructor do |string|
    string.gsub(/\D/, "") if string.present?
  end

  UpcaseString = String.constructor do |string|
    string.upcase if string.present?
  end
end
