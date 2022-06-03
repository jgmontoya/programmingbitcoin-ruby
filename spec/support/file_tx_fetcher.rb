require 'json'

class FileTxFetcher
  def initialize(_file)
    @map = JSON.parse(File.read(_file))
  end

  def fetch(_tx_hash)
    hex_tx = @map.fetch(_tx_hash.unpack1("H*"))
    StringIO.new([hex_tx].pack("H*"))
  end
end
