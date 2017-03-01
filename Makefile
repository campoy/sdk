ASSETS_PATH := etc
ASSETS := $(shell ls $(ASSETS_PATH))
ASSETS_PACKAGE := assets
BINDATA_FILE := bindata.go
BINDATA_CMD := go-bindata
BINDATA_URL := github.com/jteeuwen/go-bindata
BINDATA_EXISTS := $(shell command -v $(BINDATA_CMD) 2> /dev/null)

# General
WORKDIR = $(PWD)

# Go parameters
GOCMD = go
GOTEST = $(GOCMD) test -v

# Coverage
COVERAGE_REPORT = coverage.txt
COVERAGE_PROFILE = profile.out
COVERAGE_MODE = atomic

all: bindata

install_bindata:
ifndef BINDATA_EXISTS
	go get $(BINDATA_URL)/...
endif

bindata: install_bindata $(ASSETS)

$(ASSETS):
	$(BINDATA_CMD) \
		-pkg $@ \
		-prefix $(ASSETS_PATH)/$@ \
		-o $(ASSETS_PACKAGE)/$@/$(BINDATA_FILE) \
		$(ASSETS_PATH)/$@/...

test:
	cd $(WORKDIR); \
	$(GOTEST) ./...

test-coverage:
	cd $(WORKDIR); \
	echo "" > $(COVERAGE_REPORT); \
	for dir in `$(GOCMD) list ./... | egrep -v '/(vendor|etc)/'`; do \
		$(GOTEST) $$dir -coverprofile=$(COVERAGE_PROFILE) -covermode=$(COVERAGE_MODE); \
		if [ $$? != 0 ]; then \
			exit 2; \
		fi; \
		if [ -f $(COVERAGE_PROFILE) ]; then \
			cat $(COVERAGE_PROFILE) >> $(COVERAGE_REPORT); \
			rm $(COVERAGE_PROFILE); \
		fi; \
	done; \


