class APIDocumentationClient < RspecApiDocumentation::RackTestClient
  DOC_HOSTS = {
    scfm_api: "https://scfm.somleng.org",
    open_ews_api: "https://api.open-ews.org"
  }


  private

  def process(method, path, params = {}, headers = {})
    if path.start_with?("http")
      full_path = path
    else
      doc_host = DOC_HOSTS.fetch(metadata[:document]) { DOC_HOSTS[:scfm_api] }
      full_path = URI.join(doc_host, path)
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

  config.before(:each, document: :open_ews_api) do
    header("Content-Type", "application/vnd.api+json")
  end
end
