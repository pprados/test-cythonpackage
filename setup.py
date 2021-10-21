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
    name='test-cythonpackage',
    version='0.0.0',
    setup_requires=['cythonpackage[build]'],
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
