require 'socket'
require_relative './envelope'
require_relative './messages/get_headers'
require_relative './messages/headers'
require_relative './messages/ping'
require_relative './messages/pong'
require_relative './messages/verack'
require_relative './messages/version'

module Bitcoin
  module Network
    class SimpleNode
      TESTNET_PORT = 18333
      MAINNET_PORT = 8333

      def initialize(host, port=nil, testnet=false, logging=false)
        @testnet = testnet
        @logging = logging

        port ||= @testnet ? TESTNET_PORT : MAINNET_PORT

        connect(port, host)
      end

      attr_accessor :testnet, :logging, :socket

      def send(message)
        envelope = Bitcoin::Network::Envelope.new(
          message.command,
          message.serialize,
          @testnet
        )

        puts "sending: #{envelope}" if @logging

        @socket.send(envelope.serialize, 0)
      end

      def read
        begin
          envelope = Bitcoin::Network::Envelope.parse(@socket)
        rescue IOError
          puts 'no data received' if @logging
          return nil
        end

        puts "receiving #{envelope}" if @logging

        envelope
      end

      def wait_for(*message_classes)
        command = nil
        command_to_class = message_classes.to_h { |msg_class| [msg_class::COMMAND, msg_class] }

        while !command_to_class.key? command
          envelope = read
          if envelope.nil?
            sleep(1)
            next
          end

          command = envelope.command_bytes

          send(Bitcoin::Network::Messages::Verack.new) if command == 'version'
          send(Bitcoin::Network::Messages::Pong.parse(envelope.stream)) if command == 'ping'
        end

        command_to_class[command].parse(envelope.stream)
      end

      def handshake
        version = Bitcoin::Network::Messages::Version.new
        send(version)
        wait_for(Bitcoin::Network::Messages::Verack)
      end

      private

      def connect(port, host)
        @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM

        puts 'connecting...' if @logging
        @socket.connect(Socket.pack_sockaddr_in(port, host))
      end
    end
  end
end
