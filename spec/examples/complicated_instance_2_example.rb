# frozen_string_literal: true

module ModuleX
  @module_variable_3 = 3
  @module_variable_4 = 4
  def self.super_method
    @module_variable_5 = 5
    jard
    @module_variable_6 = 6
    @module_variable_2 = 2
  end
end

module ModuleY
  @class_variable_4 = 4
  @class_variable_5 = 5
end

module ModuleZ
  @class_variable_6 = 6
  @class_variable_7 = 7
end

class ParentClassA
  def self.hyper_method
    jard
  end

  def initialize
    @instance_3 = 3
    @instance_4 = 3
  end

  def parent_method
    @instance_6 = 6
    jard
    @instance_7 = 7
    @instance_2 = 2
  end
end
