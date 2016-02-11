require 'parslet'
module HamlishLiquid
    class LineTransform < Parslet::Transform
        include Node
        rule(:html_tag => subtree(:tree))       { HtmlTag.new(tree) }
        rule(:liquid_tag => subtree(:tree))     { LiquidTag.new(tree) }
        rule(:liquid_output => subtree(:tree))  { LiquidOutput.new(tree) }
        rule(:raw => subtree(:text))            { Raw.new(text) }
        rule(:comment => simple(:text))        { Comment.new(text) }
    end
end