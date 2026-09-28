#!/usr/bin/env bash
# Feeds commands to ./shell on stdin and checks the output of each feature.
set -u
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
pass=0; fail=0

check() {  # check <name> <input> <expected substring>
  out=$(printf '%b\n' "$2" | ./shell 2>&1)
  if [[ "$out" == *"$3"* ]]; then pass=$((pass+1)); echo "PASS  $1"
  else fail=$((fail+1)); echo "FAIL  $1"; echo "   expected: $3"; echo "   got: $out"; fi
}

check "simple command"       "echo hello"                          "hello"
check "arguments"            "printf %s-%s a b"                    "a-b"
check "pipe"                 "echo alpha beta | wc -w"             "2"
check "three-stage pipe"     "printf 'c\\nb\\na\\n' | sort | head -1" "a"
check "output redirect"      "echo saved > $tmp/o.txt\ncat $tmp/o.txt" "saved"
check "append redirect"      "echo one > $tmp/a.txt\necho two >> $tmp/a.txt\nwc -l $tmp/a.txt" "2"
check "input redirect"       "echo from-file > $tmp/i.txt\ncat < $tmp/i.txt" "from-file"
check "sequence ;"           "echo first ; echo second"            "second"
check "&& runs on success"   "true && echo ran"                    "ran"
out=$(printf 'false && echo should-not-run\n' | ./shell 2>&1)
if [[ "$out" != *"should-not-run"* ]]; then pass=$((pass+1)); echo "PASS  && skips on failure"
else fail=$((fail+1)); echo "FAIL  && skips on failure"; fi
check "history"              "echo x\nhistory"                     "1: echo x"
check "exit"                 "exit\necho after-exit"               "sh> "

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
