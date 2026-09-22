# Ruby is the one mainstream engine that ships a guard you can turn on.
#
# Two separate things are on show here, and they arrived together in Ruby 3.2:
#
#   1. the engine memoises its backtracking search, which flattens most of the
#      classic exponential shapes into something linear, and
#   2. `Regexp.timeout=` puts a wall-clock bound on whatever is left, raising
#      `Regexp::TimeoutError` instead of holding the thread.
#
# Only the exception's CLASS is recorded, never its message and never a
# duration: a class name is a fact two Ruby releases agree on.

Regexp.timeout = 2.0

EMAIL = '^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$'
EMAIL_FIXED = '^[a-zA-Z0-9_.-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}$'

HOSTILE = 'a' * 120 + '!'
BLANKS = ' ' * 120 + '!'
MAIL_HOSTILE = 'a@a.' + 'a' * 120 + '!'

def probe(pattern, subject)
  Regexp.new(pattern).match?(subject) ? 'match' : 'no match'
rescue Regexp::TimeoutError => e
  e.class.to_s
end

def table(title, rows)
  puts title
  rows.each do |pattern, shown, subject, described|
    puts format('  %-24s %-22s %s', shown || pattern, described, probe(pattern, subject))
  end
end

puts 'Regexp.timeout is 2.0 seconds; hitting it is reported as the exception class.'
puts

table('patterns with no backreference, ruby:', [
        ['^(a+)+$', nil, HOSTILE, "120 a's then '!'"],
        ['^(a|a)*$', nil, HOSTILE, "120 a's then '!'"],
        ['^(\s*|\t)+$', nil, BLANKS, "120 spaces then '!'"],
        ['^(\w+\s?)*$', nil, HOSTILE, "120 a's then '!'"],
        ['^([a-z]{2,4})+$', nil, HOSTILE, "120 a's then '!'"],
        [EMAIL, 'the email regex', MAIL_HOSTILE, "a@a. 120 a's then '!'"]
      ])

puts
table('the same engine, with the pattern changed instead:', [
        ['^(?>a+)+$', nil, HOSTILE, "120 a's then '!'"],
        ['^([a-z]{2,4})++$', nil, HOSTILE, "120 a's then '!'"],
        [EMAIL_FIXED, 'the email regex, fixed', MAIL_HOSTILE, "a@a. 120 a's then '!'"]
      ])
