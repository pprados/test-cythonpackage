from cythonpackage import build_cythonpackage


# This function will be executed in setup.py:
def build(setup_kwargs):
    build_cythonpackage(
        {
            "inject_ext_modules": True,
            "inject_init": True,
            "remove_source": True,
            "compile_pyc": True,
            "optimize": 2,
        },
        setup_kwargs)
