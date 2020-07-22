# frozen_string_literal: true

module RubyJard
  ##
  # Abstract class of all color scheme.
  class ColorScheme
    def initialize(styles: self.class.const_get(:STYLES))
      @styles = {}
      styles.each do |element, element_styles|
        update(element, element_styles)
      end
    end

    ##
    # Fetch the styles for a particular element defined in the scheme.
    # This method returns an array of two or more elements:
    # - First element is foreground color
    # - Second element is background color
    # - The rest is decorating items, such as underline, italic
    def styles_for(element)
      @styles[element].dup
    end

    def update(element, styles)
      @styles[element] = styles
    end
  end
end
