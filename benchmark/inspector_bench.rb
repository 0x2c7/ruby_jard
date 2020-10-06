# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'securerandom'
require 'ruby_jard'

##
# Benchmark lib/ruby_jard/path_filter.rb
class InpsectorBench
  include Benchmark

  def initialize
    @inspector = RubyJard::Inspectors::Base.new
  end

  def execute
    n = 10_000

    str = (1..300).to_a.map { ('a'..'z').to_a.sample }.join
    arr = ['a' * 30, 123_345_789, { a: 1, b: 2 }] * 30
    hash = {}
    30.times { |index| hash["variable#{index}"] = ['a' * 30, 123_345_789, { a: 1, b: 2 }].sample }
    obj = Object.new
    30.times { |index| obj.instance_variable_set("@variable#{index}", SecureRandom.random_bytes(10)) }

    giant_hash = {}
    100.times { |index| giant_hash["@variable#{index}"] = ['a' * 30, 123_345_789, { a: 1, b: 2 }].sample }
    giant_array = [giant_hash] * 1_000

    Benchmark.benchmark(CAPTION, 7, FORMAT) do |x|
      x.report('String inline    ') { n.times { @inspector.inline(str, line_limit: 120) } }
      x.report('String multiline ') { n.times { @inspector.multiline(str, line_limit: 120, lines: 7) } }
      x.report('String baseline  ') { n.times { str.inspect } }
      x.report('Array inline     ') { n.times { @inspector.inline(arr, line_limit: 120) } }
      x.report('Array multiline  ') { n.times { @inspector.multiline(arr, line_limit: 120, lines: 7) } }
      x.report('Array baseline   ') { n.times { arr.inspect } }
      x.report('Hash inline      ') { n.times { @inspector.inline(hash, line_limit: 120) } }
      x.report('Hash multiline   ') { n.times { @inspector.multiline(hash, line_limit: 120, lines: 7) } }
      x.report('Hash baseline    ') { n.times { hash.inspect } }
      x.report('Object inline    ') { n.times { @inspector.inline(obj, line_limit: 120) } }
      x.report('Object multiline ') { n.times { @inspector.multiline(obj, line_limit: 120, lines: 7) } }
      x.report('Object baseline  ') { n.times { obj.inspect } }
      x.report('Big arr inline   ') { n.times { @inspector.inline(giant_array, line_limit: 120) } }
      x.report('Big arr multiline') { n.times { @inspector.multiline(giant_array, line_limit: 120, lines: 7) } }
      x.report('Big arr baseline ') { n.times { giant_array.inspect } }
    end
  end
end

InpsectorBench.new.execute
# Commit 14030cd5ba1a64a779b4de04c3e0780e479d548a
# user     system      total        real
# String inline      0.258254   0.000441   0.258695 (  0.258742)
# String multiline   0.295293   0.000026   0.295319 (  0.295363)
# String baseline    0.048631   0.000057   0.048688 (  0.048694)
# Array inline       3.480633   0.000104   3.480737 (  3.480916)
# Array multiline    3.455404   0.000046   3.455450 (  3.455677)
# Array baseline     0.910096   0.000029   0.910125 (  0.910206)
# Hash inline        3.041610   0.000000   3.041610 (  3.041763)
# Hash multiline     5.942645   0.000046   5.942691 (  5.943762)
# Hash baseline      0.549978   0.000000   0.549978 (  0.550111)
# Object inline      1.788219   0.000000   1.788219 (  1.788344)
# Object multiline   5.642556   0.000000   5.642556 (  5.642953)
# Object baseline    0.519554   0.000000   0.519554 (  0.519670)
# Big arr inline    16.223891   0.000000  16.223891 ( 16.225869)
# Big arr multiline 18.647541   0.000000  18.647541 ( 18.649372)
# Big arr baseline  Forever
#
# Commit 1466b9f25c71e236c7561ed24b41219e57aba0f1
# user     system      total        real
# String inline      0.105376   0.007392   0.112768 (  0.113027)
# String multiline   0.112024   0.000021   0.112045 (  0.112094)
# String baseline    0.033947   0.000320   0.034267 (  0.034306)
# Array inline       1.237948   0.000000   1.237948 (  1.238292)
# Array multiline    1.236173   0.000000   1.236173 (  1.236279)
# Array baseline     0.634234   0.000000   0.634234 (  0.634829)
# Hash inline        1.416262   0.000000   1.416262 (  1.416259)
# Hash multiline     2.111986   0.000000   2.111986 (  2.111999)
# Hash baseline      0.321968   0.000000   0.321968 (  0.321984)
# Object inline      0.652878   0.000000   0.652878 (  0.652913)
# Object multiline   2.141283   0.000000   2.141283 (  2.141366)
# Object baseline    0.360957   0.000000   0.360957 (  0.360964)
# Big arr inline     6.660659   0.000000   6.660659 (  6.660611)
# Big arr multiline  7.684002   0.000000   7.684002 (  7.683965)
# Big arr baseline   Forever
