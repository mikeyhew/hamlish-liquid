module HamlishLiquid

    INDENTATION = /\A\s*/
    TAB_IN_INDENTATION = /\A\s*\t/
    SPACE_IN_INDENTATION = /\A\s*[ ]/



    # # parses the source and returns a node tree, starting with
    # # a Node::Root
    # def self.parse(source, base_line_no: 0)
    #     line_no = base_line_no
    #     lines = source.split("\n").map do |text|
    #         line_no += 1
    #         Line.new(line_no, text)
    #     end
    #     parse_lines(lines)
    # end

    # def self.parse_lines(lines)
    #     root = Node::Root.new
    #     indent_stack = [-1]
    #     block_stack = [root]
    #     space_or_tab_indent

    #     lines.each do |line|

    #         next if line.code.empty?

    #         if line.indentation > indent_stack.last
    #             indent_stack.push line.indentation
    #         else
    #             while line.indentation < indent_stack.last
    #                 indent_stack.pop
    #                 block_stack.pop
    #             end
    #             if line.indentation > indent_stack.last
    #                 line.error 'Unindent does not match any outer indentation level'
    #             end
    #         end # if line.indentation...

    #         node = Node.from_line(line)
    #         # TODO: check if parent block can have child element
    #         block_stack.last.add_child node
    #         block_stack.push node
    #     end # lines.each do
    #     root
    # end # def parse_lines

end # module HamlishLiquid

require 'hamlish_liquid/line_parser'
require 'hamlish_liquid/node'
require 'hamlish_liquid/line_transform'
require 'hamlish_liquid/parser'