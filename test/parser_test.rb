require 'test_helper'

class ParserTest < MiniTest::Test
    include HamlishLiquid
    def test_parse_basic
        assert Parser.new.parse('%div << %ul style= "foo"')
    end
end