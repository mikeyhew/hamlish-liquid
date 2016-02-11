module HamlishLiquid
    module Node

        class Base
            attr_reader :children
            attr_accessor :has_inline_children

            def initialize(*)
                has_inline_children = false
                @children = []
            end

            def add_child(child_node)
                @children.push child_node
                self
            end

            def preamble
                nil
            end

            def postamble
                nil
            end

            def indent_children?
                true
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
                raise 'Abstact Method'
            end
        end

        class Root < Base
            def indent_children?
                false
            end
        end

        class Raw < BlockEl
            attr_reader :text
            
            def initialize(text)
                super
                @text = text
            end

            def preamble
                text
            end
        end

        class LiquidOutput < InlineEl
            attr_reader :body
            def initialize(tree)
                super
                @body = tree[:body]
                @body = nil if @body == []
            end

            def preamble
                '{{ '
            end

            def postamble
                ' }}'
            end

            def inline_content
                body
            end
        end # class Output

        class HtmlTag < BlockEl
            attr_reader :tag_name, :attrs
            
            def initialize(tree)
                super
                @tag_name = tree[:tag_name]
                @attrs = tree[:attrs]
                # can be nil but not empty
                raise if attrs && attrs.empty?
            end

            def preamble
                "<#{tag_name}>"
            end

            def postamble
                "</#{tag_name}>"
            end
        end # class HtmlTag

        class LiquidTag < BlockEl
            attr_reader :tag_name, :body
            def initialize(tree)
                super
                @tag_name = tree[:tag_name]
                @body = tree[:body]
                @body = nil if @body && @body.length == 0
            end

            def preamble
                "{% #{tag_name} #{body} %}"
            end

            def postamble
                "{% end#{tag_name} %}"
            end
        end # class LiquidTag
    end # module Node
end # module HamlishLiquid