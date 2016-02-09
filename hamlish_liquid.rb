module HamlishLiquid
    class Line
        attr_reader :indentation, :code, :line_no

        def initialize(text, line_no)
            text = text.rstrip
            whitespace_match =~ /^[\s]+/.match(text)
            if /\t/.match text && /[ ]/.match(text)
                error 'mixed tab and space indentation'
            end
            @line_no = line_no
            @indentation = whitespace_match ? whitespace_match[0].length : 0
            @code = text.slice(whitespace_match.length)
        end

        def error(message, offset=nil)
            # convert from 0-based to 1-based offset
            offset += 1
            maybe_offset = offset.nil? ? '' : ":#{offset}"
            raise "#{line_no}#{maybe_offset}: #{message}"
        end
    end

    def get_lines(source_lines, base_line_no: 0)
        line_no = base_line_no
        source_lines.lazy.map do |line_str|
            line_no += 1
            Line.new(line_str, line_no)
        end
    end

    def parse_source(source, base_line_no: 0)
        lines = get_lines(source.split("\n"), base_line_no: base_line_no)
        parse_lines(lines)
    end

    def parse_lines(lines)
        root = Node.new
        indent_stack = [-1]
        block_stack = [root]

        lines.each do |line|
            next unless line.code

            if line.indentation > indent_stack.last.indentation
                indent_stack.push line.indentation
            else
                while line.indentation < indent_stack.last.indentation
                    indent_stack.pop
                    block_stack.pop
                end
                if line.indentation > indent_stack.last.indentation
                    line.error 'Unindent does not match any outer indentation level'
                end
            end # if line.indentation...

            node = Node.from_line(line)
            # TODO: check if parent block can have child element
            block_stack.last.add_child node
            block_stack.push node
        end # lines.each do
    end # def parse_lines

    class Node
        def self.from_line(line)
            # offset is array of length 1 or 2
            offset = [0]
            nodes = []
            loop do
                case line.code[offset[0]]
                when '%', '-'
                    if sep_match = /\s*<<\s*/.match(line.code, offset[0])
                        separator_indices = sep_match.offset(0)
                        offset[1] = separator_indices[0]
                        next_offset = [separator_indices[1]+1]

                        case line.code[offset[0]]
                        when '%'
                            nodes.push HtmlTag.new(line, offset)
                        when '-'
                            nodes.push LiquidTag.new(line, offset)
                        else
                            raise :unreachable
                        end

                        if offset[1]
                            offset = next_offset
                            next
                        end
                    end
                when '='
                    nodes.push Output.new(line, offset)
                else
                    nodes.push PlainText.new(line, offset)
                end
                break
            end
            parent = nodes[0]
            nodes.slice(1).each do |node|
                parent.add_child node
                parent = node
            end
            nodes[0]
        end # def self.from_line

        class Base
            attr_reader :line, :children, :offset
            def initialize(line, offset)
                @line = line
                @offset = offset
            end

            def preamble
                nil
            end

            def postamble
                nil
            end

            # inline? decides if the node can have children,
            # and whether the preamble and postamble are on
            # separate lines from the content in pretty-printed html
            def inline?
                false
            end
        end # class Base

        class BlockEl < Base
            def initialize
                @children = []
            end

            def inline?
                false
            end

            def add_child(child_node)
                @children.push child_node
                self
            end
        end # class BlockEl

        class InlineEl < Base
            def inline?
                true
            end
        end

        class PlainText < BlockEl
            TODO
        end

        class Output < Base
            attr_reader :output_code

            def initialize(line)
                super
                @output_code = line.code.slice(1).lstrip
            end

            def inline
                true
            end

            def preamble
                '{{ '
            end

            def postamble
                ' }}'
            end

            def content
                @output_code
            end
        end # class Output

        class HtmlTag < BlockEl
            attr_reader :tag_name, :attrs
            def initialize(line)
                super

                tag_match = /[a-z]/.match(line.code.slice(1))
                line.error('bad or missing html tag name') unless tag_match
                @tag_name = tag_match[0]

                if tag_match.offset(0) < line.code.length
                    # there is more code after the tag name
                    @attrs = get_attrs(tag_match.offset(0))
                end
            end

            def preamble
                '<' + tag_name + '>'
            end

            def postamble
                '</' + tag_name + '>'
            end

        private

            def get_attrs(offset)
                TODO offset
            end
        end # class HtmlTag

        class LiquidTag < BlockEl
            attr_reader :tag_name, :args_string
            def initialize(line)
                super
                @tag_name = /[a-z]/.match(line.code.slice(1))[0]
                @args_string = code.slice(1 + @tag_name.length)
            end

            def preamble
                '{% ' + tag_name + args_string + ' %}'
            end

            def postamble
                '{% end' + tag_name + ' %}'
            end
        end # class LiquidTag
    end # class Node
end # module HamlishLiquid