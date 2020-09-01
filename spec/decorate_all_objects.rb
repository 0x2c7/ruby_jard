# frozen_string_literal: true

#rubocop:disable all
# Fetch all objects from ObjectSpace, and decorate them, compare with the native inspection
def decorate_all_objects
  $objects = {}

  ObjectSpace.each_object do |object|
    $objects[object.class] ||= []
    if $objects[object.class].length < 5
      $objects[object.class] << object
    end
  end

  inspection_decorator = RubyJard::Decorators::InspectionDecorator.new
  color_decorator = RubyJard::Decorators::ColorDecorator.new(RubyJard::ColorSchemes::DeepSpaceColorScheme.new)
  $objects.each do |class_name, items|
    puts "====== #{class_name} ======"
    items.each do |item|
      puts "\t=== Jard Inpsect"
      begin
        lines = inspection_decorator.decorate_multiline(item, first_line_limit: 120, line_limit: 80, lines: 7)

        lines.each do |line|
          content = line.map { |span| color_decorator.decorate(span.styles, span.content) }.join
          puts "\t#{content}"
        end
      rescue StandardError, SystemStackError => e
        puts "\t#{e}"
      end
      puts "\t=== Default Inpsect"
      puts "\t#{item.inspect[0..120]}"
    end
  end
  nil
end
#rubocop:enable all
