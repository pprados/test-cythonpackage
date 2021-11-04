Sample project for 'cythonpackage'

Use 
- `make` for help
- `m̀ake bdist` for building distribution for linux
- Use CI for building distribution for all OS (See [cibuildwheel](https://cibuildwheel.readthedocs.io/en/stable/))
- Then, use `make download-artifacts`

All the generated wheel were 

C'est dans le pyproject.toml de cythonpackage qu'il faut déclarer l'existance du plugin !

C'est la galère pour avoir un env. correct.
Le mieux est de forcer l'env sur le venv local
poetry config virtualenvs.path "/home/pprados/workspace.bda/cpackage/venv"

Ensuite, il faut jouer avec les p install, pip install, etc.

La problème est dans core/factory.py, la @classmethode configure_package()
qui fige the package à partir de la conf. Donc pas d'impact en cas de modification.
On peut essayer de l'invoquer en direct, pour patcher 'package' mais c'est protégé en écriture.