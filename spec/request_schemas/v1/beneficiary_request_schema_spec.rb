require "rails_helper"

module V1
  RSpec.describe BeneficiaryRequestSchema, type: :request_schema do
    it "validates the msisdn" do
      contact = create(:contact)

      expect(validate_schema(input_params: { data: { attributes: { msisdn: nil } } })).not_to have_valid_field(:data, :attributes, :msisdn)
      expect(
        validate_schema(input_params: { data: { attributes: { msisdn: "+855 97 2345 6789" } }  })
      ).not_to have_valid_field(:data, :attributes, :msisdn)

      expect(
        validate_schema(input_params: { data: { attributes: { msisdn: "+855 97 2345 678" } }  })
      ).to have_valid_field(:data, :attributes, :msisdn)

      expect(
        validate_schema(
          input_params: { data: { attributes: { msisdn: contact.msisdn, iso_country_code: "KH" } }  },
          options: { account: contact.account }
        )
      ).not_to have_valid_field(:data, :attributes, :msisdn)

      expect(
        validate_schema(
          input_params: { data: { attributes: { msisdn: "+855 97 2345 678", iso_country_code: "KH" } }  },
          options: { account: contact.account }
        )
      ).to have_valid_field(:data, :attributes, :msisdn)
    end

    it "validates the metadata fields attributes" do
      expect(
        validate_schema(input_params: { data: { attributes: { metadata: nil } }  })
      ).not_to have_valid_field(:data, :attributes, :metadata)
      expect(
        validate_schema(input_params: { data: { attributes: { metadata: {} } }  })
      ).to have_valid_field(:data, :attributes, :metadata)
      expect(
        validate_schema(input_params: { data: { attributes: { metadata: { "foo" => "bar" } } }  })
      ).to have_valid_field(:data, :attributes, :metadata)
    end

    it "handles postprocessing" do
      result = validate_schema(
        input_params: {
          data: {
            attributes: {
              msisdn: "(855) 97 2345 678",
              iso_country_code: "kh"
            }
          }
        }
      ).output

      expect(result).to include(
        msisdn: "+855972345678",
        iso_country_code: "KH"
      )
    end

    def validate_schema(input_params:, options: {})
      BeneficiaryRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
