require 'bitcoin/merkle_block'
require 'encoding_helper'

RSpec.describe Bitcoin::MerkleBlock do
  include EncodingHelper

  let(:raw_merkle_block) do
    from_hex_to_bytes(
      "00000020df3b053dc46f162a9b00c7f0d5124e2676d47bbe7c5d0793a500000000000000"\
      "ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4dc7c835b6"\
      "7d8001ac157e670bf0d00000aba412a0d1480e370173072c9562becffe87aa661c1e4a6db"\
      "c305d38ec5dc088a7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655"\
      "ee1e27d34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c215"\
      "8785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cbaee7261831e1"\
      "550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763cef8e625f977af7c8619c3"\
      "2a369b832bc2d051ecd9c73c51e76370ceabd4f25097c256597fa898d404ed53425de608a"\
      "c6bfe426f6e2bb457f1c554866eb69dcb8d6bf6f880e9a59b3cd053e6c7060eeacaacf4da"\
      "c6697dac20e4bd3f38a2ea2543d1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848"\
      "384eebe9af917274cdfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a41"\
      "1cb6226103b55635"
    )
  end

  let(:hex_hashes) do
    [
      'ba412a0d1480e370173072c9562becffe87aa661c1e4a6dbc305d38ec5dc088a',
      '7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655ee1e27d',
      '34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c2',
      '158785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cba',
      'ee7261831e1550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763ce',
      'f8e625f977af7c8619c32a369b832bc2d051ecd9c73c51e76370ceabd4f25097',
      'c256597fa898d404ed53425de608ac6bfe426f6e2bb457f1c554866eb69dcb8d',
      '6bf6f880e9a59b3cd053e6c7060eeacaacf4dac6697dac20e4bd3f38a2ea2543',
      'd1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848384eebe9af917274c',
      'dfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a411cb62261'
    ]
  end

  let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h).reverse } }

  let(:merkle_block_solution) do
    described_class.new(
      0x20000000,
      from_hex_to_bytes('df3b053dc46f162a9b00c7f0d5124e2676d47bbe7c5d0793a500000000000000').reverse,
      from_hex_to_bytes('ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4').reverse,
      little_endian_to_int(from_hex_to_bytes('dc7c835b')),
      from_hex_to_bytes('67d8001a'),
      from_hex_to_bytes('c157e670'),
      little_endian_to_int(from_hex_to_bytes('bf0d0000')),
      byte_hashes,
      from_hex_to_bytes('b55635').reverse
    )
  end

  describe '.parse' do
    def parse(*args)
      described_class.parse(StringIO.new(*args))
    end

    it 'properly parses the version' do
      expect(parse(raw_merkle_block).version).to eq merkle_block_solution.version
    end

    it 'properly parses the previous block' do
      expect(parse(raw_merkle_block).prev_block).to eq merkle_block_solution.prev_block
    end

    it 'properly parses the merkle root' do
      expect(parse(raw_merkle_block).merkle_root).to eq merkle_block_solution.merkle_root
    end

    it 'properly parses the timestamp' do
      expect(parse(raw_merkle_block).timestamp).to eq merkle_block_solution.timestamp
    end

    it 'properly parses the bits' do
      expect(parse(raw_merkle_block).bits).to eq merkle_block_solution.bits
    end

    it 'properly parses the nonce' do
      expect(parse(raw_merkle_block).nonce).to eq merkle_block_solution.nonce
    end

    it 'properly parses the total_tx' do
      expect(parse(raw_merkle_block).total_tx).to eq merkle_block_solution.total_tx
    end

    it 'properly parses the tx_hashes' do
      expect(parse(raw_merkle_block).tx_hashes).to eq merkle_block_solution.tx_hashes
    end

    it 'properly parses the flags' do
      expect(parse(raw_merkle_block).flags).to eq merkle_block_solution.flags
    end
  end

  describe '#valid?' do
    context 'with valid merkle root' do
      it { expect(merkle_block_solution.valid?).to be true }
    end

    context 'with invalid merkle root' do
      before { merkle_block_solution.merkle_root = from_hex_to_bytes('00000000') }

      it { expect(merkle_block_solution.valid?).to be false }
    end
  end
end
