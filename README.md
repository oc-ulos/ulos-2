# ![logo](./ulos2-logo.png) ULOS 2

Home of ULOS 2 for [OpenComputers](curseforge.com/minecraft/mc-mods/opencomputers).

We recommend running ULOS 2 under OpenComputers 1.7.7 or newer.  Because Minecraft 1.12.2 ships with a horribly outdated build of Java 8, you may need to [upgrade to a newer build](https://www.youtube.com/watch?v=fZ2QIarg_c8) for certain networking features to function.

ULOS 2 boasts several advantages over [ULOS 1](https://github.com/ocawesome101/oc-ulos), not least vastly increased compatibility with programs written for a \*nix-like environment.  This is accomplished through extensive use of [LuaPosix](https://luaposix.github.io/luaposix/index.html) APIs wherever possible.

ULOS 2 is also even more modular than ULOS 1 - each component is split into its own submodule and default configurations are defined by ULOS 2, so you can override configurations or swap out individual components very easily.

Documentation for all libraries and system calls is available [here](https://ulos2.ocaweso.me/).

## Building

**Clone this repository with `--recursive`.**

This repository's submodule configuration assumes you have registered an SSH key with GitHub.  If you have not done so you will not be able to clone the repository.

You will need LuaPosix to build Cynosure 2 and CLDR 2.

Run `tools/setup.sh` to switch all submodules to their main branches after initial cloning.  Run `tools/pull-repos.sh` to pull all repo updates.

Run `tools/assemble-release.sh` from the repository root to generate a ULOS 2 system in `build/`.  Run `tools/assemble-release.sh cpio` to additionally generate a release CPIO.

## Contact us

The primary developers of ULOS 2 are Ocawesome101 and Wattana.  You can find us in [Ocawesome101's Projects](https://discord.gg/fMBMqTGGXB), [the official OpenComputers Discord](https://discord.gg/bYqKv7h), and Ocawesome101 (but not Wattana) in [Minecraft Computer Mods](https://discord.gg/mxdG5mckkY).
