require_relative 's256_point.rb'
require_relative 'signature.rb'
require_relative 'secp256k1_constants.rb'
require_relative '../helper.rb'
require 'openssl'

module ECC
  class PrivateKey
    attr_reader :point

    def initialize(secret)
      @secret = secret
      @point = secret * ECC::S256Point::G
    end

    def to_s
      @num.to_s.rjust(64, '0')
    end

    def sign(z)
      k = deterministic_k(z)
      r = (k * ECC::S256Point::G).x.num
      k_inv = k.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      s = (z + r * @secret ) * k_inv % Secp256k1Constants::N

      s = Secp256k1Constants::N - s if s > Secp256k1Constants::N / 2

      ECC::Signature.new(r, s)
    end

    def deterministic_k(z)
      k = "\x00".b * 32
      v = "\x01".b * 32
      if z > Secp256k1Constants::N
        z -= Secp256k1Constants::N
      end

      z_bytes = [z].pack("N").rjust(32, "\x00".b)
      secret_bytes = [@secret].pack("N").rjust(32, "\x00".b)

      message_1 = v + "\x00".b + secret_bytes + z_bytes
      k = OpenSSL::HMAC.digest("SHA256", k, message_1)
      v = OpenSSL::HMAC.digest("SHA256", k, v)

      message_2 = v + "\x01".b + secret_bytes + z_bytes
      k = OpenSSL::HMAC.digest("SHA256", k, message_2)
      v = OpenSSL::HMAC.digest("SHA256", k, v)

      while true
        v = OpenSSL::HMAC.digest("SHA256", k, v)
        candidate = v.unpack("N").first
        return candidate if candidate >= 1 && candidate < Secp256k1Constants::N

        k = OpenSSL::HMAC.digest("SHA256", k, v + "\x00".b)
        v = OpenSSL::HMAC.digest("SHA256", k, v)
      end
    end
  end
end
