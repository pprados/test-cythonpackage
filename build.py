from typing import Dict, Any

from cythonpackage import build_cythonpackage


# This function will be executed in setup.py:
def build(setup_kwargs:Dict[str,Any]):
    print(f"XXXXXXXXXXX DANS LE BUILD.PY {__file__=} {__name__=}")
    build_cythonpackage(
        {
            "inject_ext_modules": True,
            "inject_init": True,
            "remove_source": True,
            "compile_pyc": True,
            "optimize": 2,
        },
        setup_kwargs)
