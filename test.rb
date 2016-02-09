require 'minitest/autorun'
require './hamlish_liquid'

describe HamlishLiquid do
    it 'should parse nothing' do
        ret = HamlishLiquid.parse_source ''
    end
    it 'should parse with no indentation' do
        ret = HamlishLiquid.parse_source '%div'
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
end