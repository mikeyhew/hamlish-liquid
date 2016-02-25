require 'test_helper'

class LineParserTest < Minitest::Test
    include HamlishLiquid

    def assert_parse_error(&block)
        assert_raises(Parslet::ParseFailed, &block)
    end
    
    def parser_from (sym)
        custom_class = Class.new(LineParser) { root sym }
        custom_class.new
    end
    
    def test_html_attr_value
        p = parser_from(:html_attr_value)
        assert_equal "''", p.parse("''")
        assert_equal "'yolo'", p.parse("'yolo'")
        assert_equal '"yolo"', p.parse('"yolo"')
        assert_parse_error { p.parse('"123') }
    end

    def test_html_attr
        p = parser_from(:html_attr)
        expected = {name: 'name', value: '"value"'}
        assert_equal expected, p.parse('name="value"')
    end

    def test_liquid_tag
        p = parser_from(:liquid_tag)
        expected = {:tag_name=>"for", :body=>"i in team"}
        assert_equal expected, p.parse('-for i in team')
        expected = {:tag_name=>"assign", :body=>"foo = \"bar\""}
        assert_equal expected, p.parse('-assign foo = "bar"')
    end

    def test_liquid_output
        p = parser_from(:line)
        assert_equal({:liquid_output=>{:body=>"whatup.foo"}}, p.parse('= whatup.foo'))
    end

    def test_line_segment
        p = parser_from(:line_segment)
        expected = {html_tag: {tag_name: "div"}}
        assert_equal expected, p.parse("%div")
        code = '%span class="1 2 " data-main="yolo"'
        expected =
            {html_tag: {
                tag_name: 'span',
                attrs: [
                    {name: 'class', value: '"1 2 "'},
                    {name: 'data-main', value: '"yolo"'}
                ]}}
        assert_equal expected, p.parse(code)

        assert_equal ({raw: 'yolo 123'}), p.parse('yolo 123')
    end

    def test_line
        p = parser_from(:line)
        assert p.parse('%div')
        assert p.parse('%div<<%yolo')
        assert p.parse('%ul << %li')
        
        expected = {:html_tag=>{:tag_name=>"div", :attrs=>{:name=>"attr", :value=>"\"value\""}}}
        assert_equal expected, p.parse('%div attr="value"')
        
        expected = [{:html_tag=>{:tag_name=>"div"}},
                    {:liquid_tag=>{:tag_name=>"for", :body=>"player in team "}},
                    {:raw=>"Player: {{player.name}}"}]
        assert_equal expected, p.parse("%div << - for player in team << Player: {{player.name}}")

        assert p.parse('-for i in yolo << %div attr="" << stuff')
    end

    def test_xml_name
        p = parser_from(:xml_name)
        assert_equal "dáta", p.parse('dáta')
    end
end