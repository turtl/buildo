.PHONY: all clean run

# ------------------------------------------------------------------------------
NAME := core/linux64
VERSION := 1
OUTFILE := libturtl_core.linux64.so
# ------------------------------------------------------------------------------

# non-versioned include
-include vars.mk

export SHELL := /bin/bash
export BUILD := .build

mkdir = @mkdir -p $(dir $@)

all: $(BUILD)/dockerbuild

$(BUILD)/dockerbuild: Dockerfile core/* libsodium/* openssl/*
	$(mkdir)
	docker build -t turtl-build/$(NAME):v$(VERSION) .
	touch $@

run:
	docker run --rm -it -e OUTFILE=$(OUTFILE) -v /home/andrew/dev/turtl/build/target:/builder/out turtl-build/$(NAME):v$(VERSION)

clean:
	rm -rf build

