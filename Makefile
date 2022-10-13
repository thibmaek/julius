dependencies:
	pip install --upgrade pre-commit yamllint pillow
	pre-commit install
	pre-commit autoupdate

lint:
	yamllint integrations
	yamllint configuration.yaml
