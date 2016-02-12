# Todo

- output html attributes
- add syntax improvements
    - `#` and `.` for id and class attributes
    - `div` shortcut when there's no tagname
    - consider changing attributes syntax to be like haml, with parentheses required for html-style attributes and support for ruby {foo: bar} and maybe {:foo => bar} syntax
    - with the haml style it would be possible to get rid of << syntax
    - %div= syntax (may be implemented by the above already)
- add doctype (`!!!`) syntax
- improve test coverage
    - parser tests for low-coverage areas like liquid output
    - compiler tests
    - tests for the above new syntax features when they are introduced
- improve error reporting. Parslet provides some good error information, we just need to use it.
- add support for self-closing liquid tags
- figure out a way to tell if a liquid tag is not self-closing
- possibly use liquid's tag registry for the above, and use their parsers to check for syntax errors in tags
