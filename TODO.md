- output html attributes
- add syntax improvements
    - `#` and `.` for id and class attributes
    - `div` shortcut when there's no tagname
    - consider changing attributes syntax to be like haml, with parentheses required for html-style attributes and support for ruby {foo: bar} and maybe {:foo => bar} syntax
    - with the haml style it would be possible to get rid of << syntax
    - %div= syntax (may be implemented by the above already)
- improve test coverage
    [ ] parser tests for low-coverage areas like liquid output
    [ ] compiler tests
    [ ] tests for the above new syntax features when they are introduced