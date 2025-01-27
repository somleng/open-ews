require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "OpenEWS API Documentation"
  config.api_explanation = <<~HEREDOC
    # Introduction

    The OpenEWS API enables Organizations and Governments to efficiently manage and disseminate early warning broadcasts to beneficiaries in disaster-prone areas.
    It provides robust tools for interacting with beneficiary data, crafting broadcast alert messages, and monitoring the performance of dissemination broadcasts. Built with scalability and flexibility in mind, OpenEWS supports integration with external systems, ensuring seamless communication and data interoperability.

    The API follows the [JSON:API standard](https://jsonapi.org/), a specification for building APIs in a consistent and predictable manner. This ensures standardization in resource representation, error handling, and query parameters, making integration and development easier for your technical team.

    This documentation is intended for developers, system integrators, and technical stakeholders working on early warning systems. By leveraging the OpenEWS API, you can automate processes such as beneficiary management, broadcast distribution, and reporting, empowering your organization to deliver timely and impactful alerts.

    ## Making an HTTP Request

    All API endpoints are accessible via HTTPS and adhere to RESTful principles. The API uses the [JSON:API standard](https://jsonapi.org/), meaning all requests and responses conform to a defined structure, including the use of specific top-level document fields (`data`, `attributes`, `relationships`, etc.).

    The base URL for the API is:
    `https://api.open-ews.org/v1/`

    Requests should include the following components:

    1. **HTTP Method:** The API supports standard methods such as `GET`, `POST`, `PATCH`, and `DELETE`. Use the appropriate method based on the endpoint requirements.
    2. **Headers:** Ensure the request includes the `Authorization` header with a valid API token and the `Content-Type` header set to `application/vnd.api+json` to comply with JSON:API standards.
    3. **Endpoint URL:** Combine the base URL with the specific endpoint path to form the complete request URL.

    ### Example HTTP Request

    ```http
    POST https://api.open-ews.org/v1/beneficiaries
    Authorization: Bearer YOUR_API_TOKEN
    Content-Type: application/vnd.api+json
    ```

    ```json
    {
      "data": {
        "type": "beneficiary",
        "attributes": {
          "phone_number": "+85510999999",
          "gender": "M",
          "iso_country_code": "KH"
        }
      }
    }
    ```

    ## Credentials

    To access the OpenEWS API, you need an API token. Tokens authenticate your application and authorize access to API resources. Follow these steps to obtain and manage your API credentials:

    1. **Request an API Token:** Log in to your OpenEWS account or contact your administrator to generate an API token.
    2. **Include the Token in Requests:** Pass the token in the `Authorization` header of each API request using the format `Bearer YOUR_API_TOKEN`.
    3. **Token Security:** Treat your token as sensitive information. Do not expose it in client-side code or share it publicly.
    4. **Regenerate or Revoke Tokens:** If your token is compromised or needs to be updated, regenerate it from your account settings or by contacting the administrator.

    ### Example Authorization Header

    `Authorization: Bearer YOUR_API_TOKEN`
  HEREDOC

  config.format = :open_ews_slate
  config.curl_headers_to_filter = [ "Host", "Cookie", "Content-Type" ]

  config.request_headers_to_include = []
  config.response_headers_to_include = [ "Location", "Per-Page", "Total" ]
  config.request_body_formatter = proc do |params|
    JSON.pretty_generate(params) if params.present?
  end
  config.keep_source_order = true
  config.disable_dsl_status!

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end
end
