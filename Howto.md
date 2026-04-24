### Engineering Skinned Mesh Physics: A Technical Manual for Faster HDT-SMP

This manual provides a comprehensive protocol for transforming static Skyrim objects into dynamically simulated assets using the **Faster HDT-SMP (FSMP)** framework. This guide emphasizes the balance between high-fidelity simulation and computational performance.

---

### Phase 1: Foundations and Software Requirements

The transition from the legacy **HDT Physics Extension (HDT-PE)** to **HDT-SMP** marked a shift from the integrated Havok engine to the open-source **Bullet Physics** engine. Unlike Havok, which Bethesda restricted to basic environmental collisions, Bullet allows for complex, real-time deformation of cloth, hair, and soft bodies. **Faster HDT-SMP** further optimizes this by introducing multithreading and Advanced Vector Extensions (AVX), distributing the physics load across multiple CPU cores rather than bottlenecking a single thread.

#### Required Toolkit

1. **Blender (Version 3.6 or 4.0 recommended):** The primary 3D modeling environment.
2. **PyNIFly Plugin:** The modern standard for importing and exporting .NIF files directly in Blender without the bugs of older NifTools scripts.
3. **Outfit Studio:** Essential for "conforming" meshes to different body types and copying bone weights.
4. **NifSkope (Version 2.0 Pre-Alpha 3):** Used for editing metadata and linking the mesh to the physics logic.
5. **XP32 Maximum Skeleton Extended (XPMSSE):** This skeleton must serve as your reference. It contains the specific nodes required by the physics engine to calculate collisions.

---

### Phase 2: Geometric Design and Optimization

Performance in FSMP is directly correlated to the number of vertices and triangles involved in collision tests. Direct simulation of a high-resolution visual mesh is a fundamental error that leads to massive FPS drops.

#### The Proxy Mesh Protocol

To maintain 60 FPS, use a **proxy mesh**—a low-resolution version of the object used only for simulation.

- **Separation of Concerns:** The high-detail visual mesh is "weighted" to follow the movement of the low-detail proxy mesh.
- **Topology:** Meshes must strictly consist of **triangles or quadrilaterals**. Complex polygons (n-gons) cause calculation failures and visual artifacts during export.
- **Vertex Density:** For a simple cape, use a low density of points. For complex multi-layered skirts, use a medium density, but avoid exceeding vanilla polycounts for collision assets.

---

### Phase 3: Rigging and Skeletal Hierarchy

Rigging for physics differs from standard animation. Bones are not just deformation handles; they are physical entities with mass and inertia.

#### Kinematic vs. Dynamic Bones

- **Kinematic Bones:** These have a **mass of 0** in the XML configuration. They follow the game's predefined animations (e.g., the pelvis or spine) and serve as fixed **anchor points**.
- **Dynamic Bones:** These are the "beads" on the chain. Their position and rotation are calculated in real-time by the Bullet engine based on gravity, inertia, and collisions.

#### Weight Painting Essentials

Every vertex must be influenced by at least one bone. If a vertex is "unweighted," it lacks a parent reference and will "fall" to the world center (0,0,0). This is the most common cause of "melting" or infinite stretching where the mesh appears to be pulled into the ground.

---

### Phase 4: XML Logic Configuration

The XML file is the brain of the simulation. It defines how the object responds to forces.

#### Crucial Tag Definitions

- **`<mass>`:** Sets the "weight" of the bone. An anchor bone must be 0.

- **`<inertia>`:** An inverse scale factor applied to the bone's local inertia tensor. The default is 0, which skips inertia calculation entirely. **Strongly recommended: set to 1** for physically realistic behaviour. Values below 1 increase the effective inertia; values above 1 decrease it. Setting it to 0 does not crash the simulation — it simply omits the inertia contribution.

- **`<linearDamping>` and `<angularDamping>`:** Damping coefficients between 0 and 1 that dissipate kinetic energy each physics step. Both default to **0**. `linearDamping` on bones is a blunt per-step velocity reduction and is recommended to remain at 0 on bones; it is more useful when applied to constraints. `angularDamping` reduces rotational velocity using the formula `angularVelocity *= pow(1 - angularDamping, timeStep)`. Tune these values carefully to reduce bouncing and jitter without over-damping the motion.

- **`<margin>`:** A positive floating-point value that inflates the collision shape boundary used by the Bullet Physics engine. Defaults to **1**. A larger margin makes collision detection more stable but can cause objects to appear to float slightly above surfaces. Values that are too small increase the risk of tunneling (objects passing through each other).

- **`<restitution>`:** Controls bounciness. Defaults to 0. Higher values make the object more elastic.

#### Constraints (Generic 6DOF)

Constraints limit how far bones can twist or stretch.

