# frozen_string_literal: true
#
# Ruby's flag letters. The headline is the collision: Ruby's /m is everyone
# else's /s, and Ruby has no letter at all for "line anchors" because ^ and $
# are line anchors already.
#
# No version, path or error text is printed, so Ruby 3.4 and Ruby 4.0 produce
# byte-identical output.

THREE = "one\ntwo\nthree"
CRLF = "abc\r\ndef"

def esc(str)
  '"' + str.gsub("\\", "\\\\\\\\").gsub("\n", '\\n').gsub("\r", '\\r') + '"'
end

def show(label, regexp, subject)
  m = regexp.match(subject)
  printf("  %-30s %s\n", label, m ? "match #{esc(m[0])}" : 'no match')
end

# Ruby has no /s letter at all, and (?s) is not one of its inline options. A
# literal /one.two/s would not compile, so the string form is the only way to
# ask the question at run time. The refusal is reported as a fixed label.
def try_string(label, source, subject)
  show(label, Regexp.new(source), subject)
rescue RegexpError
  printf("  %-30s compile error\n", label)
end

puts '== the dot: what it excludes =='
puts "subject #{esc("one\ntwo")}"
show('/one.two/', /one.two/, "one\ntwo")
show('/one.two/m', /one.two/m, "one\ntwo")
show('/(?m)one.two/', /(?m)one.two/, "one\ntwo")
try_string('"(?s)one.two"', '(?s)one.two', "one\ntwo")
puts "subject #{esc("one\rtwo")}"
show('/one.two/', /one.two/, "one\rtwo")

puts '== the letter m is NOT multiline here =='
puts "subject #{esc(THREE)}"
show('/^two$/   no flag', /^two$/, THREE)
show('/^two$/m', /^two$/m, THREE)
puts "subject #{esc(CRLF)}"
show('/^abc$/', /^abc$/, CRLF)
show('/^abc\r?$/', /^abc\r?$/, CRLF)

puts '== free-spacing: /x =='
ugly = /(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])/
tidy = /
  (\d{4})                    # year
  -
  (0[1-9] | 1[0-2])          # month, 01-12
  -
  (0[1-9] | [12]\d | 3[01])  # day, 01-31
/x
show('one line', ugly, 'due 2026-09-22 ok')
show('/x', tidy, 'due 2026-09-22 ok')
show("/a b/x  on #{esc('a b')}", /a b/x, 'a b')
show("/a b/x  on #{esc('ab')}", /a b/x, 'ab')
show("/a\\ b/x on #{esc('a b')}", /a\ b/x, 'a b')
show("/a#b/x  on #{esc('a#b')}", /a#b/x, 'a#b')

puts '== inline and scoped modifiers =='
show('/abc/           on ABC', /abc/, 'ABC')
show('/abc/i          on ABC', /abc/i, 'ABC')
show('/(?i)abc/       on ABC', /(?i)abc/, 'ABC')
show('/(?i:b)c/       on Bc', /(?i:b)c/, 'Bc')
show('/(?i:b)c/       on bC', /(?i:b)c/, 'bC')
show('/(?i)ab(?-i:cd)/ on ABcd', /(?i)ab(?-i:cd)/, 'ABcd')
show('/(?i)ab(?-i:cd)/ on ABCD', /(?i)ab(?-i:cd)/, 'ABCD')
show('/a(?i)bc/       on aBC', /a(?i)bc/, 'aBC')
show('/a(?i)bc/       on ABC', /a(?i)bc/, 'ABC')
show('/(a(?i)b)c/     on aBc', /(a(?i)b)c/, 'aBc')
show('/(a(?i)b)c/     on abC', /(a(?i)b)c/, 'abC')
