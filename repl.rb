require 'io/console'
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
    continue = true
    while continue
        c = STDIN.getch
        if (c == '\n' || c == '\r')
            buffer[position] = '\n'
            continue = false
            return buffer
            break
        else
            buffer[position] = c
        end
        STDIN.iflush
        print buffer.join.to_s
        position += 1
    end
end

readline8

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