import cython

def print_me() -> bool:
    if cython.compiled:
        print("foo2.bar_d compiled.")
        return True
    else:
        print("foo2.bar_d interpreted.")
        return False
