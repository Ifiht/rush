require 'io/console'
require 'pty'
=begin
|===========[ Conventions ]===========|
    1. All RUSH core functions end in numeral '8'
    2. Shell hooks are processed as follows:
pre-input -> during-input -> post-input -> discriminate -,-> (Ruby ?) -> evaluate
                                                         '-> (Shell ?) -> evaluate

char *lsh_read_line(void)
{
  int bufsize = LSH_RL_BUFSIZE;
  int position = 0;
  char *buffer = malloc(sizeof(char) * bufsize);
  int c;

  if (!buffer) {
    fprintf(stderr, "lsh: allocation error\n");
    exit(EXIT_FAILURE);
  }

  while (1) {
    // Read a character
    c = getchar();

    // If we hit EOF, replace it with a null character and return.
    if (c == EOF || c == '\n') {
      buffer[position] = '\0';
      return buffer;
    } else {
      buffer[position] = c;
    }
    position++;

    // If we have exceeded the buffer, reallocate.
    if (position >= bufsize) {
      bufsize += LSH_RL_BUFSIZE;
      buffer = realloc(buffer, bufsize);
      if (!buffer) {
        fprintf(stderr, "lsh: allocation error\n");
        exit(EXIT_FAILURE);
      }
    }
  }
}
=end

def readline8
    position = 0
    buffer = []
    loop do
        c = STDIN.getch
        break if (c == "\n" || c == "\r" || c == "f")
        buffer[position] = c
        print c.inspect
        position += 1
    end
end

readline8

stderr_reader, stderr_writer = IO.pipe
stdout,stdin,pid = PTY.spawn(env, cmd, *args, err: stderr_writer.fileno)

env = { "LINES" => IO.console.winsize.first.to_s,
        "COLUMNS" => IO.console.winsize.last.to_s }

stderr_writer.close

stdin_thr = Thread.new do
    loop do
    c = $stdin.getch

    case c
        when "\u0010"
        print "\033[s" #save cursor
        print "\033[0;0f" #move to top left
        print "\033[K" #erase current line
        print "\e[36m" #cyan
        print "Run-CMD> wait_for: "
        print "\e[0m" #reset

        assert_string = []
        loop do
            assert_c = $stdin.getch
            case assert_c
                when "\u007F"
                    next if assert_string.empty?

                    assert_string.pop
                    $stdout.print "\b"
                    $stdout.print "\033[K"
                when "\f"
                    stdin.write "\x1B\x1Bl" # send it forward
                    break
                when "\r"
                    $stdout.print "\r"
                    $stdout.print "\033[K"
                    break
                when "\e"
                    $stdin.getch
                    $stdin.getch
                    next
                    else
                    assert_string << assert_c
                    $stdout.print assert_c
                end
            end

            recording_input.print 'a'
            recording_input.print assert_string.join("")
            recording_input.print "\u0003"

            print "\033[u" #restore cursor
            else
            recording_input.print 'c'
            recording_input.print c
            recording_input.print (Time.now-started_at).floor(2)
            recording_input.print ':'

            stdin.print c
        end
    end

    stdin.close
end

=begin
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
=end