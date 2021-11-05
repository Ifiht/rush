require 'readline'

while input = Readline.readline("=> ", true)
    parsed1 = input.split
    if parsed1[0] == "exit"
        break
    elsif (`which #{parsed1[0]}`.length >= 1)
        puts `#{input}`
    else
        puts "#{eval(input.to_s)}"
    end
    system(input)
end