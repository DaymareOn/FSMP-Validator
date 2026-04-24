# Understanding Triangles and Vertexes in FSMP XML Configuration

## Table of Contents
1. [Fundamental Concepts](#fundamental-concepts)
2. [The Triangle vs Vertex Distinction](#the-triangle-vs-vertex-distinction)
3. [How FSMP Uses These Concepts](#how-fsmp-uses-these-concepts)
4. [Performance Optimization Guide](#performance-optimization-guide)
5. [Common Misconceptions](#common-misconceptions)

---

## Fundamental Concepts

Before discussing triangles and vertexes in the context of FSMP (Free Skyrim Mesh Physics), it's essential to understand basic 3D mesh terminology.

### What is a Vertex?

A **vertex** (plural: vertices or vertexes) is a single point in 3D space with X, Y, and Z coordinates. In a mesh, vertices are the fundamental building blocks—they define the positions of corners and joints in your model.

**Example:** A simple cube has 8 vertices at its corners.

### What is a Triangle?

A **triangle** is the basic polygon surface element in 3D graphics. It is defined by exactly 3 vertices connected together. Every visible surface in a 3D mesh is composed of one or more triangles.

**Why triangles?** Because any surface can be broken down into triangles, and graphics engines are highly optimized to process triangular geometry. This is true for both rendering and physics simulation.

**Example:** A simple cube consists of 12 triangles (2 per face × 6 faces).

---

## The Triangle vs Vertex Distinction

### In Traditional 3D Graphics

In rendering, **triangles** are the rendering primitives. Your GPU processes vertices to display triangles. A single vertex can be shared by multiple triangles.

### In Physics Simulation (FSMP)

This is where the distinction becomes critical for performance and correctness:

- **Per-Triangle Shapes** (`<per-triangle-shape>`) - Collision is calculated and applied at the triangle level
- **Per-Vertex Shapes** (`<per-vertex-shape>`) - Collision detection operates at individual vertex points

### Why FSMP Prefers Per-Triangle Shapes

The FSMP physics engine uses Bullet Physics, which is optimized for triangle-based collision detection. Here's why per-triangle shapes are the standard:

1. **Efficiency**: Triangle collision detection is mathematically optimized and faster to compute
2. **Stability**: Triangle meshes provide more stable and predictable collision surfaces
3. **Accuracy**: Collisions at triangle centers/surfaces are more accurate for cloth simulation
4. **Per-Triangle Configuration**: Each triangle can have its own collision properties, weight thresholds, and behavior settings

---

## How FSMP Uses These Concepts

### Per-Triangle Shapes

A **per-triangle shape** divides the mesh surface into its component triangles and applies physics to each triangle independently.

```xml
<per-triangle-shape>
    <margin>0.05</margin>
    <tag>chest_cloth</tag>
    <weight-threshold bone="Chest" value="0.1"/>
    <weight-threshold bone="Shoulder" value="0.05"/>
</per-triangle-shape>
```

**What happens:**
- Each triangle of the mesh becomes a collision surface
- When cloth simulation runs, collisions are detected per-triangle
- The weight thresholds apply to each triangle's skinning weights
- Performance scales with triangle count

### Weight Thresholds

The `weight-threshold` attribute is **per-triangle**, meaning:

```
For each triangle:
    For each bone influencing that triangle:
        If that bone's weight < weight-threshold:
            That triangle ignores that bone's influence
```

This allows fine-grained control over which bones affect which parts of your mesh.

### Per-Vertex Shapes (Less Common)

A **per-vertex shape** applies collision detection at individual vertex positions:

```xml
<per-vertex-shape>
    <margin>0.05</margin>
    <weight-threshold bone="Chest" value="0.1"/>
</per-vertex-shape>
```

**When to avoid:** Per-vertex shapes require more calculations because vertices are collision points individually. Since most vertices are shared by multiple triangles, this can lead to redundant collision checks and increased CPU overhead.

---

## Performance Optimization Guide

### 1. Use Appropriate Shape Types

| Shape Type | Use Case | Performance Impact |
|-----------|----------|-------------------|
| `per-triangle-shape` | General cloth/mesh collision | Optimal for most cases |
| `per-vertex-shape` | Specialized per-vertex control | Higher CPU cost, rarely needed |
| `capsule`, `sphere`, `box` | Body/bone collision | Very fast, use for non-cloth parts |
| `hull` (Convex Hull) | Complex rigid bodies | Fast, better than triangle mesh |

**Recommendation:** Default to `per-triangle-shape` for cloth meshes. Use primitive shapes (capsule, sphere, box) for skeletal bones whenever possible.

### 2. Optimize Triangle Count

Since collision is calculated per-triangle, reducing triangle count directly improves performance.

**Strategies:**
- Model using low-poly meshes when possible
- Use LOD (Level of Detail) models for distant objects
- Combine small mesh pieces into single per-triangle shapes
- Use bone colliders instead of mesh colliders for structural elements

**Example impact:** A 5,000-triangle mesh requires 5,000 collision checks per frame. A 2,000-triangle mesh requires only 2,000.

### 3. Effective Use of Weight Thresholds

Weight thresholds prevent unnecessary calculations by excluding bones with minimal influence.

```xml
<!-- BAD: No thresholds, all bones evaluated for all triangles -->
<per-triangle-shape>
    <margin>0.05</margin>
</per-triangle-shape>

<!-- GOOD: Exclude bones with negligible influence -->
<per-triangle-shape>
    <margin>0.05</margin>
    <weight-threshold bone="Chest" value="0.1"/>
    <weight-threshold bone="Shoulder" value="0.05"/>
    <weight-threshold bone="Spine1" value="0.05"/>
</per-triangle-shape>
```

**Performance benefit:** Each excluded bone reduces per-triangle calculations. On a 5,000-triangle mesh with 10 bones, proper thresholds can reduce calculations by 30-50%.

### 4. Spring Frequency Limits (Critical!)

Spring frequency controls how often stiffness calculations occur. This is one of the biggest performance bottlenecks:

```xml
<!-- In FSMP 2.x, these are enabled by default -->
<linearSpringFrequency>0.25</linearSpringFrequency>
<angularSpringFrequency>0.25</angularSpringFrequency>

<!-- These limit spring calculations for FPS stability -->
<linearStiffnessLimited>true</linearStiffnessLimited>
<angularStiffnessLimited>true</angularStiffnessLimited>
```

**Important:** The schema warns that these limits are very conservative:
> "Honestly, you should set it to false and set your stiffness at the right level, because this limit is way too high: when you attain it, the spring will oscillate around once every 4 frames, you will perceive incredible jittering!"

**Optimization steps:**
1. Set `linearStiffnessLimited` and `angularStiffnessLimited` to **false**
2. Tune stiffness values appropriately instead of relying on limits
3. Use lower stiffness values to reduce calculation intensity

### 5. Disable Unused Springs

Springs consume CPU resources even when minimal. Disable them when not needed:

```xml
<!-- Disable springs that aren't contributing to the effect -->
<generic-constraint bodyA="bone1" bodyB="bone2">
    <enableLinearSprings>false</enableLinearSprings>
    <enableAngularSprings>true</enableAngularSprings>
</generic-constraint>
```

**Performance benefit:** Disabling one spring type per constraint can save ~30% of constraint computation.

### 6. Reduce Constraint Count

Every constraint (connection between bones) requires calculation:

```xml
<!-- Instead of many small constraints: -->
<generic-constraint bodyA="Chest" bodyB="Breast01"/>
<generic-constraint bodyA="Chest" bodyB="Breast02"/>
<generic-constraint bodyA="Breast01" bodyB="Breast02"/>
<generic-constraint bodyA="Breast01" bodyB="Breast03"/>

<!-- Use fewer, better-tuned constraints: -->
<generic-constraint bodyA="Chest" bodyB="Breast02">
    <linearStiffness x="100" y="100" z="100"/>
</generic-constraint>
<generic-constraint bodyA="Breast01" bodyB="Breast02">
    <linearStiffness x="80" y="80" z="80"/>
</generic-constraint>
```

**Impact:** Each constraint removed reduces per-frame physics calculations significantly.

### 7. Optimize Bone Mass Distribution

Higher mass requires more calculation:

```xml
<!-- Use reasonable mass values -->
<bone name="Breast01">
    <mass>0.5</mass>  <!-- Good: Light enough for movement -->
</bone>

<!-- Avoid extreme values -->
<bone name="Breast01">
    <mass>10</mass>   <!-- Bad: Very heavy, excessive calculations -->
</bone>

<!-- Zero mass = static/kinematic bone = NO calculations -->
<bone name="AttachPoint">
    <mass>0</mass>    <!-- Good: For attachment points -->
</bone>
```

### 8. Margin Optimization

Margin affects collision distance and detection:

```xml
<!-- Smaller margin = fewer collision checks -->
<per-triangle-shape>
    <margin>0.01</margin>  <!-- Tight collision, fewer checks -->
</per-triangle-shape>

<!-- Larger margin = more collision detection overhead -->
<per-triangle-shape>
    <margin>0.5</margin>   <!-- Loose collision, more checks -->
</per-triangle-shape>
```

**Recommendation:** Use the smallest margin that avoids clipping (typically 0.01 - 0.05).

### 9. Shared Visibility Optimization

Shape visibility settings affect which collisions are processed:

```xml
<!-- public: Highest processing cost (default) -->
<per-triangle-shape shared="public"/>

<!-- internal: Doesn't collide with other skeletons -->
<per-triangle-shape shared="internal"/>

<!-- external: Doesn't collide with same skeleton -->
<per-triangle-shape shared="external"/>

<!-- private: Doesn't collide with other meshes -->
<per-triangle-shape shared="private"/>
```

**Optimization:** Use the most restrictive visibility level that doesn't break your intended collisions.

### 10. Damping Configuration

High damping values increase calculations but reduce instability:

```xml
<!-- FSMP 1.x and 2.x behavior differs -->

<!-- Bones: Use low damping -->
<bone name="Breast01">
    <linearDamping>0</linearDamping>   <!-- Good: No bone damping -->
    <angularDamping>0</angularDamping>
</bone>

<!-- Constraints: Tune damping for stability without excess -->
<generic-constraint bodyA="Chest" bodyB="Breast01">
    <linearDamping x="0.1" y="0.1" z="0.1"/>  <!-- Moderate damping -->
</generic-constraint>
```

---

## Performance Optimization Checklist

Create your FSMP configuration files with this checklist:

- [ ] Use `per-triangle-shape` instead of `per-vertex-shape`
- [ ] Minimize triangle count (use low-poly meshes)
- [ ] Set appropriate weight thresholds to exclude negligible bone influences
- [ ] Disable `linearStiffnessLimited` and `angularStiffnessLimited`
- [ ] Tune stiffness values appropriately instead of using limits
- [ ] Disable unnecessary springs (`enableLinearSprings=false` or `enableAngularSprings=false`)
- [ ] Minimize constraint count; use fewer, better-tuned connections
- [ ] Use reasonable bone masses (typically 0.1 - 2.0 for cloth)
- [ ] Set mass to 0 for attachment points (no physics calculation)
- [ ] Use smallest margin that avoids clipping (0.01 - 0.05)
- [ ] Use the most restrictive `shared` visibility level
- [ ] Use low damping on bones, moderate damping on constraints
- [ ] Use primitive shapes (box, sphere, capsule) for skeletal bones
- [ ] Use bone-level colliders instead of mesh colliders when possible
- [ ] Test with FPS monitoring in-game to verify improvements

---

## Common Misconceptions

### ❌ "Vertexes are what cause collision"
**Correct:** Triangles are collision surfaces. Vertices define the corners of triangles but aren't collision points themselves. Collision detection happens at the triangle level (surface area), not at individual vertices.

### ❌ "More vertices = better physics"
**Correct:** More vertices usually mean more triangles, which means more collision calculations and slower performance. Better physics comes from better configuration, not more geometry.

### ❌ "Per-vertex shapes are more accurate"
**Correct:** Per-vertex shapes are less accurate and slower. They create collision points at individual vertices, which can create instability and gaps between vertices. Triangle-based collision provides better coverage and stability.

### ❌ "Spring frequency limits protect FPS"
**Correct:** Spring frequency limits (when enabled) actually cause jittering when hit. The schema notes they're too conservative. Better to disable them and tune stiffness values appropriately.

### ❌ "Higher mass makes physics more realistic"
**Correct:** Higher mass increases calculation overhead. Realistic physics comes from proper constraint tuning, not mass values. Use light masses (0.1 - 1.0) for cloth.

### ❌ "More constraints = better results"
**Correct:** More constraints increase CPU cost. Better results come from properly-tuned constraints between key bones, not from constraining every bone to every neighbor.

### ❌ "Damping solves instability"
**Correct:** Damping is a band-aid. Instability usually comes from improper stiffness values, too-high mass, or too many constraints. Fix the root cause instead of over-damping.

---

## Summary

**Triangles and vertexes are different concepts:**
- **Vertexes** are points in space that define mesh corners
- **Triangles** are surfaces made from 3 vertexes
- FSMP physics operates on **triangles**, not individual vertexes

**For best performance:**
1. Use per-triangle shapes for mesh collision
2. Reduce triangle count through modeling
3. Use weight thresholds wisely
4. Disable conservative limits and tune stiffness values
5. Minimize constraints and springs to essential connections only
6. Use appropriate margins and visibility settings

This approach gives you both excellent performance and realistic physics simulation.
