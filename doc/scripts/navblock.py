#!/usr/bin/env python3
"""navblock.py — sostituisce un blocco delimitato da marker dentro un file YAML.

Uso: navblock.py <file.yml> <nome-blocco>   (il contenuto arriva da stdin)

Il blocco è delimitato da "# BEGIN <nome>" e "# END <nome>".
Se non esiste, viene aggiunto in coda. Se esiste, viene sostituito: così il
publish è idempotente e i tre repo che scrivono nello stesso file non si
pestano i piedi.
"""
import pathlib
import sys

nav = pathlib.Path(sys.argv[1])
name = sys.argv[2]
body = sys.stdin.read().rstrip("\n")

begin = f"# BEGIN {name} (generato — non modificare a mano)"
end = f"# END {name}"
block = f"{begin}\n{body}\n{end}\n"

text = nav.read_text() if nav.exists() else ""

if begin in text and end in text:
    head = text.split(begin)[0]
    tail = text.split(end, 1)[1].lstrip("\n")
    text = head + block + ("\n" + tail if tail else "")
else:
    text = (text.rstrip("\n") + "\n\n" if text.strip() else "") + block

nav.write_text(text)
