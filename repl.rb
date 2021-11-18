require 'io/console'
require 'colorize'
=begin
|===========[ Conventions ]===========|
    1. All RUSH core functions end in numeral '8'
    2. Shell hooks are processed as follows:
pre-input -> during-input -> post-input -> discriminate -,-> (Ruby ?) -> evaluate
                                                         '-> (Shell ?) -> evaluate
    Type        Symbol
standard input	  0<
standard output	  1>
standard error	  2>

Clear Screen: \u001b[{n}J clears the screen
n=0 clears from cursor until end of screen,
n=1 clears from cursor to beginning of screen
n=2 clears entire screen
Clear Line: \u001b[{n}K clears the current line
n=0 clears from cursor to end of line
n=1 clears from cursor to start of line
n=2 clears entire line

=end

$user_prompt = "=> "


def verifycmd(cmdstr)
    fullpath = %[ "which #{cmdstr}]
    if fullpath.length > 0
        return true
    elsif fullpath.length == 0
        return false
    else
        puts "negative length string in verifycmd()"
        return false
    end
end


def preprocess8(buffer)
    working_string = buffer.join
    str_array = working_string.split
    i = str_array.count
    for s in str_array do
        if s == "red"
            working_string.sub!(s, s.colorize(:red))
        end
    end
    return working_string
end


def postprocess8(buffer)
    working_string = buffer.join
    blob_array = working_string.split(/(?<!\\)([|><]{1})/) # Split string on IO bondaries, including the separators ("|", ">", "<")
    blob_array.each do |b|
        b.split(/\b/)
    end
    
    return working_string
end


def console8
    prompt_len = $user_prompt.length
    position = 0
    buffer = []
    breakout = false
    STDOUT.print $user_prompt
    loop do
        clear = prompt_len + buffer.count + 10
        c = STDIN.getch
        break if (c == "\n" || c == "\r")
        buffer[position] = c
        STDOUT.print "\u001b[2K"         # Clear from cursor to end of line
        STDOUT.print "\u001b[#{clear}D"  # Reset cursor position to the left
        STDOUT.print $user_prompt
        STDOUT.print preprocess8(buffer)     # re-print the string buffer
        position += 1
    end
    print "\n"
    working_string = buffer.join.to_s
    #postprocess8(buffer)
    system(buffer.join.to_s)
    if working_string.match(/(^|\s)exit($|\s)/)
        breakout = true
    end
    return breakout
end


stdin_thr = Thread.new do
    loop do
        breakout = console8
        if breakout
            break
        end
    end
end


rows, columns = STDIN.winsize
puts "Your screen is #{columns} wide and #{rows} tall"


stdin_thr.join
