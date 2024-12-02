require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "Somleng SCFM API Documentation"
  config.api_explanation = <<~HEREDOC
    This is the API Documentation for Somleng Simple Call Flow Manager (Somleng SCFM).
  HEREDOC
  config.format = :slate
  config.curl_headers_to_filter = [ "Host", "Cookie", "Content-Type" ]

  config.request_headers_to_include = []
  config.response_headers_to_include = [ "Location", "Per-Page", "Total" ]
  config.request_body_formatter = proc do |params|
    JSON.pretty_generate(params) if params.present?
  end
  config.keep_source_order = false
  config.disable_dsl_status!

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end

  config.define_group :scfm_api do |conf|
    conf.filter = :scfm_api
    conf.docs_dir = Rails.root.join("doc/api")
  end

  config.define_group :open_ews_api do |conf|
    conf.filter = :open_ews_api
    conf.docs_dir = Rails.root.join("doc/open_ews_api")
  end
end
