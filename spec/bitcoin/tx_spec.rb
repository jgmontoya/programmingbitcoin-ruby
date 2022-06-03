require 'bitcoin/tx'

RSpec.describe Bitcoin::Tx do
  describe ".parse" do
    let(:raw_tx) do
      "0100000001813f79011acb80925dfe69b3def355fe914bd1d96a3f5f71bf8303c6a989c7d1000000006b48304502\
2100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f\
56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf\
016b278afeffffff02a135ef01000000001976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac99c3980000000\
0001976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac19430600"
    end

    let(:tx) { described_class.parse hex_to_byte_stream(raw_tx) }

    it "properly parses the version" do
      expect(tx.version).to eq(1)
    end

    it "properly parses input count" do
      expect(tx.ins.count).to eq(1)
    end

    it "properly parses each input prev_tx" do
      expect(bytes_to_hex(tx.ins.first.prev_tx)).to eq "d1c789a9c60383bf715f3f6ad9d14b91fe55f3deb36\
9fe5d9280cb1a01793f81"
    end

    it "properly parses each input prev_index" do
      expect(tx.ins.first.prev_index).to eq 0
    end

    it "properly parses each input script_sig" do
      expect(bytes_to_hex(tx.ins.first.raw_script_sig)).to eq "483045022100ed81ff192e75a3fd2304004d\
cadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8\
e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a"
    end

    it "properly parses each input sequence" do
      expect(tx.ins.first.sequence).to eq 0xfffffffe
    end

    it "properly parses output count" do
      expect(tx.outs.count).to eq(2)
    end

    it "properly parses each output amount" do
      expect(tx.outs.map(&:amount)).to eq([32454049, 10011545])
    end

    it "properly parses each output script_pubkey" do
      expect(tx.outs.map { |o| bytes_to_hex(o.raw_script_pubkey) }).to eq(
        [
          '76a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac',
          '76a9141c4bc762dd5423e332166702cb75f40df79fea1288ac'
        ]
      )
    end
  end

  def hex_to_byte_stream(_str)
    StringIO.new([_str].pack("H*"))
  end

  def bytes_to_hex(_bytes)
    _bytes.unpack1("H*")
  end
end
