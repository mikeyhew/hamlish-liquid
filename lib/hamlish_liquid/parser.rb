module HamlishLiquid

    class Parser
        
        INDENTATION = /\A\s*/
        TAB_IN_INDENTATION = /\A\s*\t/
        SPACE_IN_INDENTATION = /\A\s*[ ]/

        def initialize
            @line_parser = LineParser.new
            @line_transform = LineTransform.new
        end

        def parse(source)
            lines = source.split('\n')
            line_no = 0
            indent_stack = [-1]
            root = Node::Root.new
            block_stack = [root]
            lines.each do |line|
                
                line_no += 1
                
                line = line.rstrip

                if line =~ TAB_IN_INDENTATION
                    raise IndentationError, "detected tab in indentation at line #{line_no}"
                end
                
                if line.strip.empty?
                    next
                end

                # indentation: number of indent characters
                indentation = INDENTATION.match(line).offset(0)[1]

                if indentation > indent_stack.last
                    indent_stack.push indentation
                else
                    while indentation < indent_stack.last do
                        indent_stack.pop
                        block_stack.pop
                    end
                    # always pop the block stack unless we're going into
                    # further indentation
                    block_stack.pop
                end

                if indentation != indent_stack.last
                    raise IndentationError, "Unindent does not match any outer indentation level"
                end

                tree = @line_parser.parse(line)
                segments = @line_transform.apply(tree)
                segments = [segments] unless segments.is_a? Array
                
                block_stack.last.add_child(segments[0])
                
                parent = segments[0]
                segments[1..-1].each do |segment|
                    parent.has_inline_children = true
                    parent.add_child(segment)
                    parent = segment
                end
                
                # we push the last segment, so it will be
                # the one that gets the children
                block_stack.push(segments.last)
            end # lines.each
            root
        end # def parse
    end # class Compiler
end # module HamlishLiquid