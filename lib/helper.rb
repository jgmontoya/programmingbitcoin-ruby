require 'digest'

def hash256(s)
  first_round = Digest::SHA256.digest(s)
  Digest::SHA256.hexdigest(first_round).to_i(16)
end
