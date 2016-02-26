require 'haml/exec'
module HamlishLiquid
    class Exec < Haml::Exec::Haml
        def initialize(args)
            super
            @options[:for_engine][:parser_class] = HamlishLiquid::Parser
            @options[:for_engine][:compiler_class] = HamlishLiquid::Compiler
        end
    end
end