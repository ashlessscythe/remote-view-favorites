# Testing

```bash
lua tests/run.lua                                          # pure Lua (scripts/favorites.lua), no Factorio
scripts/run_factorio_tests.sh                              # headless in-game smoke tests, in Docker
scripts/run_factorio_tests.sh run --mod-path . --tag-whitelist visual   # scenarios, headless, in Docker
scripts/watch_factorio_tests.sh                            # watch the scenarios in a real Factorio window
```

- In-game tests are [factorio-test](https://github.com/GlassBricks/FactorioTest) and live in `tests/factorio/`; they are registered at the bottom of `control.lua` and only load when the `factorio-test` mod is enabled.
- `smoke.lua` is headless-safe. `visual.lua` is tagged `visual`: favorite jumps, position memory, the jump guard and list refresh, with pauses so you can watch them.
- The watch script and the non-Docker route use your local Steam Factorio (2.1.24+): `npx factorio-test-cli run --mod-path . --factorio-path <factorio binary> --tag-whitelist visual`.
- Docker route and CI need `FACTORIO_USERNAME` / `FACTORIO_TOKEN` (read from your local `player-data.json` when unset) to download the factorio-test mod.
- Custom inputs can't be raised from script, so tests call the same handler through the `rvf-test` remote interface (only registered when factorio-test is active).
