# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'ruby_jard'
require 'securerandom'
require 'jard_merge_sort'

##
# Benchmark lib/ruby_jard/path_filter.rb
class PathFilterBench
  include Benchmark

  def initialize
    config = RubyJard::Config.new
    config.filter = :application
    @path_filter = RubyJard::PathFilter.new(config: config)
  end

  def execute
    n = 500_000
    file = File.expand_path('../lib/ruby_jard/path_filter.rb')
    gem_file = JardMergeSort::Sorter.instance_method(:sort).source_location[0]
    stdlib_file = SecureRandom.method(:uuid).source_location[0]

    Benchmark.benchmark(CAPTION, 7, FORMAT) do |x|
      x.report('App file     ') { n.times { @path_filter.match?(file) } }
      x.report('Gem file     ') { n.times { @path_filter.match?(gem_file) } }
      x.report('Stdlib file  ') { n.times { @path_filter.match?(stdlib_file) } }
      x.report('(eval)       ') { n.times { @path_filter.match?('(eval)') } }
      x.report('<internal:gc>') { n.times { @path_filter.match?('<internal:gc>') } }
      x.report('nil          ') { n.times { @path_filter.match?(nil) } }
      x.report('Other file   ') { n.times { @path_filter.match?(file) } }
      x.report('Base line    ') { n.times { File.expand_path('abc/def.rb').start_with?('abc/') } }
    end
  end
end

PathFilterBench.new.execute

# Commit 9858faa422a35b4a7a13c5ac986e35bf16fb8029
# App file       4.528750   0.168117   4.696867 (  4.698018)
# Gem file       6.003084   0.235965   6.239049 (  6.239139)
# Stdlib file    6.198815   0.203962   6.402777 (  6.402885)
# (eval)         0.830737   0.000104   0.830841 (  0.830878)
# <internal:gc>  0.747695   0.000000   0.747695 (  0.747713)
# Other file     4.317924   0.191915   4.509839 (  4.509897)
# Base line      0.026612   0.000000   0.026612 (  0.026614)

# Latest
# App file       1.217831   0.147700   1.365531 (  1.365815)
# Gem file       2.569692   0.180220   2.749912 (  2.750003)
# Stdlib file    2.450189   0.171845   2.622034 (  2.622073)
# (eval)         0.312905   0.000080   0.312985 (  0.312986)
# <internal:gc>  0.457472   0.000116   0.457588 (  0.457589)
# nil            0.191749   0.000000   0.191749 (  0.191761)
# Other file     1.207719   0.143965   1.351684 (  1.351699)
# Base line      0.631581   0.143966   0.775547 (  0.775573)
