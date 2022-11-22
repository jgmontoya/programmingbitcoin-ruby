# encoding: ascii-8bit
require_relative '../../../bitcoin_data_io'
require_relative './base_message'

module Bitcoin
  module Network
    module Messages
      class Version < BaseMessage
        COMMAND = "version"

        def initialize(
          version: 70015,
          services: 0,
          timestamp: nil,
          receiver_services: 0,
          receiver_ip: "\x00\x00\x00\x00",
          receiver_port: 8333,
          sender_services: 0,
          sender_ip: "\x00\x00\x00\x00",
          sender_port: 8333,
          nonce: nil,
          user_agent: "/budabitcoinguild:0.1/",
          latest_block: 0,
          relay: false
        )
          @version = version
          @services = services
          @timestamp = timestamp.nil? ? Time.now.to_i : timestamp
          @receiver_services = receiver_services
          @receiver_ip = receiver_ip
          @receiver_port = receiver_port
          @sender_services = sender_services
          @sender_ip = sender_ip
          @sender_port = sender_port
          @nonce = nonce.nil? ? 0 : nonce
          @user_agent = user_agent
          @latest_block = latest_block
          @relay = relay
        end

        def serialize
          result = int_to_little_endian(@version, 4)
          result << int_to_little_endian(@services, 8)
          result << int_to_little_endian(@timestamp, 8)
          result << int_to_little_endian(@receiver_services, 8)
          result << "\x00" * 10 + "\xff\xff" + @receiver_ip
          result << int_to_big_endian(@receiver_port, 2)
          result << int_to_little_endian(@sender_services, 8)
          result << "\x00" * 10 + "\xff\xff" + @sender_ip
          result << int_to_big_endian(@sender_port, 2)
          result << int_to_little_endian(@nonce, 8)
          result << encode_varint(@user_agent.length)
          result << @user_agent
          result << int_to_little_endian(@latest_block, 4)
          result << (@relay ? "\x01" : "\x00")

          result
        end
      end
    end
  end
end
