# Wolf Tail — FSMP Creature Example

**Version 0.1.0** · an FSMP (Faster HDT-SMP) **creature-physics** demonstration mod.

This is a worked example for the [FSMP modder guide](https://github.com/DaymareOn/FSMP-Validator/wiki):
it gives Skyrim's canines (wolves, dogs, foxes) a physics-driven tail that swings under gravity
and the creature's own movement, instead of the stiff vanilla animation. It is meant to be read
alongside the two source files, which are heavily commented.

> ⚠️ **Requires FSMP 4.1.0 or newer** — the release that introduced creature & animal physics —
> **and** the *Enable creature & animal physics* toggle turned **on** in the FSMP config menu (it is
> off by default). An older FSMP, the original HDT-SMP, or FSMP with the toggle off will simply
> ignore this file.

---

## What it demonstrates

Until FSMP 4.1.0, SMP only ran on humanoids and on armor you equipped. This example shows the two
new pieces that let a plain, unarmored creature get physics from a config file alone:

- **`SKSE/Plugins/hdtSkinnedMeshConfigs/FSMP_Example_WolfTail.xml`** — a **bone-only** physics
  system. It declares **no mesh shape at all**: SMP simulates the tail bones as rigid bodies and
  writes their transforms back to the skeleton every frame, and the creature's own vanilla tail
  mesh — already skinned to those bones — simply follows. That is why this mod ships **no meshes and
  no textures** and needs no NIF edit. Inside it demonstrates:
  - a **kinematic anchor** (`Canine_Pelvis`, mass 0) that stays glued to the body, declared *before*
    the mass-bearing `<bone-default>` so it inherits the built-in kinematic template;
  - three **dynamic segments** (`Canine_Tail1/2/3`) declared *after* that default, so they swing;
  - one reusable **hinge template** (`<generic-constraint-default>`) chaining the segments with a
    loose but bounded cone of motion — no springs, so gravity and the creature's motion do all the
    work, and the bounds stop the tail folding back on itself.

- **`SKSE/Plugins/hdtSkinnedMeshConfigs/defaultBBPs.xml`** — the **per-race default** that binds the
  physics file to canines. FSMP 4.1.0 added the `<creature>` mapping, keyed on the race's **skeleton
  NIF path**, and applies the file to any matching creature that has no embedded-tag physics and
  nothing equipped. Three skeleton paths are listed so it covers both the vanilla shared skeleton
  (`Actors\Canine\Character Assets\skeleton.nif`) and XPMSSE-style split skeletons
  (`...Character Assets Wolf\` / `Dog\`).

The physics file passes the FSMP `smp report` validator with **0 errors, 0 warnings**.

---

## Requirements

Install **all** of these first. This mod ships **only XML config** — no meshes or textures — and the
tail mesh it animates is the **vanilla** canine mesh, so no art mod is required.

1. **[SKSE64](http://skse.silverlock.org/)**
2. **[Faster HDT-SMP (FSMP)](https://www.nexusmods.com/skyrimspecialedition/mods/57339)** version
   **4.1.0 or newer** — the release that introduced creature & animal physics. Turn on *Enable
   creature & animal physics* in the FSMP config menu (**Simplification → Creatures & animals**); it
   is off by default.

That is all. The canine skeleton and tail mesh are base-game assets. [XPMSSE](https://www.nexusmods.com/skyrimspecialedition/mods/1988)
is supported but not required — its split canine skeletons are covered by the extra entries in
`defaultBBPs.xml`.

## Installation

Install with a mod manager (MO2/Vortex). The mod adds two files:

```
SKSE/Plugins/hdtSkinnedMeshConfigs/FSMP_Example_WolfTail.xml   (new physics file)
SKSE/Plugins/hdtSkinnedMeshConfigs/defaultBBPs.xml             (per-race default mapping)
```

> ⚠️ **`defaultBBPs.xml` is a single-winner file.** Only one `defaultBBPs.xml` is visible through the
> mod manager's virtual file system, so if another mod (for example a body mod) ships its own, only
> the highest-priority one is read and the others are ignored. In a real load order **merge** the
> three `<creature>` lines from this file into your existing `defaultBBPs.xml` rather than letting one
> override the other — otherwise you would silently drop that other mod's mappings. See the
> [Creatures and animals](https://github.com/DaymareOn/FSMP-Validator/wiki) wiki page for the
> alternatives.

Then load a save near a wolf or dog (or `player.placeatme` one) with the creature toggle on, and its
tail will start to swing. If nothing moves, set the FSMP log level to **Debug** and look for the line
`creature physics: race ... skeleton model '...'` — it prints the exact skeleton path that race uses,
which is what the `skeleton=` attribute must match.

---

## Credits

- **Skyrim / the canine skeleton and tail mesh** — Bethesda. Base-game assets this config animates;
  nothing of theirs is redistributed here.
- **HDT-SMP / Faster HDT-SMP** — HydrogensaysHDT and the FSMP maintainers. The physics engine and the
  creature-physics feature.
- **DaydreamingDay** — this physics config and the example.

## Permissions

This mod contains only original XML configuration authored by DaydreamingDay. It **redistributes no
art assets** (no meshes, no textures) — the canine skeleton and tail mesh are Bethesda's base-game
assets, animated in place. Use it freely as a starting point for your own creature-physics configs.
