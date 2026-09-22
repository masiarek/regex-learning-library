# In Ruby, `^` and `$` are LINE anchors. Always. There is no flag involved and
# no flag that turns it off -- Ruby's /m is the dot flag, which everyone else
# spells /s. So `^\d+$` in Ruby asks "is any LINE of this string all digits?"

SUBJECTS = ["1", "1\n", "1\nrm -rf /"].freeze

def row(label, a, b, c)
  puts label.ljust(30) + a.ljust(8) + b.ljust(8) + c
end

def verdicts(re)
  SUBJECTS.map { |s| re.match?(s) ? "match" : "no" }
end

puts "ruby"
row("pattern", '"1"', '"1\n"', '"1\nrm -rf /"')
row('/^\d+$/',      *verdicts(/^\d+$/))
row('/\A\d+\z/',    *verdicts(/\A\d+\z/))
row('/\A\d+\Z/',    *verdicts(/\A\d+\Z/))
row('/(?-m)^\d+$/', *verdicts(/(?-m)^\d+$/))

# What the first row means for a caller: the pattern said yes, and the value it
# said yes about still has a second line in it.
puts
m = /^\d+$/.match("1\nrm -rf /")
puts %(/^\\d+$/ matched #{m[0].inspect} inside a #{"1\nrm -rf /".length}-char subject)

# The flag letters. Ruby's /m is the DOT flag. Turning it off with (?-m), the
# spelling that disables the line-anchor flag in Perl and Python, changes
# nothing about ^ and $ -- there is nothing there to disable.
puts
row("flag", "none", "/m", "(?-m)")
row('^\d+$ on "1\nrm -rf /"',
    (/^\d+$/.match?("1\nrm -rf /") ? "match" : "no"),
    (/^\d+$/m.match?("1\nrm -rf /") ? "match" : "no"),
    (/(?-m)^\d+$/.match?("1\nrm -rf /") ? "match" : "no"))
row('a.b on "a\nb"',
    (/a.b/.match?("a\nb") ? "match" : "no"),
    (/a.b/m.match?("a\nb") ? "match" : "no"),
    (/(?-m)a.b/m.match?("a\nb") ? "match" : "no"))

# What (?-m) actually cancelled: the dot flag, on a regexp that had /m set.
# And the proof that ^ is a line anchor with no flag at all -- put the payload
# first and the digits last, and ^ still finds them while \A does not.
puts
puts 'on "rm -rf /\n1":'
[['/^\d+$/', /^\d+$/], ['/\A\d+$/', /\A\d+$/]].each do |label, re|
  puts "  " + label.ljust(28) + (re.match?("rm -rf /\n1") ? "match" : "no")
end
