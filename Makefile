# tZERO Solidity Makefile
#
#  - Compiles all '*.sol' files within './contracts'
#  - Generate Geth init scripts (t0ken.js)
#


SOLIDITY_DEV = "minty/solidity-dev:0.5.14-1.9.9"
SOLC_VERSION = "istanbul"
SOLC_OPTIMIZATIONS = 1000

SOLC := $(shell command -v solc 2> /dev/null)

CONTRACTS = $(shell find contracts -name "*.sol")
CONTRACTS_SOLC = $(shell for f in $(CONTRACTS); do echo "/src/$$f"; done)
PWD = $(shell pwd)


.PHONY: contracts scripts cmd


all: scripts

contracts:
	# -= Compiling contracts =--------------------------------------------------
ifdef SOLC
	@solc                                     \
		--evm-version $(SOLC_VERSION)         \
		--bin                                 \
		--abi                                 \
		--optimize                            \
		--optimize-runs $(SOLC_OPTIMIZATIONS) \
		--output-dir /src/build               \
		--overwrite                           \
		--userdoc                             \
		--devdoc                              \
		tzero/=/src/contracts/                \
		$(CONTRACTS_SOLC) > /tmp/build.log    \
	&& { cat /tmp/build.log | ./bin/solc_filter.sh; cp /tmp/build.log ./build; } \
	|| { cat /tmp/build.log | ./bin/solc_filter.sh; cp /tmp/build.log ./build; exit 1; }
else
	@docker run                                   \
		-it                                       \
		--rm                                      \
		--user $$(id -u $$USER):$$(id -g $$USER)  \
		--volume "$(PWD)":/src                    \
		--workdir /src                            \
		--entrypoint solc                         \
		$(SOLIDITY_DEV)                           \
			--evm-version $(SOLC_VERSION)         \
			--bin                                 \
			--abi                                 \
			--optimize                            \
			--optimize-runs $(SOLC_OPTIMIZATIONS) \
			--output-dir /src/build               \
			--overwrite                           \
			--userdoc                             \
			--devdoc                              \
			tzero/=/src/contracts/                \
			$(CONTRACTS_SOLC) > /tmp/build.log    \
	&& { cat /tmp/build.log | ./bin/solc_filter.sh; cp /tmp/build.log ./build; } \
	|| { cat /tmp/build.log | ./bin/solc_filter.sh; cp /tmp/build.log ./build; exit 1; }
endif

scripts: contracts
	# -= Generating contracts.js =----------------------------------------------
	#    writing begin js
	@echo "var contracts = {" > ./build/contracts.js
	@for file in $(CONTRACTS) ; do          \
		name=$$(basename $$file .sol) ;     \
		abi=$$(cat "./build/$$name.abi")  ; \
		bin=$$(cat "./build/$$name.bin")  ; \
		echo "	'$$name': { abi: $$abi, bin: '$$bin' }," >> ./build/contracts.js ; \
	done
	#    writing custom js
	@./bin/custom_contracts.sh
	#    closing js
	@echo "};" >> ./build/contracts.js

clean:
	# -= Cleaning ./build =-----------------------------------------------------
	@rm -f ./build/*
