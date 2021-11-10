import sys
import os
sys.path.remove(os.getcwd())

import importlib

import  foo.bar_a
import  foo.bar_b
import  foo.sub.sub
import  foo2.bar_c
import  foo2.bar_d
import  foo3.bar_e

assert foo.bar_a.print_me()
assert foo.bar_b.print_me()
assert foo.sub.sub.print_me()
assert foo2.bar_c.print_me()
assert foo2.bar_d.print_me()
assert not foo3.bar_e.print_me()