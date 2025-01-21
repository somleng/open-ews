StatResult = Data.define(:key, :groups, :value, :sequence_number) do
  def id
    StatResult::IDGenerator.generate_id(key)
  end
end

class StatResult::IDGenerator
  def self.generate_id(key)
    Digest::SHA256.hexdigest(key.compact_blank.join(":"))
  end
end
