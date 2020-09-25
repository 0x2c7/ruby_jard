# frozen_string_literal: true

require 'tty-markdown'
require 'ruby_jard'
require 'uri'

class JardDocConverter < TTY::Markdown::Converter
  def convert_hr(_el, _opts)
    width = 30 - @symbols[:diamond].length * 2
    line = @symbols[:diamond] + @symbols[:line] * width + @symbols[:diamond]
    @pastel.decorate(line, *@theme[:hr]) + NEWLINE
  end
end

class JardDocGenerator
  include TTY::Markdown

  def self.parse(source)
    convert_options = { width: 999, indent: 2, theme: THEME,
                        mode: 256, symbols: TTY::Markdown::SYMBOLS,
                        input: 'KramdownExt', enabled: true }
    doc = Kramdown::Document.new(source, convert_options)
    transform_children(doc.root)
    JardDocConverter.convert(doc.root, doc.options).join
  end

  def self.transform_children(node)
    node.children =
      node.children.map do |children_node|
        case children_node.type
        when :html_element
          children_node unless %w[LinkedImage].include? children_node.value
        when :p
          case children_node.children.first.value
          when /id: ?([a-z-]+).*(slug:.*)?/
            nil
          when /import.*from.*/
            nil
          else
            children_node.children = transform_children(children_node)
            children_node
          end
        when :hr
          nil
        when :a
          if children_node.attr['href'].to_s =~ %r{^/docs.*}
            children_node.attr['href'] =
              if children_node.attr['href'] =~ %r{^/docs/commands/(.*)}
                Regexp.last_match(1)
              else
                URI.join('https://rubyjard.org', children_node.attr['href']).to_s
              end
          end
          children_node
        else
          children_node.children = transform_children(children_node)
          children_node
        end
      end.compact
  end
end

doc_dir = File.expand_path(File.join('../website/docs/commands/'), File.dirname(__FILE__))
rendered_dir = File.expand_path(File.join('../lib/ruby_jard/commands/'), File.dirname(__FILE__))
docs = Dir[File.join(doc_dir, '*.md')]

failures = []

docs.each do |doc|
  matches = %r{.*/commands/(.*)\.md$}.match(doc)
  command = matches[1]
  rendered_doc = File.join(rendered_dir, "#{command}_command.doc.txt")
  new_content = JardDocGenerator.parse(File.read(doc))
  if ARGV.empty? || ARGV.first == 'generate'
    puts "Rendering \e[33m#{command}\e[0m to \e[33m#{rendered_doc}\e[0m"
    File.write(rendered_doc, new_content)
  else
    puts "Checking \e[33m#{command}\e[0m in \e[33m#{rendered_doc}\e[0m"
    unless File.exist?(rendered_doc)
      failures << command
      puts "\e[31m=> Not existed\e[0m"
      next
    end
    rendered_content = File.read(rendered_doc)
    if rendered_content == new_content
      puts "\e[32m=> OK\e[0m"
    else
      failures << command
      puts "\e[31m=> Failed\e[0m"
    end
  end
end

exit(1) unless failures.empty?
