class ApplicationFilter < ApplicationRequestSchema
  def self.build_filter_schema(filter_class)
    Class.new(ApplicationFilter) do
      @@__filter_class__ = filter_class

      params do
        optional(:filter).schema(filter_class.schema)
      end

      def output
        result = super.fetch(:filter, {})
        @@__filter_class__.new(input_params: result).output
      end
    end
  end
end
