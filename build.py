from cythonpackage import build_cythonpackage

# This function will be executed inside the generated setup.py:
def build(setup_kw):
    build_cythonpackage(setup_kw)
