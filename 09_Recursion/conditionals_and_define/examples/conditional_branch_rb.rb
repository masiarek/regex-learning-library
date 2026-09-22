# Ruby's Onigmo HAS conditionals -- by number and by (?(<name>)...) -- and
# nothing else from the family.
#
# Ruby's RegexpError messages are not printed here, only fixed labels chosen in
# this file, so the recorded key does not depend on which Ruby ran it.

SUBJECTS = ["<tag>", "tag", "<tag"].freeze

def row(label, pattern)
  rx = Regexp.new(pattern)
  cells = SUBJECTS.map { |s| format("%-7s", rx.match?(s) ? "yes" : "no") }.join
  puts format("%-30s %s", label, cells).rstrip
rescue RegexpError
  puts format("%-30s compile error", label)
end

puts format("%-30s %-7s%-7s%-7s", "", "<tag>", "tag", "<tag").rstrip

# The classic use: an optional opening delimiter that makes the closing one
# mandatory.
row("numbered   (?(1)>)", '\A(<)?\w+(?(1)>)\z')

# Onigmo takes the angle-bracket spelling, the one Perl and PCRE2 take.
row("named      (?(<open>)>)", '\A(?<open><)?\w+(?(<open>)>)\z')

# ...and not Python's bare-name spelling.
row("named      (?(open)>)", '\A(?<open><)?\w+(?(open)>)\z')

# ...and not a lookaround as the condition.
row("lookaround (?(?=<)...|...)", '\A(?(?=<)<\w+>|\w+)\z')

# ...and not DEFINE, even though Ruby has the subroutine calls \g<name> that
# would use it.
row("DEFINE     (?(DEFINE)...)", '(?(DEFINE)(?<octet>\d))\A\g<octet>\z')

puts

# A condition naming a group that is not in the pattern: Ruby refuses at compile
# time, where Perl compiles it and quietly takes the no-branch.
begin
  Regexp.new('\A(a)(?(2)x|y)\z')
  puts "(a)(?(2)x|y) with no group 2: compiled"
rescue RegexpError
  puts "(a)(?(2)x|y) with no group 2: compile error"
end

# And Ruby has no recursion condition at all, so a group really named R is
# simply a group named R -- but only in the angle-bracket spelling.
begin
  Regexp.new('\A(?<R>x)(?(R)y|n)\z')
  puts "(?<R>x)(?(R)y|n):             compiled"
rescue RegexpError
  puts "(?<R>x)(?(R)y|n):             compile error"
end
rx = Regexp.new('\A(?<R>x)(?(<R>)y|n)\z')
["xy", "xn"].each do |s|
  puts format("(?<R>x)(?(<R>)y|n) on %-3s %s", s, rx.match?(s) ? "yes" : "no")
end
