import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo.bar_a compiled.")
        return True
    else:
        print("foo.bar_a interpreted.")
        return False
