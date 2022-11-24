# encoding: ascii-8bit
require_relative './base_message'

module Bitcoin
  module Network
    module Messages
      class Verack < BaseMessage
        COMMAND = "verack"

        def serialize
          ''
        end

        def self.parse(_)
          new
        end
      end
    end
  end
end
