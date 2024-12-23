require "rails_helper"

module V1
  RSpec.describe BeneficiaryRequestSchema, type: :request_schema do
    it "validates the msisdn" do
      contact = create(:contact)

      expect(
        validate_schema(input_params: { data: { attributes: { msisdn: nil } } })
      ).not_to have_valid_field(:data, :attributes, :msisdn)

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

    it "validates the iso_country_code" do
      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: nil } } })
      ).not_to have_valid_field(:data, :attributes, :iso_country_code)

      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: "foo" } }  })
      ).not_to have_valid_field(:data, :attributes, :iso_country_code)

      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: "kh" } }  })
      ).to have_valid_field(:data, :attributes, :iso_country_code)

      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: "KH" } }  })
      ).to have_valid_field(:data, :attributes, :iso_country_code)
    end

    it "validates the language_code" do
      expect(
        validate_schema(input_params: { data: { attributes: { language_code: nil } } })
      ).to have_valid_field(:data, :attributes, :language_code)

      expect(
        validate_schema(input_params: { data: { attributes: {} }  })
      ).to have_valid_field(:data, :attributes, :language_code)

      expect(
        validate_schema(input_params: { data: { attributes: { language_code: "km" } }  })
      ).to have_valid_field(:data, :attributes, :language_code)
    end

    it "validates the gender" do
      expect(
        validate_schema(input_params: { data: { attributes: { gender: nil } } })
      ).to have_valid_field(:data, :attributes, :gender)

      expect(
        validate_schema(input_params: { data: { attributes: {} }  })
      ).to have_valid_field(:data, :attributes, :gender)

      expect(
        validate_schema(input_params: { data: { attributes: { gender: "foo" } } })
      ).not_to have_valid_field(:data, :attributes, :gender)

      expect(
        validate_schema(input_params: { data: { attributes: { gender: "M" } } })
      ).to have_valid_field(:data, :attributes, :gender)
    end

    it "validates the date of birth" do
      expect(
        validate_schema(input_params: { data: { attributes: { date_of_birth: nil } } })
      ).to have_valid_field(:data, :attributes, :date_of_birth)

      expect(
        validate_schema(input_params: { data: { attributes: {} }  })
      ).to have_valid_field(:data, :attributes, :date_of_birth)

      expect(
        validate_schema(input_params: { data: { attributes: { date_of_birth: "invalid-date" } } })
      ).not_to have_valid_field(:data, :attributes, :date_of_birth)

      expect(
        validate_schema(input_params: { data: { attributes: { date_of_birth: "2000-01-01" } } })
      ).to have_valid_field(:data, :attributes, :date_of_birth)
    end

    it "validates the address" do
      expect(
        validate_schema(input_params: { data: { attributes: { address: nil } } })
      ).not_to have_valid_field(:data, :attributes, :address)

      expect(
        validate_schema(input_params: { data: { attributes: {} }  })
      ).to have_valid_field(:data, :attributes, :address)

      expect(
        validate_schema(input_params: { data: { attributes: { address: { iso_region_code: "KH-1" } } } })
      ).to have_valid_field(:data, :attributes, :address, :iso_region_code)
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
