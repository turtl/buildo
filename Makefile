.PHONY: core-linux32 core-linux64 core-armv7 core-arm64 desktop-linux32 desktop-linux64

export SHELL := /bin/bash
export BUILD := target

mkdir = @mkdir -p $(dir $@)

core-linux32:
	cd core/linux32 && make run

core-linux64:
	cd core/linux64 && make run

core-armv7:
	cd core/armv7 && make run

core-arm64:
	cd core/arm64 && make run

desktop-linux32:
	cd desktop/linux32 && make run

desktop-linux64:
	cd desktop/linux64 && make run

