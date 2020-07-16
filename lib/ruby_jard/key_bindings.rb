# frozen_string_literal: true

module RubyJard
  ##
  # Register custom key bindings and corresponding action, try to
  # match a key binding sequence from input.
  # As this class is performant-sensitive, a lookup tree is built
  # and updated whenever a new key is added.
  class KeyBindings
    def initialize
      @key_bindings = []
      @indexes = {}
    end

    def to_a
      @key_bindings.dup
    end

    def push(sequence, action)
      if sequence.is_a?(Array)
        sequence.each { |s| push(s, action) }
        return
      end

      raise RubyJard::Error if sequence.to_s.empty?

      key_binding = RubyJard::KeyBinding.new(sequence, action)
      reindex(key_binding)
      @key_bindings << key_binding
    end

    def match(&read_key)
      raise RubyJard::Error, 'This method requires a block' unless block_given?

      buffer = ''
      node = @indexes
      loop do
        keys = read_key.call
        if keys.nil?
          # No more key. Match the current node
          if node[nil].nil?
            return buffer
          else
            return node[nil]
          end
        end

        buffer += keys
        keys.bytes.each do |byte|
          if node[byte].is_a?(Hash)
            # Not sure, continue to match
            node = node[byte]
          elsif node[byte].nil?
            # It's sure that no more bindings to match
            return buffer
          elsif buffer == node[byte].sequence
            # Exact match current key binding
            return node[byte]
          else
            return buffer
          end
        end
      end
    end

    private

    def reindex(key_binding)
      parent = nil
      node = @indexes
      bytes = key_binding.sequence.bytes
      bytes.each do |byte|
        if node[byte].nil?
          node[byte] = {}
        elsif node[byte].is_a?(KeyBinding)
          return if node[byte].sequence == key_binding.sequence

          # Propagate the tree node
          node[byte] = {
            nil => node[byte]
          }
        end
        parent = node
        node = node[byte]
      end

      if node.empty?
        parent[bytes.last] = key_binding
      else
        node[nil] = key_binding
      end
    end
  end
end
