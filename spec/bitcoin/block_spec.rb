require 'bitcoin/block'
require 'encoding_helper'

RSpec.describe Bitcoin::Block do
  include EncodingHelper

  describe '#parse' do
    let(:raw_block_header) do
      "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40\
508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d"
    end

    def parse(*args)
      described_class.parse(StringIO.new(from_hex_to_bytes(*args)))
    end

    it 'properly parses the version' do
      expect(parse(raw_block_header).version).to eq 0x20000002
    end

    it 'properly parses the previous block' do
      expect(parse(raw_block_header).prev_block)
        .to eq from_hex_to_bytes('000000000000000000fd0c220a0a8c3bc5a7b487e8c8de0dfa2373b12894c38e')
    end

    it 'properly parses the merkle root' do
      expect(parse(raw_block_header).merkle_root)
        .to eq from_hex_to_bytes('be258bfd38db61f957315c3f9e9c5e15216857398d50402d5089a8e0fc50075b')
    end

    it 'properly parses the timestamp' do
      expect(parse(raw_block_header).timestamp).to eq 0x59a7771e
    end

    it 'properly parses the bits' do
      expect(parse(raw_block_header).bits).to eq from_hex_to_bytes('e93c0118')
    end

    it 'properly parses the nonce' do
      expect(parse(raw_block_header).nonce).to eq from_hex_to_bytes('a4ffd71d')
    end
  end
end
