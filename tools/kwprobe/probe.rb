# The Ruby column of tools/kwprobe/run.py. One cell per row on stdout.
#
# Run with -W0: Onigmo warns on stderr about some spellings it accepts (a
# brace-less \pL, for one), and the cell is the answer, not the warning.

def decode(s)
  s.gsub(/\\u\{([0-9A-Fa-f]+)\}/) { $1.to_i(16).chr(Encoding::UTF_8) }
   .gsub('\\n', "\n").gsub('\\r', "\r").gsub('\\t', "\t").gsub('\\\\', '\\')
end

def encode(s)
  return '""' if s.empty?
  s.each_char.map do |c|
    o = c.ord
    case
    when c == '\\' then '\\\\'
    when c == "\n" then '\\n'
    when c == "\r" then '\\r'
    when c == "\t" then '\\t'
    when o < 0x20 || o > 0x7e then format('\\u{%X}', o)
    else c
    end
  end.join
end

File.foreach(ARGV[0], encoding: 'UTF-8') do |raw|
  line = raw.strip
  next if line.empty? || line.start_with?('#')
  f = line.split(' :: ').map(&:strip)
  pattern = f[1]
  subject = f.length > 2 ? decode(f[2]) : nil
  replace = nil
  split = false
  skip = false
  f[3..].to_a.each do |o|
    if o.start_with?('replace=') then replace = decode(o[8..])
    elsif o == 'split' then split = true
    elsif o.start_with?('skip=') && o[5..].split(',').include?('ruby') then skip = true
    end
  end
  if skip then puts 'n/a'; next end
  re = begin
    Regexp.new(pattern)
  rescue StandardError
    nil
  end
  if re.nil? then puts '-'; next end
  if subject.nil? then puts 'ok'; next end
  begin
    if replace
      if re.match(subject).nil? then puts 'no'
      else puts encode(subject.sub(re, replace))
      end
    elsif split
      puts '[' + subject.split(re, -1).map { |p| p.empty? ? '' : encode(p) }.join(',') + ']'
    else
      m = re.match(subject)
      puts m.nil? ? 'no' : encode(m[0])
    end
  rescue StandardError
    puts 'err'
  end
end
