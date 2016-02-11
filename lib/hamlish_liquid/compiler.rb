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

            inline_child = node.has_inline_children

            push ' '*indentation unless parent_on_same_line

            push node.preamble if node.preamble
            
            if node.respond_to? :inline_content
                push ' ' + node.inline_content + ' '
            else

                if inline_child
                    compile_recursive node.children[0], indentation, parent_on_same_line: true
                else
                    child_indentation = indentation
                    child_indentation += 2 if node.indent_children?
                    push "\n" unless node.children.empty?
                    node.children.each do |child|
                        compile_recursive child, child_indentation
                    end
                end
            end

            if node.postamble
                push ' '*indentation unless inline_child || node.children.empty?
                push node.postamble
            end
            
            push "\n" unless parent_on_same_line
            
            nil 
        end # def compile_recursive
    end # class Compiler
end # class 