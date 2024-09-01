.PHONY: all bigbang init plan apply destroy init-module activate-module

all:
	@echo "Specify a command to run"

init:
	python3 -m venv .venv; \
	until [ -f .venv/bin/python3 ]; do sleep 1; done; \
	until [ -f .venv/bin/activate ]; do sleep 1; done;
	. .venv/bin/activate; \
	pip install PyYAML xia-framework keyring setuptools wheel; \
    pip install keyrings.google-artifactregistry-auth; \

plan: init
	@. .venv/bin/activate; \
	python -m xia_framework.cosmos plan

apply: init
	@. .venv/bin/activate; \
	python -m xia_framework.cosmos apply

destroy: init
	@. .venv/bin/activate; \
	python -m xia_framework.cosmos destroy

bigbang: init
	@. .venv/bin/activate; \
	python -m xia_framework.cosmos bigbang

init-module: init
	@. .venv/bin/activate; \
	if [ -z "$(module_uri)" ] ; then \
		echo "Module URI not specified. Usage: make init-module module_uri=<package_name>@<version>/<module_name>"; \
	else \
		python -m xia_framework.cosmos init-module -n $(module_uri); \
	fi

activate-module: init
	@. .venv/bin/activate; \
	if [ -z "$(module_uri)" ] ; then \
		echo "Module URI not specified. Usage: make activate-module module_uri=<package_name>@<version>/<module_name>"; \
	else \
		python -m xia_framework.cosmos activate-module -n $(module_uri); \
	fi
