module HamlishLiquid

    class HamlishLiquidError < RuntimeError 
    end
    class SyntaxError < HamlishLiquidError
        def initialize(message, line_no, col=nil)
            maybe_col = col ? ":#{col}" : ''
            super "#{line_no}#{maybe_col}: #{message}"
        end
    end
    class IndentationError < SyntaxError
    end


    require 'hamlish_liquid/line_parser'
    require 'hamlish_liquid/node'
    require 'hamlish_liquid/line_transform'
    require 'hamlish_liquid/parser'
    require 'hamlish_liquid/compiler'

    def self.compile(source)
        Compiler.new(Parser.new.parse(source)).compile
    end

end # module HamlishLiquid