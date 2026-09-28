CC ?= gcc
CFLAGS ?= -std=gnu11 -Wall -Wextra -O2

shell: src/shell.c
	$(CC) $(CFLAGS) -o $@ $<

test: shell
	bash tests/test.sh

clean:
	rm -f shell

.PHONY: test clean
