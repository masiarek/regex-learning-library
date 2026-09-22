# Ruby's Onigmo engine, asked the same questions as the other engines here.

subject = "<b>bold</b>"
puts "subject       #{subject}"
["<.+>", "<.+?>", "<[^>]+>"].each do |pattern|
  re = Regexp.new(pattern)
  printf("  %-9s first %p  all %p\n", pattern, subject[re], subject.scan(re))
end

puts "subject       aaa"
["a+", "a+?", "a*?", "a{1,3}?"].each do |pattern|
  printf("  %-9s first %p\n", pattern, "aaa"[Regexp.new(pattern)])
end
