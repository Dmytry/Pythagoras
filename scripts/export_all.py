#!/usr/bin/python3
# (C) 2023 Dmytry Lavrov.

import os, re, argparse, subprocess, time, signal

parser=argparse.ArgumentParser("Export all models from openscad file")
parser.add_argument('input', metavar="FILE", nargs=1, help="Input file")
parser.add_argument('--output', metavar="FOLDER", help="Output folder", default='')
parser.add_argument('--modules', metavar="NAME", nargs='*', help="Module names")
parser.add_argument('--jobs', metavar="N", type=int, help="jobs", default='24')

args=parser.parse_args()

input_filename=args.input[0]
f=open(input_filename)
lines=f.read()
pattern=re.compile(r'module\s+(OUT_\w+)')

processes=[]

def wait_process_count():
    global processes
    while len(processes)>=args.jobs:
        processes = [p for p in processes if p.poll() == None]
        time.sleep(0.1)

def process_module(match):
    print(match)
    if match.startswith('OUT_'):
        match=match[4:]
    out_filename=os.path.join(args.output, match)
    with open(out_filename, 'w') as of:
        rp=os.path.relpath(input_filename, args.output)
        of.write(f'$fa=3;\n$fs=0.2;\nuse <{rp}>\nOUT_{match}();')
    wait_process_count()
    p=subprocess.Popen(['openscad', out_filename, '-o', os.path.join(args.output, f'{match}.stl')])
    processes.append(p)


def process_list(l):    
    if len(l)>0 :
        os.makedirs(args.output, exist_ok=True)
        s = {a for a in l}
        for m in s:
            process_module(m)

try:
    if args.modules and len(args.modules)>0:
        process_list(args.modules)
    else:
        matches = pattern.findall(lines)
        process_list(matches)
        
        
    for p in processes:
        p.wait()
except KeyboardInterrupt:
    for p in processes:
        p.send_signal(signal.SIGINT)
    for p in processes:
        p.wait()
