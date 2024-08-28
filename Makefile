.PHONY: all bigbang init plan apply destroy init-module activate-module

all:
	@echo "Specify a command to run"

init:
	python3 -m venv .venv; \
	until [ -f .venv/bin/python3 ]; do sleep 1; done; \
	until [ -f .venv/bin/activate ]; do sleep 1; done;
	. .venv/bin/activate; \
    pip install git+https://github.com/x-i-a/xia-framework.git; \
    pip install git+https://github.com/x-i-a/xia-module.git; \
	pip install PyYAML keyring setuptools wheel; \
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
	@if [ -z "$(realm_project)" ]; then \
		echo "Realm project not specified. Usage: make bigbang realm_project=<realm_project>"; \
	else \
		python main.py bigbang -p $(realm_project); \
	fi

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
