# ADR-0001: C11 bitboard engine with no dependencies

| Field | Value |
| :---- | :---- |
| Status | Accepted |
| Date | 2026-11-03 |
| Deciders | @DakodaStemen |

## Context

The engine is a UCI chess program. Move generation must be exact (checked against published perft counts) and search must be reproducible so that a change in behavior is visible in CI.

## Decision

- Write the engine in C11 with 64-bit bitboards and no third-party libraries; build with `make` and `gcc` or `clang`.
- Compute slider attacks with Hyperbola Quintessence plus a rank lookup table.
- Keep the search deterministic and record its node count at depth 9 in `tests/bench_nodes.txt`; CI fails when it changes unannounced.
- Verify correctness with the perft suite (`tests/perft.tsv`), the Zobrist hash check and UCI tests driven by python-chess (test-only dependency).

## Alternatives considered

| Alternative | Why not chosen |
| :---- | :---- |
| Magic bitboards | Measured faster per lookup in `tools/slider_bench.c`, but need larger tables and a magic search; Hyperbola Quintessence is simpler |
| C++ or Rust | The project is deliberately plain C11 with a portable Makefile |
| Library for board logic | Writing the generator is the point of the project |

## Consequences

**Positive**

- Builds anywhere with a C compiler; `make ci` reproduces the CI checks.
- Search or eval changes are visible as a bench signature change.

**Negative**

- Slider lookups are slower than magic bitboards in the microbenchmark.
- Tests need Python and python-chess (`make setup`).
