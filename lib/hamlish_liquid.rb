require 'haml'

module HamlishLiquid

    class Parser < Haml::Parser
        
        # overriding this method to always return false will
        # disable #{} string interpolation in text,
        # at least for the current version of haml
        def contains_interpolation?(text)
            false
        end

        def tag(line)
            node = super(line)
            unless node.value[:attributes_hashes].empty?
                raise SyntaxError, "dynamic attribute values are currently unsupported. Use `attr='{{ value }}'`."
            end
            node
        end

        def silent_script(line)
            node = super(line)
            match = /\w+/.match line.text, 1
            raise SyntaxError, "failed to match liquid tag" unless match
            node.value[:keyword] ||= match[0]
            node
        end

        def script(line, escape_html = nil, preserve = false)
            raise SyntaxError, "!= and &= are unsupported" unless escape_html.nil?
            ParseNode.new(:script, line.index + 1, text: line.text, preserve: preserve)
        end
    end

    class Compiler < Haml::Compiler
        def compile_silent_script
            push_text '{% ' + @node.value[:text].strip + ' %}'
            tag_name = @node.value[:keyword]

            if block_given?
                # storing these values because they're needed if this
                # is an if/unless and there's else/elsif following
                @node.value[:dont_indent_next_line] = @dont_indent_next_line
                @node.value[:dont_tab_up_next_text] = @dont_tab_up_next_text
                yield
            end
            
            # TODO: push end#{tag_name} only if this is a block tag
            push_text '{% ' + 'end' + tag_name + ' %}'
        end

        def compile_script
            push_text '{{ ' + @node.value[:text].strip + ' }}'
        end
    end

    def self.render(text, options={})
        options[:parser_class] ||= Parser
        options[:compiler_class] ||= Compiler
        Haml::Engine.new(text, options).render
    end

end
