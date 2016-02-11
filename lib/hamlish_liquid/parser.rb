module HamlishLiquid
    class Parser

        def initialize(source)
            @source = source
            @lines = source.split('\n')
            @line_parser = LineParser.new
            @line_transform = LineTransform.new
        end

        def push(node)
            puts node
        end

        def parse
            @line_no = 0
            @lines.each do |line|
                
                @line_no += 1
                
                if line =~ TAB_IN_INDENTATION
                    raise "detected tab in indentation at line #{line_no}"
                end
                
                if line.strip.empty?
                    push :empty_line
                    next
                end

                tree = @line_parser.parse(line)
                segments = @line_transform.apply(tree)
                segments = [segments] unless segments.is_a? Array
                return segments
            end
        end
    end # class Compiler
end # module HamlishLiquid