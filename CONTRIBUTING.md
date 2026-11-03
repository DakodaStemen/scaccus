# Contributing

Keep changes small and measured. `main` stays stable; work happens on branches and lands through a pull request. Run `make ci` before you push.

## Build and test

```sh
make                 # C11, gcc or clang, no dependencies
make setup           # once: .venv with python-chess for the UCI tests (needs uv)
make lint            # -Werror compile of every source + shellcheck
make test            # perft quick tier + bench signature + UCI tests
make ci              # lint + test + ASan/UBSan smoke run
./tests/perft_suite.sh ./cbitboard full   # deep perft tier, about 1 min
```

CI builds with `-Wall -Wextra -Werror` on gcc and clang and runs ASan/UBSan, so warnings are errors.

## Branches and pull requests

| Prefix | Use |
| :---- | :---- |
| `feat/...` | Engine features |
| `fix/...` | Bug fixes |
| `docs/...` | Documentation |
| `chore/...` | Tooling and repository hygiene |
| `ci/...` | Workflow changes |
| `test/...` | Tests only |

- PR titles follow Conventional Commits, matching the prefix: `feat: add ...`, `fix: ...`.
- One purpose per PR. Fill in `.github/PULL_REQUEST_TEMPLATE.md` with an honest description: what changed, what you measured, what you did not.
- Commit messages state what changed and why. Weak: `updated search`. Strong: `search: skip null move when only pawns remain (fixes zugzwang loss)`.

## Rules

- **Move generation changes** must keep every row of `tests/perft.tsv` passing.
- **Search/eval changes** alter the deterministic bench node count. Update `tests/bench_nodes.txt` (`./cbitboard bench | grep signature`) in the same commit and say why in the message.
- **Strength claims** need a test: use `make sprt BASE=<old-binary>` (needs [fastchess](https://github.com/Disservin/fastchess)). State the settings (fixed nodes vs time control), game count and LLR bounds. Do not report an SPRT as a rating.
- **Speed claims** need real before/after numbers from your machine; mention load and how you reduced noise.
- Do not commit binaries, archives or generated output (`sprt-out/` is ignored).

Report vulnerabilities as described in [SECURITY.md](SECURITY.md).
