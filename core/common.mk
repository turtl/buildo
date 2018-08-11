# Some targets common to all core builds. Keeps the Makefiles clean and simple.
# You must set NAME, VERSION, & OUTFILE before including.

.PHONY: all clean run

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
	rm -rf $(BUILD)

