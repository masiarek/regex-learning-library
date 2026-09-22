# Ruby HAS recursion. It just does not spell it (?R).
#
# Ruby's engine is Onigmo, which took its subroutine-call syntax from a
# different branch of the family than Perl did:
#
#   Perl / PCRE2     (?R)     (?1)      (?&name)
#   Onigmo / Ruby    \g<0>    \g<1>     \g<name>
#
# Ask Ruby for (?R) and it raises. Ask it for \g<0> and it recurses.

def compiles?(source)
  Regexp.new(source)
  "yes"
rescue RegexpError          # normalised on purpose: the message text moves
  "no"                      # between Ruby releases, the outcome does not
end

puts "does it COMPILE?"
[
  ['(?R)',    '\((?:[^()]|(?R))*\)'],
  ['(?1)',    '(\((?:[^()]|(?1))*\))'],
  ['(?&par)', '(?<par>\((?:[^()]|(?&par))*\))'],
  ['\g<0>',   '\((?:[^()]|\g<0>)*\)'],
  ['\g<1>',   '(\((?:[^()]|\g<1>)*\))'],
  ['\g<par>', '(?<par>\((?:[^()]|\g<par>)*\))'],
].each { |label, source| printf("  %-8s %s\n", label, compiles?(source)) }

SUBJECTS = ['(a(b)c)', '((a)(b))', '()', '(a(b)c', 'a'].freeze

# \g<0> is "call the whole pattern", so this one is unanchored and finds the
# leftmost balanced run.
whole = /\((?:[^()]|\g<0>)*\)/
puts "\n\\g<0>, unanchored"
SUBJECTS.each do |s|
  m = whole.match(s)
  printf("  %-10s %s\n", s, m ? "found '#{m[0]}'" : 'no match')
end

# The same trap Perl has: \g<0> re-runs the whole pattern, anchors included.
anchored_0 = /\A\((?:[^()]|\g<0>)*\)\z/
puts "\n\\A...\\g<0>...\\z -- the anchors are INSIDE the recursion"
SUBJECTS.each { |s| printf("  %-10s %s\n", s, anchored_0.match?(s) ? 'match' : 'no match') }

# \g<1> and \g<par> call one group, so the anchors stay outside.
anchored_1 = /\A(\((?:[^()]|\g<1>)*\))\z/
anchored_n = /\A(?<par>\((?:[^()]|\g<par>)*\))\z/
puts "\n\\g<1> and \\g<par>, anchored"
SUBJECTS.each do |s|
  printf("  %-10s by number %-9s by name %s\n", s,
         anchored_1.match?(s) ? 'match' : 'no match',
         anchored_n.match?(s) ? 'match' : 'no match')
end

puts "\nnesting depth, with the \\g<1> form"
[1, 10, 100, 1000].each do |depth|
  s = '(' * depth + 'a' + ')' * depth
  printf("  depth %-5d %s\n", depth, anchored_1.match?(s) ? 'match' : 'no match')
end
