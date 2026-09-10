module FieldDefinitions
  class Field
    OPERATORS = %i[
      eq
      not_eq
      contains
      not_contains
      starts_with
      gt
      gteq
      lt
      lteq
      between
      is_null
      in
      not_in
    ].freeze

    MULTIPLE_SELECTION_OPERATORS = %w[in not_in]

    attr_reader :name, :prefix, :path, :filter, :description, :example, :attributes

    def initialize(attributes)
      @name = attributes.fetch(:name)
      @prefix = ActiveSupport::StringInquirer.new(attributes[:prefix].to_s) if attributes.key?(:prefix)
      @path = attributes[:path] = [ prefix, name ].compact.join(".")
      @filter = attributes.fetch(:filter)
      @description = attributes[:description]
      @read_only = attributes[:read_only] = attributes.fetch(:read_only, false)
      @required = attributes[:required] = attributes.fetch(:required, false)
      @example = attributes[:example]
      @attributes = attributes
    end

    def read_only?
      !!@read_only
    end

    def required?
      !!@required
    end
  end
end
