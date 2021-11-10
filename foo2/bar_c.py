import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo2.bar_c compiled.")
        return True
    else:
        print("foo2.bar_c interpreted.")
        return False
