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

def readline8
    position = 0
    buffer = []
    loop do
        c = STDIN.getch
        break if (c == "\n" || c == "\r" || c == "f")
        buffer[position] = c
        STDOUT.print "\u001b[2K"     # Clear the current line
        STDOUT.print "\u001b[1000D"  # Reset cursor position to the left
        STDOUT.print buffer.join     # re-print the string buffer
        position += 1
    end
    print "\n"
end


stdin_thr = Thread.new do
    readline8
end

rows, columns = STDIN.winsize
puts "Your screen is #{columns} wide and #{rows} tall"

stdin_thr.join
