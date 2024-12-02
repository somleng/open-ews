class ApplicationRecord < ActiveRecord::Base
  include SerializableResource
  include DecoratableResource
  include TimestampQueryHelpers

  primary_abstract_class
end
