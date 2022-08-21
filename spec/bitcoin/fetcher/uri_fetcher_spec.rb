require 'bitcoin/fetcher/uri_fetcher'

RSpec.describe UriFetcher do
  describe '#UriFetcher' do
    subject(:uri_fetcher) { described_class.new }

    it 'fetch the wanted tx' do
      tx_id = '5fbb9471b8b801847274b0e3c51bc76957031293422f5eafe43101d91f2c9a1d'

      tx_fetched_id = uri_fetcher.fetch(tx_id, testnet: true).id.first

      expect(tx_fetched_id).to eq tx_id
    end
  end
end
