require 'parslet'

module HamlishLiquid
    class LineParser < Parslet::Parser
        
        # HTML tags

        rule(:html_tag_start)   { str('%') }
        
        rule(:html_tag_name)    { match['a-zA-Z'] >> match['a-zA-Z0-9'].repeat(1) }
        
        rule(:html_attr_name)   { match['a-z'] >> match['a-z\-'].repeat(0) }
        
        rule(:html_attr_value_single_quoted) \
                                { str('\'') >> match['^\'\n'].repeat(0) >> str('\'') }
        
        rule(:html_attr_value_double_quoted) \
                                { str('"') >> match['^"\n'].repeat(0) >> str('"') }
        
        rule(:html_attr_value)  { html_attr_value_double_quoted | html_attr_value_single_quoted }
        
        rule(:html_attr)        { html_attr_name.as(:name) >> space? >> str('=') >> space? >> html_attr_value.as(:value) }
        
        rule(:html_attr_list)   { html_attr >> (space >> html_attr).repeat(0) } 
        
        rule(:html_tag)         { html_tag_start >> space? >> html_tag_name.as(:tag_name) >> (space >> html_attr_list.as(:attrs)).maybe }

        # Liquid Tags ( {% %} )

        rule (:liquid_tag_start)    { str('-') }
        
        rule (:liquid_tag_name)     { match['a-zA-Z_'] >> match('\w').repeat(0) }
        
        rule (:liquid_tag_body)     { (end_of_line_segment.absent? >> any).repeat(0) }
        
        rule (:liquid_tag)          { liquid_tag_start >> space? >> liquid_tag_name.as(:tag_name) >> space? >> liquid_tag_body.maybe.as(:body) }

        # Liquid Output ( {{ }} )
        # will match until end of line (so no inline children with << )

        rule (:liquid_output_start) { str('=') }

        rule (:liquid_output_body)  { (end_of_line.absent? >> any).repeat(0) }

        rule (:liquid_output)       { liquid_output_start >> space? >> liquid_output_body.as(:body) }

        # raw html/text
        # will match until the end of the line, so you can't have inline children with <<

        rule(:raw)                  { (end_of_line.absent? >> any).repeat(1) }

        # comments
        # matches to end of line
        rule(:comment_start)        { str(";")}
        rule(:comment)         { comment_start >> space? >> (end_of_line.absent? >> any).repeat(0).as(:comment)}

        # Allow inline children with <<

        rule(:line_segment)         { comment | html_tag.as(:html_tag) | liquid_tag.as(:liquid_tag) | liquid_output.as(:liquid_output) | raw.as(:raw) }
        
        # Line - the root element    
        rule(:line)                 { space? >> line_segment >> (space? >> str('<<') >> space? >> line_segment).repeat(0) }
        
        # helpers

        rule(:space)                { match('\s').repeat(1) }
        
        rule(:space?)               { space.maybe }
        
        rule(:end_of_line)          { str('\n') | any.absent? }

        rule(:end_of_line_segment)  { str('<<') | end_of_line }

        root :line
    end # class LineParser
end # module HamlishLiquid