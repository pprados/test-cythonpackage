#!/usr/bin/env make
SHELL=/bin/bash
.SHELLFLAGS = -e -c
.ONESHELL:
MAKEFLAGS += --no-print-directory

PRJ=test-cythonpackage
PRJ_PACKAGE:=$(PRJ)
PYTHON=python3
PYTHON_SRC=$(shell find . -name '*.py' -not -path "./venv/*" -not -path "./.eggs/*" -not -path "./build/*")
REQUIREMENTS=
TWINE_USERNAME?=__token__
SIGN_IDENTITY?=$(USER)
ifeq ($(OS),Windows_NT)
    OS:= Windows
else
    OS:= $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

GITHUB_USER?=$(USER)

CHECK_VENV=if [[ "$(VIRTUAL_ENV)" == "" ]] ; \
  then ( echo -e "$(green)Use: $(cyan)virtualenv$(VENV)$(green) before using $(cyan)make$(normal)"; exit 1 ) ; fi

ACTIVATE_VENV=source $(VIRTUAL_ENV)/bin/activate
DEACTIVATE_VENV=deactivate

VALIDATE_VENV?=$(CHECK_VENV)

## Print all majors target
help:
	@echo "$(bold)Available rules:$(normal)"
	echo
	sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=20 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

	echo -e "Use '$(cyan)make -jn ...$(normal)' for Parallel run"
	echo -e "Use '$(cyan)make -B ...$(normal)' to force the target"
	echo -e "Use '$(cyan)make -n ...$(normal)' to simulate the build"


.PHONY: dump-*
# Tools to dump makefile variable (make dump-AWS_API_HOME)
dump-%:
	@if [ "${${*}}" = "" ]; then
		echo "Environment variable $* is not set";
		exit 1;
	else
		echo "$*=${${*}}";
	fi

ifneq ($(TERM),)
normal:=$(shell tput sgr0)
bold:=$(shell tput bold)
red:=$(shell tput setaf 1)
green:=$(shell tput setaf 2)
yellow:=$(shell tput setaf 3)
blue:=$(shell tput setaf 4)
purple:=$(shell tput setaf 5)
cyan:=$(shell tput setaf 6)
white:=$(shell tput setaf 7)
gray:=$(shell tput setaf 8)
endif

