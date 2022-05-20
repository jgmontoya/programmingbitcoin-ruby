require_relative 's256_point.rb'
require_relative 'signature.rb'
require_relative 'constants.rb'
require_relative '../helper.rb'
require 'openssl'

module ECC
  class PrivateKey
    attr_reader :point

    def initialize(secret)
      @secret = secret
      @point = ECC::S256Point.G * secret
    end

    def to_s
      @num.to_s.rjust(64, '0')
    end

    def sign(z)
      k = deterministic_k(z)
      r = ECC::S256Point.G.*(k).x.num
      k_inv = k.pow(ECC::N - 2, ECC::N)
      s = (z + r * @secret ) * k_inv % ECC::N

      s = ECC::N - s if s > ECC::N / 2

      return ECC::Signature.new(r, s)
    end

    def deterministic_k(z)
      k = "\x00".b * 32
      v = "\x01".b * 32
      if z > ECC::N
        z -= ECC::N
      end

      # pending: bytes has to of size 32
      z_bytes = [z].pack("N")
      secret_bytes = [@secret].pack("N")

      message_1 = v + "\x00".b + secret_bytes + z_bytes
      k = OpenSSL::HMAC.digest("SHA256", k, message_1)
      v = OpenSSL::HMAC.digest("SHA256", k, v)

      message_2 = v + "\x01".b + secret_bytes + z_bytes
      k = OpenSSL::HMAC.digest("SHA256", k, message_2)
      v = OpenSSL::HMAC.digest("SHA256", k, v)

      while true
        v = OpenSSL::HMAC.digest("SHA256", k, v)
        candidate = v.unpack("N").first
        if candidate >= 1 && candidate < N
          return candidate
        end

        k = OpenSSL::HMAC.digest("SHA256", k, v + "\x00".b)
        v = OpenSSL::HMAC.digest("SHA256", k, v)
      end
    end
  end
end
