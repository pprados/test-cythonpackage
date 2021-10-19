#!/usr/bin/env python
# Version with PBR
# from setuptools import setup
# setup(
#     setup_requires=['pbr', 'cythonpackage'],
#     cythonpackage=False,
#     pbr=True,
#     requires=['cythonpackage'],
# )

# Version without PBR
from setuptools import setup, find_packages

setup(
    setup_requires=['cythonpackage'],
    cythonpackage=True,
    # cythonpackage={
    #     "inject_ext_modules": True,
    #     "inject_init": True,
    #     "remove_source": True,
    #     "compile_pyc": True,
    #     "optimize": 2,
    # },

    packages=find_packages(),
)
