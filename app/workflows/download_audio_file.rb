class DownloadAudioFile < ApplicationWorkflow
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    uri = URI.parse(broadcast.audio_url)
    broadcast.cache_audio_file_from_audio_url = true
    broadcast.audio_file.attach(
      io: URI.open(uri),
      filename: File.basename(uri)
    )
  rescue OpenURI::HTTPError, URI::InvalidURIError
    broadcast.mark_as_errored!("Unable to download audio file")
  end
end
