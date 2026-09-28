# mini-unix-shell

A small Unix shell in C. It reads a command line, parses it, and runs programs
with `fork` and `execvp`, wiring up pipes and file redirection with `dup2`.

Built for CSE321 (Operating Systems) at BRAC University, Spring 2025.

## Build and run

Linux or macOS (it uses POSIX `fork`, `pipe` and `sigaction`):

```bash
make
./shell
```

```
sh> ls -l | grep .c | wc -l
sh> echo hello > out.txt ; cat < out.txt
sh> gcc -o hello hello.c && ./hello
sh> history
```

## Features

| Feature | Syntax | How it works |
| --- | --- | --- |
| Run programs | `ls -la` | `fork`, then `execvp` in the child; the parent waits |
| Pipes | `a \| b \| c` | one `pipe` per stage; each child's stdin/stdout moved with `dup2` |
| Redirection | `<`, `>`, `>>` | `open` with the right flags, then `dup2` onto stdin or stdout |
| Sequences | `a ; b` | runs each command in turn |
| Conditional | `a && b` | runs `b` only if `a` exits with status 0 |
| History | `history` | lists the commands typed this session |
| Ctrl-C | | a `SIGINT` handler keeps the shell alive and redraws the prompt |
| Exit | `exit` or Ctrl-D | |

## Tests

`tests/test.sh` pipes commands into the shell and checks the output for each
feature (12 checks). CI runs it on Ubuntu on every push.

```bash
make test
```

## Limitations

- No quoting or escaping: arguments are split on spaces.
- No `cd` or other built-ins besides `history` and `exit`, and no background jobs (`&`).
- Pipeline stages are waited for one at a time, so a stage that writes more than
  the pipe buffer before the next stage starts can block.
- History is kept in memory only (up to 100 commands).
