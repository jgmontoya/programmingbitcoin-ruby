require 'merkle_tree'
require 'encoding_helper'

RSpec.describe MerkleTree do
  include EncodingHelper

  describe '#initialize' do
    context 'when number of leaves is even' do
      let(:tree) { described_class.new(16) }

      it 'creates tree with correct number of nodes' do
        expect(tree.nodes.flatten.size).to be(31)
      end

      it 'creates tree with correct max depth' do
        expect(tree.max_depth).to be(4)
      end
    end

    context 'when number of leaves is odd' do
      let(:tree) { described_class.new(27) }

      it 'creates tree with correct number of nodes' do
        expect(tree.nodes.flatten.size).to be(55)
      end
    end
  end

  describe '#to_s' do
    context 'when tree is empty' do
      it 'properly represents tree' do
        tree_string = "None\n"\
                      "None, None\n"\
                      "None, None, None, None\n"\
                      "None, None, None, None, None, None, None, None"

        expect(described_class.new(8).to_s).to eq(tree_string)
      end
    end

    context 'when tree is full' do
      let(:hex_hashes) do
        [
          "42f6f52f17620653dcc909e58bb352e0bd4bd1381e2955d19c00959a22122b2e",
          "94c3af34b9667bf787e1c6a0a009201589755d01d02fe2877cc69b929d2418d4",
          "959428d7c48113cb9149d0566bde3d46e98cf028053c522b8fa8f735241aa953",
          "a9f27b99d5d108dede755710d4a1ffa2c74af70b4ca71726fa57d68454e609a2",
          "62af110031e29de1efcad103b3ad4bec7bdcf6cb9c9f4afdd586981795516577"
        ]
      end
      let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h) } }
      let(:flag_bits) { Array.new(11, 1) }
      let(:tree) { described_class.new(hex_hashes.size) }

      it 'properly represents tree' do
        tree.populate_tree(flag_bits, byte_hashes)
        tree_string = "a8e8bd02\n"\
                      "e2e5af20, 4e1f780d\n"\
                      "d7fb8a90, 4e7a9ff0, 610b17d5\n"\
                      "42f6f52f, 94c3af34, 959428d7, a9f27b99, 62af1100"

        expect(tree.to_s).to eq(tree_string)
      end
    end
  end

  describe '#populate_tree' do
    context 'when all hashes are given' do
      let(:hex_hashes) do
        [
          "9745f7173ef14ee4155722d1cbf13304339fd00d900b759c6f9d58579b5765fb",
          "5573c8ede34936c29cdfdfe743f7f5fdfbd4f54ba0705259e62f39917065cb9b",
          "82a02ecbb6623b4274dfcab82b336dc017a27136e08521091e443e62582e8f05",
          "507ccae5ed9b340363a0e6d765af148be9cb1c8766ccc922f83e4ae681658308",
          "a7a4aec28e7162e1e9ef33dfa30f0bc0526e6cf4b11a576f6c5de58593898330",
          "bb6267664bd833fd9fc82582853ab144fece26b7a8a5bf328f8a059445b59add",
          "ea6d7ac1ee77fbacee58fc717b990c4fcccf1b19af43103c090f601677fd8836",
          "457743861de496c429912558a106b810b0507975a49773228aa788df40730d41",
          "7688029288efc9e9a0011c960a6ed9e5466581abf3e3a6c26ee317461add619a",
          "b1ae7f15836cb2286cdd4e2c37bf9bb7da0a2846d06867a429f654b2e7f383c9",
          "9b74f89fa3f93e71ff2c241f32945d877281a6a50a6bf94adac002980aafe5ab",
          "b3a92b5b255019bdaf754875633c2de9fec2ab03e6b8ce669d07cb5b18804638",
          "b5c0b915312b9bdaedd2b86aa2d0f8feffc73a2d37668fd9010179261e25e263",
          "c9d52c5cb1e557b92c84c52e7c4bfbce859408bedffc8a5560fd6e35e10b8800",
          "c555bc5fc3bc096df0a0c9532f07640bfb76bfe4fc1ace214b8b228a1297a4c2",
          "f9dbfafc3af3400954975da24eb325e326960a25b87fffe23eef3e7ed2fb610e"
        ]
      end
      let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h) } }
      let(:flag_bits) { Array.new(31, 1) }
      let(:tree) { described_class.new(hex_hashes.size) }

      it 'properly populates the tree' do
        tree.populate_tree(flag_bits, byte_hashes)
        root = '597c4bafe3832b17cbbabe56f878f4fc2ad0f6a402cee7fa851a9cb205f87ed1'

        expect(bytes_to_hex(tree.root)).to eq(root)
      end
    end

    context 'when some hashes are given' do
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
      let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h) } }
      let(:flag_bits) { [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0] }
      let(:tree) { described_class.new(3519) }

      it 'properly populates the tree' do
        tree.populate_tree(flag_bits, byte_hashes)
        root_solution = 'ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4'

        expect(bytes_to_hex(tree.root)).to eq(root_solution)
      end
    end
  end
end
