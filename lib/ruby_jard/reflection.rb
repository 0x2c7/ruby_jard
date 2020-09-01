# frozen_string_literal: true

module RubyJard
  ##
  # User classes may override basic Kernel methods, such as #inspect
  # or #to_s, or even #is_a?. It's not very wise to call those methods
  # directly, as there maybe side effects. Therefore, this class is
  # to extract unbound methods from Kernel module, and then call them
  # in Object's context.
  class Reflection
    class << self
      def call_class(object)
        if call_is_a?(object, Module)
          bind_call(Kernel, :class, object)
        else
          instance_bind_call(Kernel, :class, object)
        end
      end

      def call_respond_to?(object, method_name)
        if call_is_a?(object, Module)
          bind_call(Kernel, :respond_to?, object, method_name)
        else
          instance_bind_call(Kernel, :respond_to?, object, method_name)
        end
      end

      def call_instance_variables(object)
        bind_call(Kernel, :instance_variables, object)
      end

      def call_instance_variable_get(object, variable)
        bind_call(Kernel, :instance_variable_get, object, variable)
      end

      def call_instance_variable_set(object, variable, value)
        bind_call(Kernel, :instance_variable_set, object, variable, value)
      end

      def call_inspect(object)
        if call_is_a?(object, Module)
          bind_call(Kernel, :inspect, object)
        else
          instance_bind_call(Kernel, :inspect, object)
        end
      end

      def call_to_s(object)
        if call_is_a?(object, Module)
          bind_call(Kernel, :to_s, object)
        else
          instance_bind_call(Kernel, :to_s, object)
        end
      end

      def call_is_a?(object, comparing_class)
        bind_call(Kernel, :is_a?, object, comparing_class)
      end

      def call_const_get(object, const_name)
        bind_call(Kernel, :const_get, object, const_name)
      end

      def call_const_defined?(object, const_name)
        bind_call(Kernel, :const_defined?, object, const_name)
      end

      def bind_call(owner, method_name, object, *args)
        @method_cache ||= {}
        @method_cache[owner] ||= {}
        @method_cache[owner][method_name] ||= fetch_method(owner, method_name)
        @method_cache[owner][method_name].bind(object).call(*args)
      end

      def instance_bind_call(owner, method_name, object, *args)
        @instance_method_cache ||= {}
        @instance_method_cache[owner] ||= {}
        @instance_method_cache[owner][method_name] ||= fetch_instance_method(owner, method_name)
        @instance_method_cache[owner][method_name].bind(object).call(*args)
      end

      def fetch_method(object, method_name)
        @method_cache ||= {}
        @method_cache[::Kernel] ||= {}
        @method_cache[::Kernel][:method] ||= ::Kernel.method(:method).unbind
        @method_cache[::Kernel][:method].bind(object).call(method_name).unbind
      end

      def fetch_instance_method(object, method_name)
        @method_cache ||= {}
        @method_cache[::Kernel] ||= {}
        @method_cache[::Kernel][:instance_method] ||= ::Kernel.method(:instance_method).unbind
        @method_cache[::Kernel][:instance_method].bind(object).call(method_name)
      end
    end
  end
end
