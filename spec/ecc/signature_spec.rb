require 'ecc/signature'

RSpec.describe ECC::Signature do
  let(:r) { 0xac8d1c87e51d0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395 }
  let(:s) { 0x68342ceff8935ededd102dd876ffd6ba72d6a427a3edb13d26eb0781cb423c4 }
  let(:signature) { described_class.new(r, s) }

  describe 'to_s' do
    let(:string_format) do
      "Signature(78047132305074547209667415378684003360790728528333174453334458954808711947157,"\
      " 2945795152904547855448158643091235482997756069461486099501216307557115896772)"
    end

    it 'parses signature to expected format' do
      expect(signature.to_s).to eq string_format
    end
  end
end
