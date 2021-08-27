require 'readline'

while input = Readline.readline("=> ", true)
    if input == "exit"
        break
    else
        puts "#{eval(input.to_s)}"
    end
    system(input)
end