class ApplicationRequestSchema < Dry::Validation::Contract
  Types = FieldDefinitions::Types

  attr_reader :input_params

  option :resource, optional: true
  option :account, optional: true

  delegate :success?, :errors, to: :result

  register_macro(:phone_number_format) do
    key.failure(text: "is invalid") if key? && !Phony.plausible?(value)
  end

  register_macro(:url_format) do
    next unless key?

    uri = URI.parse(value)
    isValid = (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host.present?

    key.failure(text: "is invalid") unless isValid
  rescue URI::InvalidURIError
    key.failure(text: "is invalid")
  end

  # NOTE: composable contracts
  #
  # params do
  #   required(:a).hash(OtherContract.schema)
  # end
  #
  # rule(:a).validate(contract: OtherContract)
  #
  register_macro(:contract) do |macro:|
    contract_instance = macro.args[0]
    contract_result = contract_instance.new(input_params: value)
    unless contract_result.success?
      errors = contract_result.errors
      errors.each do |error|
        key(key.path.to_a + error.path).failure(error.text)
      end
    end
  end

  def initialize(input_params:, options: {})
    super(**options)

    @input_params = input_params.to_h.with_indifferent_access
  end

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end
end
