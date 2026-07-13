#!/usr/bin/env python3
"""svg-embed.py — inject inline Faust block diagrams into generated library docs.

For every `#### Diagram` heading in a generated markdown file, take the nearest
preceding `#### Test` code block, turn its `NAME_test = EXPR;` line into
`process = EXPR;`, compile it with `faust -svg`, self-contain the top-level
`process.svg` (drop the XML prolog and the non-deterministic drill-down links),
and inline it right after the `#### Diagram` heading, wrapped in
`<div class="faust-diagram">`.

Idempotent: an already-injected diagram (an immediately-following
`<div class="faust-diagram">` block) is replaced, not duplicated.

Usage: svg-embed.py <file.md> [-I <faust-include-dir>]
"""
import os, re, sys, subprocess, tempfile

def selfcontain(svg):
    svg = re.sub(r'<\?xml[^>]*\?>\s*', '', svg)          # drop XML prolog for inline HTML
    svg = re.sub(r'<a xlink:href="[^"]*">', '', svg)     # drop non-deterministic drill-down links
    return svg.replace('</a>', '')

def test_to_process(code_lines):
    out = []
    for ln in code_lines:
        m = re.match(r'\s*[A-Za-z_][A-Za-z0-9_]*_test\s*=\s*(.*)$', ln)
        out.append('process = ' + m.group(1) if m else ln)
    return '\n'.join(out) + '\n'

def compile_svg(code_lines, incdir):
    with tempfile.TemporaryDirectory() as d:
        with open(os.path.join(d, 'diagram.dsp'), 'w') as f:
            f.write(test_to_process(code_lines))
        r = subprocess.run(['faust', '-svg', '-I', incdir, 'diagram.dsp', '-o', '/dev/null'],
                           cwd=d, capture_output=True, text=True)
        if r.returncode != 0:
            raise RuntimeError(r.stderr.strip())
        with open(os.path.join(d, 'diagram-svg', 'process.svg')) as f:
            return selfcontain(f.read()).strip()

def embed(path, incdir):
    lines = open(path).read().split('\n')
    out, i, last_test, injected = [], 0, None, 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '#### Test':
            out.append(line); i += 1
            while i < len(lines) and lines[i].strip() != '```':
                out.append(lines[i]); i += 1
            if i < len(lines):
                out.append(lines[i]); i += 1
            code = []
            while i < len(lines) and lines[i].strip() != '```':
                code.append(lines[i]); out.append(lines[i]); i += 1
            last_test = code
            continue
        if line.strip() == '#### Diagram':
            out.append(line); i += 1
            if i < len(lines) and lines[i].strip() == '' and i + 1 < len(lines) \
               and lines[i + 1].startswith('<div class="faust-diagram">'):
                i += 1
                while i < len(lines) and not lines[i].startswith('</div>'):
                    i += 1
                i += 1
            if last_test is None:
                raise RuntimeError(f'{path}: "#### Diagram" with no preceding "#### Test"')
            svg = compile_svg(last_test, incdir)
            out += ['', f'<div class="faust-diagram">\n{svg}\n</div>']
            injected += 1
            continue
        out.append(line); i += 1
    open(path, 'w').write('\n'.join(out))
    return injected

if __name__ == '__main__':
    args = sys.argv[1:]
    incdir = '../src'
    if '-I' in args:
        k = args.index('-I'); incdir = args[k + 1]; del args[k:k + 2]
    incdir = os.path.abspath(incdir)   # resolve before faust runs with cwd=tempdir
    n = embed(args[0], incdir)
    print(f'  embedded {n} diagram(s) into {args[0]}')
