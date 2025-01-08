class APIDocumentationClient < RspecApiDocumentation::RackTestClient
  private

  def process(method, path, params = {}, headers = {})
    if path.start_with?("http")
      full_path = path
    else
      full_path = URI.join("https://api.open-ews.org", path)
    end

    do_request(method, full_path, params, headers)
    document_example(method.to_s.upcase, full_path)
  end
end


module APIDocumentationHelpers
  def client
    @client ||= APIDocumentationClient.new(self)
  end
end

RSpec.configure do |config|
  config.prepend(APIDocumentationHelpers, api_doc_dsl: :resource)

  config.before(:each, jsonapi: true) do
    header("Content-Type", "application/vnd.api+json")
  end
end
