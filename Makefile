dependencies:
	pip install --upgrade pre-commit yamllint
	pre-commit install
	pre-commit autoupdate

lint:
	yamllint integrations
	yamllint configuration.yaml
