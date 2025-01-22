class ApplicationFilter < ApplicationRequestSchema
  def output
    output_data = super
    output_data.fetch(:filter, {})
  end
end
