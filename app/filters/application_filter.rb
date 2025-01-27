class ApplicationFilter < ApplicationRequestSchema
  class_attribute :__filter_class__

  def self.build_filter_schema(filter_class)
    Class.new(ApplicationFilter) do
      self.__filter_class__ = filter_class

      params do
        optional(:filter).schema(filter_class.schema)
      end

      rule(:filter).validate(contract: filter_class)

      def output
        result = super.fetch(:filter, {})
        __filter_class__.new(input_params: result).output
      end
    end
  end
end
