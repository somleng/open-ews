module RequestSpecHelpers
  def set_authorization_header_for(account)
    access_token = create(:access_token, resource_owner: account)
    set_authorization_header(access_token:)
  end

  def set_authorization_header(access_token:)
    authentication :basic, "Bearer #{access_token.token}"
  end

  def json_response(body = response_body)
    JSON.parse(body)
  end

  def jsonapi_response_attributes
    json_response.dig("data", "attributes")
  end
end

RSpec.configure do |config|
  config.include(RequestSpecHelpers, type: :request)
end
