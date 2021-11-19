import sys

import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo.sub.sub compiled.")
        return True
    else:
        print("foo.sub.sub interpreted.")
        return False