- **Linear Limits** (`<linearLowerLimit>` / `<linearUpperLimit>`): These default to `(1, 1, 1)` and `(-1, -1, -1)` respectively. Because the lower limit is greater than the upper limit, **no linear constraint is applied by default** — this is intentional, not a bug. To prevent fabric from stretching like rubber, explicitly set both limits to `(0, 0, 0)` to lock all linear axes, or use small symmetrical values to permit minimal stretch.

- **Angular Limits** (`<angularLowerLimit>` / `<angularUpperLimit>`): Define the "feel" of the material. Leather requires tight limits (e.g., ±0.2 radians), while lightweight cloth can allow rotations over 90 degrees (±1.57 radians).

---

### Phase 5: NIF Implementation and Metadata

Once the NIF and XML are ready, they must be linked. Skyrim does not automatically recognize the XML file; you must embed the path within the NIF.

1. **Open the NIF in NifSkope.**
2. **Insert the Metadata Block:** Right-click the **Scene Root**, select `Block > Insert`, and choose **NiStringExtraData**.
3. **Name the Block:** The name must be exactly **HDT Skinned Mesh Physics Object** (case-sensitive).
4. **Set the Path:** In the `String Data` field, enter the relative path to your XML (e.g., `SKSE\Plugins\hdtSkinnedMeshConfigs\MyMod.xml`).
5. **Reference the Node:** Ensure the `NiStringExtraData` block number is added to the **Extra Data List** of the Scene Root NiNode.

---

### Phase 6: Performance Optimization

Faster HDT-SMP provides advanced software-level optimizations to maintain fluidity in complex scenes.

#### CPU and Instruction Sets

The FSMP plugin is compiled in different versions. Choose the one that matches your CPU's capabilities:

- **AVX2:** Standard for Intel Haswell/AMD Ryzen and newer. Provides a major performance boost.
- **AVX512:** Performance peak for modern high-end processors (AMD Ryzen 7000 series, Intel Sapphire Rapids/Alder Lake and newer).
- **CUDA:** Currently in development, it offloads collision math to the GPU. It is most effective on systems with many actors and a powerful NVIDIA card, but may be less stable than CPU-based simulation.

#### Culling and Distance Management

Edit the global `configs.xml` to manage how many actors consume physics resources:

- **`minCullingDistance`** (default: `500` units): The minimum distance from the camera below which a skeleton is *never* culled. Increase this value to force more nearby skeletons to remain active even when the maximum active skeleton count would otherwise cut them off.

- **`autoAdjustMaxSkeletons`** (default: `false`) and **`maximumActiveSkeletons`** (default: `20`): Enable dynamic throttling of the active skeleton count to stay within a configurable performance budget. When `autoAdjustMaxSkeletons` is `true`, FSMP will automatically reduce the number of active skeletons to keep physics processing within the time allocated by `budgetMs` (default: `3.5` ms per frame).

- **FOV-based culling** is handled automatically by FSMP (default angle: ±45°). It is not currently configurable through `configs.xml`.

---

### Phase 7: Troubleshooting and Debugging

#### Common Visual Glitches

- **Melting/Stretching:** Most commonly caused by unweighted vertices (see Phase 3). If the skeleton is correctly weighted, the issue may be an unstable simulation caused by springs that are too stiff or damping that is too low. In the XML, try reducing `<angularStiffness>` and `<linearStiffness>`, or increasing `<angularDamping>` and `<linearDamping>` on the relevant constraints. If the problem affects all characters, try increasing `maxSubSteps` or raising `min-fps` in `configs.xml` to give the physics engine more substep resolution.

  > ⚠️ **Note:** The tag `<hkparam name="maxLinearVelocity">` belongs to the legacy **HDT Physics Extension (HDT-PE)** and uses Havok XML syntax. It has no effect in FSMP, which uses the Bullet Physics engine and a completely different XML schema.

- **Invisible Meshes:** Often caused by a mismatched DLL version for your specific Skyrim executable (SE vs. AE).

- **Jumping/Flapping:** Usually indicates that damping values are too low or constraints are too loose.

#### Console Commands for Developers

Use these commands to diagnose issues in real-time:

- **`smp reset`:** Reloads XML configs and reinitializes the physics world. Use this to see changes without restarting the game.

- **`smp list`:** Lists all tracked skeletons and their active/inactive state. Useful for checking which NPCs have physics running in crowded areas.

- **`smp detail`:** Like `smp list`, but also prints each tracked armor addon and head part with their physics status and active collision meshes.

- **`smp on` / `smp off`:** Enables or disables HDT-SMP physics globally at runtime.

  > ⚠️ **Note:** There is no `smp timing` command in FSMP. This command existed in legacy HDT-SMP but was not carried over. For performance analysis, enable `autoAdjustMaxSkeletons` in `configs.xml` and set `logLevel` to `4` (debug) to observe per-frame physics processing times in the log file.
