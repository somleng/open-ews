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

    attr_reader :name, :prefix, :path, :column, :query, :schema, :association, :description, :example, :attributes

    def initialize(attributes)
      @name = attributes.fetch(:name)
      @prefix = ActiveSupport::StringInquirer.new(attributes[:prefix].to_s) if attributes.key?(:prefix)
      @path = attributes[:path] = [ prefix, name ].compact.join(".")
      @schema = attributes[:schema]
      @query = attributes[:query]
      @column = attributes[:column]
      @association = attributes[:association]
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

    def clone(overrides)
      self.class.new(attributes.merge(overrides))
    end

    def operator_options_for_select
      operators.map do |operator|
        [ human_operator(operator), operator ]
      end
    end

    def human_name(**options)
      translation_key = [ options[:namespace]&.downcase, name ].compact.join(".")
      ApplicationRecord.human_attribute_name(translation_key)
    end

    def human_operator(operator)
      I18n.t("filter_operators.#{operator}")
    end

    def human_value(value)
      return value unless schema.is_a?(FilterSchema::ListType)
      return value if value.blank?

      schema.options_for_select.find { it.last == value }.first
    end

    def operators
      schema.schema_definition.key_map.map do |key|
        key.name
      end
    end
  end
end
