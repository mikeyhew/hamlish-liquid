require 'test_helper'

class ParserTest < MiniTest::Test
    include HamlishLiquid
    def test_parse_basic
        puts Parser.new('%div << %ul style= "foo"').parse.to_s
    end
end