## Clean project
clean:
	@rm -rf .eggs $(PRJ).egg-info .mypy_cache .pytest_cache .start build nohup.out dist \
		.make-* .pytype out.json \
		foo/*.c foo/sub/*.c foo2/*.c foo3/*.c
	find . -name __pycache__ -exec rm {} \;


## Download the dependencies
init:
	pip install -e '.[dev]'

## Test the usage of cythonpackage
test: bdist
	@echo -e "$(green)Build package$(normal)"
	#export PIP_EXTRA_INDEX_URL=http://localhost/simple
	export PIP_EXTRA_INDEX_URL=https://test.pypi.org/simple
	#export PIP_EXTRA_INDEX_URL=https://pypi.org/simple
	#export PIP_INDEX_URL=https://test.pypi.org/simple
	rm -Rf build dist
	python setup.py bdist_wheel
	mkdir -p $(TEMP)/$(PRJ)
	cp test.py $(TEMP)/$(PRJ)
	echo -e "$(green)Create temporary virtualenv$(normal)"
	pip install -q virtualenv
	python --version
	python -m virtualenv $(TEMP)/$(PRJ)/venv
	source $(TEMP)/$(PRJ)/venv/bin/activate
	echo -e "$(green)Install project$(normal)"
	pip install --force-reinstall cython ../dist/*.whl
	pip install --force-reinstall cython dist/test*.whl
	cd $(TEMP)/$(PRJ)
	echo -e "$(green)Test project$(normal)"
	python 'test.py'
	rm -Rf $(TEMP)/$(PRJ)


# --------------------------- Distribution
dist/:
	@mkdir dist

.PHONY: bdist
dist/$(subst -,_,$(PRJ_PACKAGE))-*.whl: $(REQUIREMENTS) $(PYTHON_SRC) setup.* pyproject.toml | dist/
	@$(VALIDATE_VENV)
	export PBR_VERSION=0.0.1
	# Pre-pep517 $(PYTHON) setup.py bdist_wheel
	#pip wheel --no-deps --no-build-isolation --use-pep517 -w dist .
	#pip wheel --use-pep517 -w dist .
	#python setup.py bdist_wheel
	python -m build -w
	# FIXME auditwheel repair $@
	pkginfo dist/$(subst -,_,$(PRJ_PACKAGE))-*.whl
	unzip -l dist/$(subst -,_,$(PRJ_PACKAGE))-*.whl


## Create a binary wheel distribution for different version
bdist: dist/$(subst -,_,$(PRJ_PACKAGE))-*.whl | dist/

## Create standard package (without compilation)
bdist-default:
	echo -e "$(green)Build default package$(normal)"
	CYTHONPACKAGE=False python setup.py bdist_wheel

## Create all binary wheel distribution for different version for the platform
#bdist-all: bdist-default | dist/
bdist-all:  | dist/
	@$(VALIDATE_VENV)
	pip install cibuildwheel
	echo -e "$(green)Build compiled platform package$(normal)"
	CIBW_BUILD=cp310-* \
	CIBW_REPAIR_WHEEL_COMMAND='' \
	CIBW_ENVIRONMENT="PBR_VERSION=0.0.0" \
	$(PYTHON) -m cibuildwheel --output-dir dist \
		--platform $(shell echo $(OS) | tr '[:upper:]' '[:lower:]')


.PHONY: download-artifacts
# Download the last artifacts generated with gihub Action
download-artifacts:
	@$(VALIDATE_VENV)
	if [[ ! -z "$(GITHUB_TOKEN)" ]]; then GITHUB_AUTH="-u $(GITHUB_USER):$(GITHUB_TOKEN)" ; fi
	mkdir -p build
	ID=$$(curl $(GITHUB_AUTH) -s "https://api.github.com/repos/$(GITHUB_USER)/$(PRJ)/actions/artifacts" | jq -r '.artifacts[0].id')
	curl -sL $(GITHUB_AUTH) \
		-H "Accept: application/vnd.github.v3+json" \
		https://api.github.com/repos/$(GITHUB_USER)/$(PRJ)/actions/artifacts/$${ID}/zip \
		-o build/dist.zip
	unzip -o build/dist.zip -d dist


.PHONY: sdist
dist/$(PRJ_PACKAGE)-*.tar.gz: $(REQUIREMENTS) | dist/
	@$(VALIDATE_VENV)
	$(PYTHON) setup.py sdist

sdist: dist/$(PRJ_PACKAGE)-*.tar.gz | dist/

.PHONY: clean-dist dist

clean-dist:
	rm -Rf dist/*

# see https://packaging.python.org/guides/publishing-package-distribution-releases-using-github-actions-ci-cd-workflows/
## Create a full distribution
dist: clean-dist bdist-all sdist
	@echo -e "$(yellow)Packages for distribution created$(normal)"

.PHONY: check-twine test-keyring test-twine
## Check the distribution before publication
check-twine: bdist
	@$(VALIDATE_VENV)
	twine check \
		$(shell find dist/ -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )

## Create keyring for Test-twine
test-keyring:
	@[ -s "$$TWINE_USERNAME" ] && read -p "Test Twine username:" TWINE_USERNAME
	keyring set https://test.pypi.org/legacy/ $$TWINE_USERNAME

## Publish distribution on test.pypi.org
test-twine: check-twine
	@$(VALIDATE_VENV)
	[[ $$( find dist/ -name "*.dev*.whl" | wc -l ) == 0 ]] || \
		( echo -e "$(red)Add a tag version in GIT before release$(normal)" \
		; exit 1 )
	rm -f dist/*.asc
	echo -e "$(green)Enter the Pypi password$(normal)"
	twine upload --sign -i $(SIGN_IDENTITY) --repository-url https://test.pypi.org/legacy/ \
		$(shell find dist/ -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )
	echo -e "To the test repositiry"
	echo -e "$(green)export PIP_INDEX_URL=https://test.pypi.org/simple$(normal)"
	echo -e "$(green)export PIP_EXTRA_INDEX_URL=https://pypi.org/simple$(normal)"

.PHONY: keyring release

## Create keyring for release
keyring:
	@[ -s "$$TWINE_USERNAME" ] && read -p "Twine username:" TWINE_USERNAME
	keyring set https://upload.pypi.org/legacy/ $$TWINE_USERNAME

.PHONY: push-docker-release push-release release

## Publish a distribution on pypi.org
release: clean .make-validate check-twine
	@$(VALIDATE_VENV)
	[[ $$( find dist/ -name "*.dev*" | wc -l ) == 0 ]] || \
		( echo -e "$(red)Add a tag version in GIT before release$(normal)" \
		; exit 1 )
	rm -f dist/*.asc
	echo -e "$(green)Enter the Pypi password$(normal)"
	twine upload --sign \
		$(shell find dist -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )

