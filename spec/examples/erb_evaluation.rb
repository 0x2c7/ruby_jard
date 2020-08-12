# frozen_string_literal: true

require 'ruby_jard'
require 'erb'

class ProductView
  class ProductObject
    attr_reader :name, :prices

    def initialize(name, prices)
      @name = name
      @prices = prices
    end
  end

  def initialize(name, prices)
    @object = ProductObject.new(name, prices)
  end

  def render
    file = File.join(File.dirname(__FILE__), './erb_evaluation.erb')
    erb = ERB.new(File.read(file))
    erb.filename = file
    erb.result @object.__binding__
  end
end

ProductView.new('Bitcoin', [5710, 5810]).render
