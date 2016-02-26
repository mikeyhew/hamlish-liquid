require 'test_helper'

class HamlishTest < Minitest::Test

    def test_basic
        assert_equal "foo", render('foo').strip
    end

    def test_no_liquid
        filename = 'test/test_no_liquid.liquid.haml'
        html = render(File.read(filename), filename: filename)
        assert_equal File.read(filename[0..-6]), html
    end
end