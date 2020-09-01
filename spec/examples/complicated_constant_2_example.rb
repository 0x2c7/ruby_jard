# frozen_string_literal: true

$global2 = 'global2'
$global3 = 'global3'

GLOBAL_CONSTANT_CALLED = 'global_constant_called'.freeze
GLOBAL_CONSTANT_NOT_CALLED = 'global_constant_not_called'.freeze

module ModuleX
  CONSTANT_MODULE_X_CALLED = 'constant_module_called'.freeze
  CONSTANT_MODULE_X_NOT_CALLED = 'constant_module_not_called'.freeze

  class ClassB
    CONSTANT_CLASS_B_CALLED = 'constant_class_b_called'.freeze
    CONSTANT_CLASS_B_NOT_CALLED = 'constant_class_b_not_called'.freeze
  end
end

module ModuleY
  CONSTANT_MODULE_Y_CALLED = 'constant_module_y_called'.freeze
  CONSTANT_MODULE_Y_NOT_CALLED = 'constant_module_y_not_called'.freeze
end

module ModuleZ
  CONSTANT_MODULE_Z_CALLED = 'constant_module_z_called'.freeze
  CONSTANT_MODULE_Z_NOT_CALLED = 'constant_module_z_not_called'.freeze
end
class ParentClassA
  CONSTANT_PARENT_A_CALLED = 'constant_parent_a_called'.freeze
  CONSTANT_PARENT_A_NOT_CALLED = 'constant_parent_a_not_called'.freeze
end
