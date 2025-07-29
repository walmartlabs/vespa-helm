REPO_URL = https://github.com/walmartlabs/vespa-helm.git

.PHONY: all lint test render

.DEFAULT_GOAL := all

all: lint test render

# This is to lint the current charts
lint: 
	helm lint charts/vespa/

# This is to unit-test the current charts
test: 
	helm unittest charts/vespa/

# This is to render the current charts and check if it renders
render: 
	helm template charts/vespa/

