#!/usr/bin/env python
# Version with PBR
# from setuptools import setup
# setup(
#     setup_requires=['pbr', 'cythonpackage[build]'],
#     cythonpackage=True,
#     pbr=True,
#     requires=['cythonpackage'],
# )

# Version without PBR
from setuptools import setup, find_packages

setup(
    setup_requires=['cythonpackage[build]'],
    # Note: setuptools 44.0.0 with PEP-517 can not manage extra parameter in setup.cfg
    cythonpackage=True,

    # To update low level parameters
    # cythonpackage={
    #     "inject_ext_modules": True,
    #     "inject_init": True,
    #     "remove_source": True,
    #     "compile_pyc": True,
    #     "optimize": 2,
    # },

    # To build only with setup()
    # name="test-cythonpackage",
    # version="v0.0.0",

    packages=find_packages(),
)
