#!/usr/bin/env python
# Version with PBR
# setup(
#     setup_requires=['pbr', 'cythonpackage[build]==0.0.12'],
#     cythonpackage={
#         "inject_ext_modules": True,
#         "inject_init": True,
#         "remove_source": True,
#         "compile_py": False,
#         "optimize": 2,
#         "exclude":["**/_b.py"],
#     },
#     pbr=True,
#     install_requires=['cythonpackage==0.0.12'],
# )

# Version without PBR
from setuptools import setup, find_packages

setup(
    # setup_requires=['pbr', 'cythonpackage[build]'],
    # pbr=True,
    # # Note: setuptools 44.0.0 with PEP-517 can not manage extra parameter in setup.cfg
    setup_requires=['cythonpackage[build]'],
    # cythonpackage=True,
    #
    # # To update low level parameters
    cythonpackage={
        "ext_modules": True,
        "install_requires": False,
        "inject_init": True,
        "remove_source": True,
        "compile_py": True,
        "optimize": 2,
        "exclude":["**/*_b.py"]
    },

    # To build only with setup()
    # name="test-cythonpackage",
    # version="v0.0.0",
    # install_requires=['cythonpackage'],
    packages=find_packages(),
)
