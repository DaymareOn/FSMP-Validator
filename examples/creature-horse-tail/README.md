# Horse Tail — FSMP Creature Example

**Version 0.1.0** · an FSMP (Faster HDT-SMP) **creature-physics** demonstration mod.

This is a worked example for the [FSMP modder guide](https://github.com/DaymareOn/FSMP-Validator/wiki):
it gives Skyrim's horses a physics-driven tail that swings under gravity and the horse's own movement,
instead of the scripted tail-swish animation. It is a companion to the
[wolf-tail example](https://github.com/DaymareOn/FSMP-Validator/tree/main/examples/creature-wolf-tail),
showing the same technique on a **mount** — the tail keeps simulating while the horse is ridden.

> ⚠️ **Requires FSMP 4.1.0 or newer** — the release that introduced creature & animal physics —
> **and** the *Enable creature & animal physics* toggle turned **on** in the FSMP config menu
> (**Experimental → Creatures & animals**); it is off by default.

---

## What it demonstrates

The same two pieces as the wolf tail, on a rideable mount:

- **`SKSE/Plugins/hdtSkinnedMeshConfigs/FSMP_Example_HorseTail.xml`** — a **bone-only** physics system.
  It declares **no mesh shape**: SMP simulates the tail bones as rigid bodies and writes their
  transforms back to the skeleton, and the horse's own vanilla tail mesh — skinned to those bones —
  follows. A kinematic anchor at `HorsePelvis`, four dynamic segments `HorseTail1`…`HorseTail4`, and one
  reusable hinge template with a loose, bounded cone of motion (no springs). `HorseTail1`…`HorseTail4`
  are present in every horse skeleton (vanilla, XPMSSE, War Horse, Slim Horse), so this is portable.

- **`SKSE/Plugins/hdtSkinnedMeshConfigs/defaultBBPs/creature-horse-tail.xml`** — the **per-race default**
  that binds the physics file to the horse race by its skeleton path, shipped as a drop-in in the
  `defaultBBPs/` folder so it never clashes with other mods.

The physics file passes the FSMP `smp report` validator with **0 errors, 0 warnings**.

---

## Requirements

This mod ships **only XML config** — no meshes or textures — and the tail it animates is the vanilla
horse tail mesh, so no art mod is required.

1. **[SKSE64](http://skse.silverlock.org/)**
2. **[Faster HDT-SMP (FSMP)](https://www.nexusmods.com/skyrimspecialedition/mods/57339)** version
   **4.1.0 or newer**, with *Enable creature & animal physics* turned on (menu → **Experimental**).

The horse skeleton and tail mesh are base-game assets. [XPMSSE](https://www.nexusmods.com/skyrimspecialedition/mods/1988)
is supported but not required.

## Installation

Install with a mod manager (MO2/Vortex) after FSMP. It adds two files:

```
SKSE/Plugins/hdtSkinnedMeshConfigs/FSMP_Example_HorseTail.xml          (physics file)
SKSE/Plugins/hdtSkinnedMeshConfigs/defaultBBPs/creature-horse-tail.xml (per-race default mapping)
```

The mapping is a **drop-in** in the `defaultBBPs/` folder (FSMP 4.1.0+): FSMP reads it alongside the
single `defaultBBPs.xml` with no conflict — nothing to overwrite or merge. See
[Creatures and animals](https://github.com/DaymareOn/FSMP-Validator/wiki/22-%E2%80%90-Creatures-and-animals).

Then approach or summon a horse with the toggle on, and its tail will start to swing. Mount and ride —
the tail keeps simulating behind you. If nothing moves, set the FSMP log level to **Debug** and read
the line `creature physics: race ... skeleton model '...'`: that is the exact path the `skeleton=`
attribute must match for the horse you are testing.

---

## Credits

- **Skyrim / the horse skeleton and tail mesh** — Bethesda. Base-game assets this config animates;
  nothing of theirs is redistributed here.
- **HDT-SMP / Faster HDT-SMP** — HydrogensaysHDT and the FSMP maintainers. The physics engine and the
  creature-physics feature.
- **DaydreamingDay** — this physics config and the example.

## Permissions

This mod contains only original XML configuration authored by DaydreamingDay. It **redistributes no
art assets** — the horse skeleton and tail mesh are Bethesda's base-game assets, animated in place. Use
it freely as a starting point for your own creature-physics configs.
