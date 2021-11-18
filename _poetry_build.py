import cythonpackage

# This function will be executed inside the generated setup.py:
def build(setup_kw):
    cythonpackage.build_cythonpackage(setup_kw)
