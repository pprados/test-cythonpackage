import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo2.bar_e compiled.")
        return True
    else:
        print("foo2.bar_e interpreted.")
        return False
