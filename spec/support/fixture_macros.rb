require_relative '../support/file_tx_fetcher'

module FixtureMacros
  def self.included(_klass)
    _klass.extend ClassMethods
  end

  def resolve_tx(_hex_hash)
    tx_fetcher.fetch([_hex_hash].pack("H*"))
  end

  module ClassMethods
    def load_transaction_set(_fixture_name)
      let(:tx_fetcher) do
        FileTxFetcher.new(File.dirname(__FILE__) + "/../fixtures/#{_fixture_name}.json")
      end
    end
  end
end

RSpec.configure do |config|
  config.include FixtureMacros
end
