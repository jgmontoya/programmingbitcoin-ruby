# encoding: ascii-8bit
require 'bitcoin/op'
require 'ecc/s256_point'
require 'ecc/signature'
require 'hash_helper'

RSpec.describe Bitcoin::Op do
  let(:described_module) { Object.new.extend described_class }

  describe '#op_0' do
    it 'pushes a 0 (empty string) into the stack' do
      stack = []

      described_module.op_0(stack)
      expect(stack).to eq([""])
    end
  end

  describe '#op_drop' do
    it 'pops the top element of the stack' do
      element1 = ['111111'].pack("H*")
      element2 = ['222222'].pack("H*")
      stack = [element1, element2]

      described_module.op_drop(stack)
      expect(stack).to eq([element1])
    end
  end

  describe '#op_dup' do
    it 'duplicates the top element in the stack' do
      element1 = ['111111'].pack("H*")
      element2 = ['222222'].pack("H*")
      stack = [element1, element2]

      described_module.op_dup(stack)
      expect(stack).to eq([element1, element2, element2])
    end
  end

  describe '#op_hash160' do
    before do
      allow(HashHelper).to receive(:hash160).and_return('hash160')
    end

    it 'pops the top element of the stack, and pushes its hash160 into the stack' do
      element1 = ['111111'].pack("H*")
      element2 = ['222222'].pack("H*")
      stack = [element1, element2]

      described_module.op_hash160(stack)
      expect(stack).to eq([element1, HashHelper::hash160(element2)])
    end
  end

  describe '#op_hash256' do
    before do
      allow(HashHelper).to receive(:hash256).and_return('hash256')
    end

    it 'pops the top element of the stack, and pushes its hash256 into the stack' do
      element1 = ['111111'].pack("H*")
      element2 = ['222222'].pack("H*")
      stack = [element1, element2]

      described_module.op_hash256(stack)
      expect(stack).to eq([element1, HashHelper::hash256(element2)])
    end
  end

  describe '#op_checksig' do
    let(:der_signature) { ['1111'].pack("H*") }
    let(:der_signature_with_hash_type) { ['1111aa'].pack("H*") }
    let(:sec_pubkey) { ['2222'].pack("H*") }

    let(:point) { instance_double(ECC::S256Point) }
    let(:sig) { instance_double(ECC::Signature) }

    before do
      allow(ECC::S256Point).to receive(:parse).with(sec_pubkey).and_return(point)
      allow(ECC::Signature).to receive(:parse).with(der_signature).and_return(sig)
    end

    context 'when there is two or more elements in the stack' do
      before do
        allow(point).to receive(:verify).and_return(valid)
      end

      let(:stack) do
        [
          der_signature_with_hash_type,
          sec_pubkey
        ]
      end

      context 'when the signature is valid for the public key' do
        let(:valid) { true }

        it 'consumes the two elements and pushes a 1 into the stack' do
          described_module.op_checksig(stack, 0x1111)
          expect(stack).to eq(["\x01"])
        end

        it 'returns true' do
          expect(described_module.op_checksig(stack, 0x1111)).to be true
        end
      end

      context 'when the signature is not valid for the public key' do
        let(:valid) { false }

        it 'consumes the two elements and pushes an empty string into the stack' do
          described_module.op_checksig(stack, 0x1111)
          expect(stack).to eq([""])
        end

        it 'returns true' do
          expect(described_module.op_checksig(stack, 0x1111)).to be true
        end
      end
    end

    context 'when there is less than two elements in the stack' do
      let(:stack) do
        [
          sec_pubkey
        ]
      end

      it 'returns false' do
        expect(described_module.op_checksig(stack, 0x1111)).to be false
      end
    end
  end

  # rubocop:disable RSpec/EmptyLineAfterExampleGroup
  # rubocop:disable Style/BlockDelimiters
  xdescribe '#op_pushdata1' do it 'performs op_pushdata1 correctly' end
  xdescribe '#op_pushdata2' do it 'performs op_pushdata2 correctly' end
  xdescribe '#op_pushdata4' do it 'performs op_pushdata4 correctly' end
  xdescribe '#op_1negate' do it 'performs op_1negate correctly' end
  xdescribe '#op_1' do it 'performs op_1 correctly' end
  xdescribe '#op_2' do it 'performs op_2 correctly' end
  xdescribe '#op_3' do it 'performs op_3 correctly' end
  xdescribe '#op_4' do it 'performs op_4 correctly' end
  xdescribe '#op_5' do it 'performs op_5 correctly' end
  xdescribe '#op_6' do it 'performs op_6 correctly' end
  xdescribe '#op_7' do it 'performs op_7 correctly' end
  xdescribe '#op_8' do it 'performs op_8 correctly' end
  xdescribe '#op_9' do it 'performs op_9 correctly' end
  xdescribe '#op_10' do it 'performs op_10 correctly' end
  xdescribe '#op_11' do it 'performs op_11 correctly' end
  xdescribe '#op_12' do it 'performs op_12 correctly' end
  xdescribe '#op_13' do it 'performs op_13 correctly' end
  xdescribe '#op_14' do it 'performs op_14 correctly' end
  xdescribe '#op_15' do it 'performs op_15 correctly' end
  xdescribe '#op_16' do it 'performs op_16 correctly' end
  xdescribe '#op_nop' do it 'performs op_nop correctly' end
  xdescribe '#op_if' do it 'performs op_if correctly' end
  xdescribe '#op_notif' do it 'performs op_notif correctly' end
  xdescribe '#op_else' do it 'performs op_else correctly' end
  xdescribe '#op_endif' do it 'performs op_endif correctly' end
  xdescribe '#op_verify' do it 'performs op_verify correctly' end
  xdescribe '#op_return' do it 'performs op_return correctly' end
  xdescribe '#op_toaltstack' do it 'performs op_toaltstack correctly' end
  xdescribe '#op_fromaltstack' do it 'performs op_fromaltstack correctly' end
  xdescribe '#op_2drop' do it 'performs op_2drop correctly' end
  xdescribe '#op_2dup' do it 'performs op_2dup correctly' end
  xdescribe '#op_3dup' do it 'performs op_3dup correctly' end
  xdescribe '#op_2over' do it 'performs op_2over correctly' end
  xdescribe '#op_2rot' do it 'performs op_2rot correctly' end
  xdescribe '#op_2swap' do it 'performs op_2swap correctly' end
  xdescribe '#op_ifdup' do it 'performs op_ifdup correctly' end
  xdescribe '#op_depth' do it 'performs op_depth correctly' end
  xdescribe '#op_nip' do it 'performs op_nip correctly' end
  xdescribe '#op_over' do it 'performs op_over correctly' end
  xdescribe '#op_pick' do it 'performs op_pick correctly' end
  xdescribe '#op_roll' do it 'performs op_roll correctly' end
  xdescribe '#op_rot' do it 'performs op_rot correctly' end
  xdescribe '#op_swap' do it 'performs op_swap correctly' end
  xdescribe '#op_tuck' do it 'performs op_tuck correctly' end
  xdescribe '#op_size' do it 'performs op_size correctly' end
  xdescribe '#op_equal' do it 'performs op_equal correctly' end
  xdescribe '#op_equalverify' do it 'performs op_equalverify correctly' end
  xdescribe '#op_1add' do it 'performs op_1add correctly' end
  xdescribe '#op_1sub' do it 'performs op_1sub correctly' end
  xdescribe '#op_negate' do it 'performs op_negate correctly' end
  xdescribe '#op_abs' do it 'performs op_abs correctly' end
  xdescribe '#op_not' do it 'performs op_not correctly' end
  xdescribe '#op_0notequal' do it 'performs op_0notequal correctly' end
  xdescribe '#op_add' do it 'performs op_add correctly' end
  xdescribe '#op_sub' do it 'performs op_sub correctly' end
  xdescribe '#op_mul' do it 'performs op_mul correctly' end
  xdescribe '#op_booland' do it 'performs op_booland correctly' end
  xdescribe '#op_boolor' do it 'performs op_boolor correctly' end
  xdescribe '#op_numequal' do it 'performs op_numequal correctly' end
  xdescribe '#op_numequalverify' do it 'performs op_numequalverify correctly' end
  xdescribe '#op_numnotequal' do it 'performs op_numnotequal correctly' end
  xdescribe '#op_lessthan' do it 'performs op_lessthan correctly' end
  xdescribe '#op_greaterthan' do it 'performs op_greaterthan correctly' end
  xdescribe '#op_lessthanorequal' do it 'performs op_lessthanorequal correctly' end
  xdescribe '#op_greaterthanorequal' do it 'performs op_greaterthanorequal correctly' end
  xdescribe '#op_min' do it 'performs op_min correctly' end
  xdescribe '#op_max' do it 'performs op_max correctly' end
  xdescribe '#op_within' do it 'performs op_within correctly' end
  xdescribe '#op_ripemd160' do it 'performs op_ripemd160 correctly' end
  xdescribe '#op_sha1' do it 'performs op_sha1 correctly' end
  xdescribe '#op_sha256' do it 'performs op_sha256 correctly' end
  xdescribe '#op_codeseparator' do it 'performs op_codeseparator correctly' end
  xdescribe '#op_checksigverify' do it 'performs op_checksigverify correctly' end
  xdescribe '#op_checkmultisig' do it 'performs op_checkmultisig correctly' end
  xdescribe '#op_checkmultisigverify' do it 'performs op_checkmultisigverify correctly' end
  xdescribe '#op_nop1' do it 'performs op_nop1 correctly' end
  xdescribe '#op_checklocktimeverify' do it 'performs op_checklocktimeverify correctly' end
  xdescribe '#op_checksequenceverify' do it 'performs op_checksequenceverify correctly' end
  xdescribe '#op_nop4' do it 'performs op_nop4 correctly' end
  xdescribe '#op_nop5' do it 'performs op_nop5 correctly' end
  xdescribe '#op_nop6' do it 'performs op_nop6 correctly' end
  xdescribe '#op_nop7' do it 'performs op_nop7 correctly' end
  xdescribe '#op_nop8' do it 'performs op_nop8 correctly' end
  xdescribe '#op_nop9' do it 'performs op_nop9 correctly' end
  xdescribe '#op_nop10' do it 'performs op_nop10 correctly' end

  # rubocop:enable RSpec/EmptyLineAfterExampleGroup
  # rubocop:enable Style/BlockDelimiters
end
