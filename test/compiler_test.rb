require 'test_helper'

class CompilerTest < Minitest::Test
    include HamlishLiquid

    def test_compile
        p = Parser.new
        puts Compiler.new(p.parse('%div')).compile
        puts Compiler.new(p.parse('%div << %yolo')).compile
        puts Compiler.new(p.parse('%div\n %ul attr="value"\n  %li << Content')).compile
        puts Compiler.new(p.parse('-for i in team\n Whatup')).compile
    end
end