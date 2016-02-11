module HamlishLiquid
    class Compiler
        
        def initialize(root, options={})
            @root = root
            @options = options
        end

        def compile
            unless @output
                @output = []
                compile_recursive(@root, @options[:base_indentation] || 0)
            end
            @output.join('')
        end

    private

        def push(*strings)
            strings.each do |string|
                @output.push(string)
            end
            self
        end

        def compile_recursive(node, indentation, parent_on_same_line: false)
            raise if node.children.nil?
            
            if node.respond_to? :inline_content
                push ' '*indentation unless parent_on_same_line
                push node.preamble + ' ' if node.preamble
                push node.inline_content
                push ' ' + node.postamble if node.postamble
                push "\n" unless parent_on_same_line
                return
            end

            inline_child = node.has_inline_children

            push ' '*indentation unless parent_on_same_line

            if inline_child
                push node.preamble if node.preamble
                compile_recursive node.children[0], indentation, parent_on_same_line: true
            else
                if node.preamble
                    push node.preamble
                    push "\n" unless node.children.empty? 
                end

                child_indentation = indentation
                child_indentation += @options[:indent_width] || 2 if node.indent_children?
                node.children.each do |child|
                    compile_recursive child, child_indentation
                end
            end

            if node.postamble
                push ' '*indentation unless inline_child || node.children.empty?
                push node.postamble
            end
            
            push "\n" unless parent_on_same_line || node == @root
            
            return
        end # def compile_recursive
    end # class Compiler
end # class 