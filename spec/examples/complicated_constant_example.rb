# frozen_string_literal: true

require 'ruby_jard'
require_relative './complicated_constant_2_example'

$global1 = 'global1'

module ModuleX
  CONSTANT_MODULE_X = 'constant_2'.freeze

  class ClassA < ParentClassA
    CONSTANT_CLASS_A = 'constant_1'.freeze
    include ModuleY
    prepend ModuleZ

    def self.another_test_method
      jard
    end

    def test_method
      a = CONSTANT_CLASS_A
      a = CONSTANT_PARENT_A_CALLED
      jard
      a = ClassB::CONSTANT_CLASS_B_CALLED # Not shown. Limit by now
      a = CONSTANT_MODULE_X_CALLED
      a = CONSTANT_MODULE_Y_CALLED
      a = CONSTANT_MODULE_Z_CALLED
      a = GLOBAL_CONSTANT_CALLED
      a = CONSTANT_MODULE_X               # Now shown. Limit by now
      a = TOPLEVEL_BINDING
      a = STDOUT
      a = $stdout
      a = $global1
      a = $global2
      jard
    end
  end
end

ModuleX::ClassA.new.test_method
ModuleX::ClassA.another_test_method
