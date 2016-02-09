require 'minitest/autorun'
require './hamlish_liquid'

module HamlishLiquid
    class Line
        def state
            {line_no: line_no, indentation: indentation, code: code}
        end
    end
end

include HamlishLiquid
include Node

# shortcut method
def p(source)
    HamlishLiquid.parse_source(source)
end

describe HamlishLiquid do
    it 'should parse nothing' do
        ret = p ''
        assert ret.is_a? Root
    end
    it 'should parse with no indentation' do
        ret = p '%div'
        assert ret.is_a? Root
        assert ret.children.length == 1
        div = ret.children[0]
        assert div.is_a? HtmlTag
        assert div.line.state == {line_no: 1, indentation: 0, code: "%div"}
    end
    it 'should parse two lines' do
        ret = HamlishLiquid.parse_source "%div\n%span"
    end
    it 'should parse with children' do
        ret = HamlishLiquid.parse_source "%ul\n %li\n %li"
    end
    it 'should parse liquid tag' do
        ret = HamlishLiquid.parse_source "-assign foo='monkey'\n"
    end
    it 'should parse output tag' do
        ret = HamlishLiquid.parse_source "\n\n= yolo\n\n"
    end
    it 'should parse liquid tag with children' do
        ret = HamlishLiquid.parse_source "-for i in [1,2,3]; = i | someFilter"
    end
    it 'should parse with inline content' do
        root = p "%span << %b"
        assert_equal 1, root.children.length
        span = root.children[0]
        expected = {line_no: 1, indentation: 0, code: "%span << %b"}
        assert_equal expected, span.line.state
        assert_equal 1, span.children.length
        b = span.children[0]
        assert_equal expected, b.line.state
    end
end