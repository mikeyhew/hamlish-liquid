require 'parslet'

module HamlishLiquid
    class LineParser < Parslet::Parser
        
        rule(:xml_name_start_char)   { match[":A-Z_a-z\u{C0}-\u{D6}\u{D8}-\u{F6}\u{F8}-\u{2FF}\u{370}-\u{37D}\u{37F}-\u{1FFF}\u{200C}-\u{200D}\u{2070}-\u{218F}\u{2C00}-\u{2FEF}\u{3001}-\u{D7FF}\u{F900}-\u{FDCF}\u{FDF0}-\u{FFFD}\u{10000}-\u{EFFFF}"]}

        rule(:xml_name_char)         { xml_name_start_char | match["\-.0-9\u{B7}\u{0300}-\u{036F}\u{203F}-\u{2040}"]}

        rule(:xml_name)              { xml_name_start_char >> xml_name_char.repeat(0) }

        # HTML tags

        rule(:html_tag_start)   { str('%') }
        
        rule(:html_tag_name)    { xml_name }
        
        rule(:html_attr_name)   { xml_name }
        
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