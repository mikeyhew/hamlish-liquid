# Using the haml gem to parse hamlish liquid

override methods:

- Compiler#compile_script()
- Compiler#compile_silent_script
This is where we output haml tags.
note: there is a :keyword key in @node.value, which is probably created by the parser. I should do a similar thing with a :tag_name key.
- Parser#silent_script(line)
- Parser#close_silent_script(_)


Stuff to check out
- &=, != should throw errors as they won't be supported
^ should be doable by raising if escape_html arg is not nil in Parser#script
- #{} interpolation should be disabled
^ can be solved, at least in the current version, by defining Parser#contains_interpolation? to always return false
- find out how ~ (whitespace preservation) works
^ looks like it just calls Parser#script with :preserve

More stuff to look at
- `@node.value[:keyword]` is an OK place to put the liquid tag name, but relying on haml to validate `elsif` and `else` seems too lucky to be true.
