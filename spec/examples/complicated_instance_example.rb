# frozen_string_literal: true

require 'ruby_jard'
require_relative './complicated_instance_2_example'

module ModuleX
  def self.a_test_method
    @module_variable_1 = 1
    jard
    @module_variable_2 = 2
    @module_variable_4 = 4
    super_method
  end

  class ClassA < ParentClassA
    @class_variable_1 = 1

    include ModuleY
    prepend ModuleZ

    def initialize
      super
      @instance_1 = 1 # Shown
    end

    def self.another_test_method
      @class_variable_2 = 2
      jard
      @class_variable_3 = 3
      hyper_method
    end

    def test_method
      @instance_2 = 2
      jard
      @instance_4 = 4
      @instance_5 = 5
      parent_method
    end
  end
end

ModuleX.a_test_method
ModuleX::ClassA.new.test_method
ModuleX::ClassA.another_test_method
