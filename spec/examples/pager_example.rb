require 'ruby_jard'

def generate_hash(items)
  hash = {}
  (1..items).each do |index|
    hash["variable_#{index}".to_sym] = 'a' * 30
  end
  hash
end

hash_a = generate_hash(5)
jard
hash_b = generate_hash(10)
jard
hash_c = generate_hash(15)
jard
hash_d = generate_hash(20)
jard
hash_e = generate_hash(25)
jard
sleep 0
