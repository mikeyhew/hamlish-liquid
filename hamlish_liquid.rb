module HamlishLiquid
    class Line
        attr_reader :line_no, :indentation, :code

        def self.from_source_line(line_no, text)
            text = text.rstrip
            whitespace_match = /^[\s]+/.match text
            if text =~ /\t/ && text =~ /\t/
                error 'mixed tab and space indentation'
            end
            indentation = whitespace_match ? whitespace_match[0].length : 0
            code = text[indentation..-1]
            new line_no, indentation, code
        end

        def initialize(line_no, indentation, code)
            @line_no = line_no
            @indentation = indentation
            @code = code
        end

        def error(message, offset=nil)
            # offset is an array with [start, stop]
            # stop is optional
            # 
            unless offset.nil?
                start = offset[0] + 1 + indentation
                if offset[1]
                    stop = offset[1] + indentation
                else
                    stop = code.length + indentation
                end
            end
            maybe_offset = offset.nil? ? '' : ":#{start}-#{stop}"
            raise "#{line_no}#{maybe_offset}: #{message}"
        end

        def code_from_offset(offset)
            # ruby ranges are inclusive, not like
            # python or javascript slices
            code[offset[0]..(offset[1] - 1 || -1)]
        end
    end

    def self.get_lines(source_lines, base_line_no: 0)
        line_no = base_line_no
        source_lines.map do |line_str|
            line_no += 1
            Line.from_source_line(line_no, line_str)
        end
    end

    def self.parse_source(source, base_line_no: 0)
        lines = get_lines(source.split("\n"), base_line_no: base_line_no)
        parse_lines(lines)
    end

    def self.parse_lines(lines)
        root = Node::Root.new
        indent_stack = [-1]
        block_stack = [root]

        lines.each do |line|
            next if line.code.empty?

            if line.indentation > indent_stack.last
                indent_stack.push line.indentation
            else
                while line.indentation < indent_stack.last
                    indent_stack.pop
                    block_stack.pop
                end
                if line.indentation > indent_stack.last
                    line.error 'Unindent does not match any outer indentation level'
                end
            end # if line.indentation...

            node = Node.from_line(line)
            # TODO: check if parent block can have child element
            block_stack.last.add_child node
            block_stack.push node
        end # lines.each do
        root
    end # def parse_lines

    module Node
        def self._node_type_from_first_char(char)
            case char
                when '%' then HtmlTag
                when '-' then LiquidTag
                when '=' then Output
                else require 'pry'; binding.pry; PlainText
            end
        end

        def self.from_line(line)
            raise if line.code.empty?
            nodes = []
            chunks = line.code.split '<<'
            offset_start = 0
            chunks.each do |chunk|
                offset_end = offset_start + chunk.length
                offset = [offset_start, offset_end]
                if chunk.strip.empty?
                    line.error('line ends with inline data separator (<<)', offset)
                end
                code = line.code_from_offset(offset)
                node_type = _node_type_from_first_char code.lstrip[0]
                node = node_type.new(line, offset)
                nodes.push(node)
                # increment offset for '<<'
                offset_start = offset_end + '<<'.length
            end
            parent = nodes[0]
            nodes[1..-1].each do |node|
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

            def add_child(child_node)
                @children ||= []
                @children.push child_node
                self
            end

            def preamble
                nil
            end

            def postamble
                nil
            end
        end

        class BlockEl < Base
        end # class BlockEl

        class InlineEl < Base
            def add_child(child_node)
                child_node.line.error(
                    "Node::#{self.class.name} " +
                    "is inline and may not have children",
                    child_node.offset
                )
            end

            def inline_content
                nil
            end
        end

        class Root < Base
            def initialize
                @children = []
            end

            def add_child(child_node)
                @children.push child_node
                self
            end
        end

        class PlainText < BlockEl
            def initialize
                raise 'TODO'
            end
        end

        class Output < InlineEl

            def initialize(line, offset)
                super
                raise unless line.code[offset[0]] == '='
            end

            def output_code
                line.code_from_offset(offset)[1..-1].lstrip
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

            def inline_content
                output_code
            end
        end # class Output

        class HtmlTag < BlockEl
            attr_reader :tag_name, :attrs
            def initialize(line, offset)
                super
                code = line.code_from_offset(offset).rstrip
                tag_match = /\s*([a-z]+)(\s|\z)/.match(
                    code,
                    1 # skip '%' character
                )
                line.error('bad or missing html tag name') unless tag_match
                @tag_name = tag_match[1]
                index_after_tag = tag_match.offset(1)[1]

                if  index_after_tag < code.length
                    # there is more code after the tag name
                    require 'pry'; binding.pry
                    @attrs = get_attrs(index_after_tag)
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
            def initialize(line, offset)
                super
                @tag_name = /[a-z]/.match(line.code, 1)[0]
                @args_string = line.code[1 + @tag_name.length..-1]
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