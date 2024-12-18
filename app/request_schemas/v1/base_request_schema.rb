module V1
  class BaseRequestSchema < JSONAPIRequestSchema
    option :account

    def output
      result = super
      result[:account] = account
      result
    end
  end
end
