# Crossed Cloak — FSMP Pattern Example

**Version 0.1.0** · an FSMP (Faster HDT-SMP) **pattern** demonstration mod.

This is a worked example for the [FSMP modder guide](https://github.com/DaymareOn/FSMP-Validator/wiki): it rebuilds the
physics of one Cloaks of Skyrim cloak as a **crossed 2-D tissue** using the FSMP *pattern*
macro feature, instead of hand-writing every bone and constraint. It is meant to be read
alongside the two source files, which are heavily commented.

> ⚠️ **Requires FSMP 4.0.1 or newer** — the release that introduced pattern support. An
> older FSMP, or the original HDT-SMP, will fail to load this file.

---

## What it demonstrates

The required Cloaks of Skyrim cloak NIF is a 3×6 grid of `CB` cloth bones (`CB 01 1` …
`CB 03 6`) wired as three independent vertical chains. This example keeps the **same real NIF
bones** but reorganises the physics:

- **`patterns/DaydreamingDay.xml`** — a shared pattern library. It defines one reusable
  pattern, `DaydreamingDay.cloak`, that emits the whole cloth structure:
  - the CB grid (parameterised by `cols`/`rows`),
  - **warp** constraints chaining each column top-to-bottom (locked near the neck, lightly
    limited lower down),
  - **weft** constraints tying adjacent columns at the same row — a deliberately loose,
    non-Hookean spring so the cloak drapes as a sheet without going rigid.
  - The weft tuning is exposed as parameters (`weftStiffness`, `weftLinearLimit`, …) with
    sensible defaults.
- **`cloak.xml`** — the consumer. It declares only what is specific to *this* NIF — the
  collision shapes (the body meshes, the cloak itself, and the NIF's `VirtualGround`
  plane, kept from the original config so the cloak drapes on a virtual floor instead of
  falling through it) and the body skeleton bones those shapes skin to — and invokes the
  pattern with one line, overriding two weft knobs:

  ```xml
  <pattern name="DaydreamingDay.cloak" weftStiffness="6" weftLinearLimit="1.5"/>
  ```

At load time FSMP expands that single tag into 18 bones and 25 constraints. Dropping
`DaydreamingDay.xml` into the global `patterns/` folder makes the pattern available to every
physics file, so other cloaks can reuse the same structure with their own tuning.

The expanded document passes the FSMP `smp report` validator with **0 errors, 0 warnings**.

---

## Requirements

Install **all** of these first, in this order. This mod ships **only XML config** — no
meshes or textures — so the cloak itself comes entirely from the mods below.

1. **[SKSE64](http://skse.silverlock.org/)**
2. **[Faster HDT-SMP (FSMP)](https://www.nexusmods.com/skyrimspecialedition/mods/57339)**
   version **4.0.1 or newer** — the release that introduced pattern support. An older FSMP,
   or the original HDT-SMP, will fail to load this file.
3. **[Cloaks of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/6369)** (Nikinoodles
   & Nazenn) — the base cloak items, meshes and textures.
4. **[Artesian Cloaks of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/17416)** —
   the SMP-enabled cloak NIFs (`Meshes\Clothes\cloaksofskyrim\`) whose `CB` bones this config
   binds to.

## Installation

Install with a mod manager (MO2/Vortex) **after** the cloak mods above, and let it
**overwrite**. This mod replaces the SMP cloak patch's `cloak.xml` with the pattern-based
version and adds the shared `patterns/DaydreamingDay.xml`:

```
SKSE/Plugins/hdtSkinnedMeshConfigs/cloak.xml                  (replaces the patch's)
SKSE/Plugins/hdtSkinnedMeshConfigs/patterns/DaydreamingDay.xml (new, shared library)
```

It only changes the **cloak** physics. The patch's `cape.xml` is left untouched.

---

## Credits

- **Cloaks of Skyrim** — Nikinoodles & Nazenn. Base cloak meshes, textures and items.
- **Artesian Cloaks of Skyrim** — Zeridian and Rosent. The SMP-enabled cloak NIFs and the
  original `cloak.xml` this example is derived from.
- **HDT-SMP / Faster HDT-SMP** — HydrogensaysHDT and the FSMP maintainers. The physics engine
  and the pattern feature.
- **DaydreamingDay** — the pattern, this reimplementation, and the example.

## Permissions

This mod contains only original XML configuration authored by DaydreamingDay, derived from
Artesian Cloaks of Skyrim's `cloak.xml`. It **redistributes no art assets** (no meshes, no
textures) — those remain with their original authors and are obtained by installing the
required mods above. Artesian Cloaks of Skyrim's permissions explicitly forbid redistributing
its art assets, which this example respects by depending on it rather than bundling it.
