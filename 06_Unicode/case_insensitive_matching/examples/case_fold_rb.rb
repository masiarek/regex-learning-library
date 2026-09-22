# What //i folds in Ruby (Onigmo), and what String#casecmp? folds instead.
#
# Characters are built from code points and named by code point in the output,
# so nothing here depends on the terminal, the locale or this file's encoding.

KELVIN      = 0x212A.chr(Encoding::UTF_8)
LONG_S      = 0x017F.chr(Encoding::UTF_8)
SHARP_S     = 0x00DF.chr(Encoding::UTF_8)
CAP_SHARP_S = 0x1E9E.chr(Encoding::UTF_8)
DOTLESS_I   = 0x0131.chr(Encoding::UTF_8)
DOTTED_I    = 0x0130.chr(Encoding::UTF_8)
DOT_ABOVE   = 0x0307.chr(Encoding::UTF_8)

PROBES = [
  ["k",        "k",             "U+004B LATIN CAPITAL LETTER K",                "K"],
  ["k",        "k",             "U+212A KELVIN SIGN",                           KELVIN],
  ["s",        "s",             "U+017F LATIN SMALL LETTER LONG S",             LONG_S],
  ["U+00DF",   SHARP_S,         "U+1E9E LATIN CAPITAL LETTER SHARP S",          CAP_SHARP_S],
  ["U+1E9E",   CAP_SHARP_S,     "U+00DF LATIN SMALL LETTER SHARP S",            SHARP_S],
  ["ss",       "ss",            "U+00DF LATIN SMALL LETTER SHARP S",            SHARP_S],
  ["[k]",      "[k]",           "U+212A KELVIN SIGN",                           KELVIN],
  ["[a-z]",    "[a-z]",         "U+212A KELVIN SIGN",                           KELVIN],
  ["i",        "i",             "U+0131 LATIN SMALL LETTER DOTLESS I",          DOTLESS_I],
  ["i",        "i",             "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I],
  ["i U+0307", "i" + DOT_ABOVE, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I],
].freeze

def yn(hit)
  hit ? "yes" : "no"
end

def hit(pattern, subject)
  re = Regexp.new('\A(?:' + pattern + ')\z', Regexp::IGNORECASE)
  !re.match(subject).nil?
end

def hit_binary(pattern, subject)
  re = Regexp.new('\A(?:' + pattern.b + ')\z'.b, Regexp::IGNORECASE)
  !re.match(subject.b).nil?
end

puts "does (?i) match?          ruby, Onigmo, anchored"
puts format("%-9s %-46s %-6s%s", "pattern", "subject", "utf-8", "binary")
PROBES.each do |pat_name, pattern, sub_name, subject|
  puts format("%-9s %-46s %-6s%s", pat_name, sub_name,
              yn(hit(pattern, subject)), yn(hit_binary(pattern, subject)))
end

puts ""
puts "does (?i) fold the BACKREFERENCE comparison too?"
puts format("%-12s vs 'a' + U+0041            %s", '(?i)(a)\1', yn(/(?i)(a)\1/.match?("aA")))
puts format("%-12s vs 'k' + U+212A            %s", '(?i)(k)\1', yn(/(?i)(k)\1/.match?("k" + KELVIN)))

puts ""
puts "one program, two answers about the same pair"
def row(label, str_answer, re_answer)
  puts format("  %-38s%-8s regex //i: %s", label, str_answer, re_answer)
end
row("casecmp?: U+00DF and 'ss'", SHARP_S.casecmp?("ss"), yn(hit("ss", SHARP_S)))
row("downcase(:fold) U+00DF == 'ss'", SHARP_S.downcase(:fold) == "ss", yn(hit("ss", SHARP_S)))
row("casecmp?: U+212A and 'k'", KELVIN.casecmp?("k"), yn(hit("k", KELVIN)))
row("casecmp?: U+017F and 's'", LONG_S.casecmp?("s"), yn(hit("s", LONG_S)))
row("downcase U+1E9E == U+00DF", CAP_SHARP_S.downcase == SHARP_S, yn(hit(SHARP_S, CAP_SHARP_S)))
row("upcase U+00DF is 2 code points", SHARP_S.upcase.length == 2, yn(hit("SS", SHARP_S)))
