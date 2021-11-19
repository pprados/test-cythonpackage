import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo.bar_b compiled.")
        return True
    else:
        print("foo.bar_b interpreted.")
        return False
