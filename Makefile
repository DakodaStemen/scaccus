# An inherited PYTHONPATH (for example another Python's site-packages) breaks uv and the UCI tests.
unexport PYTHONPATH

# Plain `make` builds the engine (as before); `make help` lists targets.
.DEFAULT_GOAL := cbitboard

CC      ?= gcc
# Set NATIVE=0 for a portable binary (e.g. CI artifacts); default tunes for this CPU.
NATIVE  ?= 1
CFLAGS  ?= -std=c11 -Wall -Wextra -O3
ifeq ($(NATIVE),1)
CFLAGS  += -march=native
endif
SRCS    = $(wildcard src/*.c)
HDRS    = $(wildcard src/*.h)
TARGET  = cbitboard
# The UCI tests need python-chess; `make setup` creates .venv with it.
PY      = $(if $(wildcard .venv/bin/python),.venv/bin/python,python3)

.PHONY: help setup lint debug test ci clean bench sprt slider-bench

help:
	@echo "make              build ./$(TARGET) (C11, no dependencies)"
	@echo "make setup        create .venv with python-chess for the UCI tests (idempotent)"
	@echo "make lint         compile every source with -Wall -Wextra -Werror; shellcheck the scripts"
	@echo "make test         perft quick tier + bench signature + UCI tests"
	@echo "make ci           lint + test + ASan/UBSan smoke run"
	@echo "make debug        sanitizer build"
	@echo "make bench|slider-bench|sprt BASE=<binary>|clean"

$(TARGET): $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) -o $@ $(SRCS)

setup:
	@command -v uv >/dev/null || { echo "need uv on PATH" >&2; exit 1; }
	uv venv --allow-existing .venv
	uv pip install --python .venv/bin/python chess

lint:
	@for f in $(SRCS); do $(CC) -std=c11 -Wall -Wextra -Werror -O2 -fsyntax-only -Isrc $$f || exit 1; done
	shellcheck tests/*.sh tools/*.sh

debug: CFLAGS = -std=c11 -Wall -Wextra -g -fsanitize=address,undefined
debug: clean $(TARGET)

test: $(TARGET)
	./tests/perft_suite.sh ./$(TARGET) quick
	./tests/bench.sh ./$(TARGET)
	$(PY) tests/uci_test.py ./$(TARGET)

# Sanitizer smoke run (same commands as the CI "sanitizers" job), then rebuild the normal binary.
ci: lint test
	$(MAKE) debug
	./$(TARGET) 4
	./$(TARGET) "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -" hashcheck 3
	./$(TARGET) bench 5
	$(MAKE) clean
	$(MAKE) $(TARGET)

slider-bench:
	$(CC) -std=c11 -O3 -march=native -Isrc tools/slider_bench.c src/bitboard.c -o slider_bench && ./slider_bench

clean:
	rm -f $(TARGET)

bench: $(TARGET)
	./tests/bench.sh ./$(TARGET)

# make sprt BASE=./old-binary [NEW=./cbitboard]   (needs fastchess on PATH or FASTCHESS=...)
sprt: $(TARGET)
	@test -n "$(BASE)" || { echo "usage: make sprt BASE=<baseline binary> [NEW=./$(TARGET)]"; exit 2; }
	./tools/sprt.sh "$(BASE)" "$(or $(NEW),./$(TARGET))"
