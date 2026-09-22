# What \w, \d, \s and \b match in Ruby -- where \w and \b do not agree with
# each other, and [[:word:]] is not a synonym for \w.
#
# Every character is built from its code point, never written literally, so this
# file and everything it prints are pure ASCII.

PROBES = [
  ["U+0041 LATIN CAPITAL LETTER A", 0x0041],
  ["U+00E9 LATIN SMALL LETTER E WITH ACUTE", 0x00E9],
  ["U+0301 COMBINING ACUTE ACCENT", 0x0301],
  ["U+0660 ARABIC-INDIC DIGIT ZERO", 0x0660],
  ["U+FF11 FULLWIDTH DIGIT ONE", 0xFF11],
  ["U+00A0 NO-BREAK SPACE", 0x00A0],
  ["U+3000 IDEOGRAPHIC SPACE", 0x3000]
].freeze

def ch(cp) = [cp].pack("U")

# "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
SUBJECT = "na" + ch(0x00EF) + "ve reader"

# "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
ARABIC_INDIC = ch(0x0660) + ch(0x0661) + ch(0x0662)

def esc(s)
  s.codepoints.map { |c| c >= 0x20 && c <= 0x7E ? c.chr : format('\u%04X', c) }.join
end

def hit(src, s) = Regexp.new("\\A(?:#{src})\\z").match?(s) ? "yes" : "no"

def table(title, w, d, sp)
  puts title
  width = [w, d, sp].map(&:length).max + 2
  puts "".ljust(40) + w.ljust(width) + d.ljust(width) + sp
  PROBES.each do |label, cp|
    c = ch(cp)
    puts label.ljust(40) + hit(w, c).ljust(width) + hit(d, c).ljust(width) + hit(sp, c)
  end
  puts ""
end

table("default -- \\w, \\d and \\s are ASCII:", '\w', '\d', '\s')
table("the POSIX bracket classes are not:", '[[:word:]]', '[[:digit:]]', '[[:space:]]')
table("and (?u) switches the shorthands over:", '(?u)\w', '(?u)\d', '(?u)\s')

puts "\\b\\w+\\b over 'na' U+00EF 've reader' -- how many words?"
[
  ['\b\w+\b        ', '\b\w+\b'],
  ['\w+ (no \\b)    ', '\w+'],
  ['(?u)\b\w+\b    ', '(?u)\b\w+\b'],
  ['\b[[:word:]]+\b', '\b[[:word:]]+\b']
].each do |label, src|
  found = SUBJECT.scan(Regexp.new(src))
  puts "  #{label} -> #{found.length}   #{found.map { |t| esc(t) }.join(' ')}"
end
puts ""

puts "is U+00EF a word character to \\b, when \\w says it is not?"
puts "  'na' U+00EF 've' =~ /na\\b/  -> #{SUBJECT.match?(/na\b/) ? "yes" : "no"}"
puts "  'na' U+00EF 've' =~ /\\bve/  -> #{SUBJECT.match?(/\bve/) ? "yes" : "no"}"
puts ""

puts "\\d and the number that follows it (subject is U+0660 U+0661 U+0662):"
puts "  /\\A\\d+\\z/          -> #{hit('\d+', ARABIC_INDIC)}"
puts "  /\\A[[:digit:]]+\\z/ -> #{hit('[[:digit:]]+', ARABIC_INDIC)}"
puts "  /\\A(?u)\\d+\\z/      -> #{hit('(?u)\d+', ARABIC_INDIC)}"
puts "  String#to_i        -> #{ARABIC_INDIC.to_i}"
begin
  puts "  Integer()          -> #{Integer(ARABIC_INDIC)}"
rescue ArgumentError => e
  puts "  Integer()          -> raises #{e.class}"
end
