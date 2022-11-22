# encoding: ascii-8bit
require_relative './base_message'

module Bitcoin
  module Network
    module Messages
      class Pong < BaseMessage
        COMMAND = "pong"

        def initialize(nonce)
          @nonce = nonce
        end

        def serialize
          @nonce
        end

        def self.parse(stream)
          nonce = stream.read(8)
          new(nonce)
        end
      end
    end
  end
end
