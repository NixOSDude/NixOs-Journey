# 🌌 The NixOS Engineering Journal

A documented progression into **NixOS System Engineering and the Nix Language**. 

This is an independent deep-dive into the Nix ecosystem—moving beyond standard configurations into custom infrastructure, distributed orchestration, and pure functional system design. 

## 🛠️ The Control Plane
* **Primary Node:** Intel Core Ultra 7 265KF (20 Cores) | 64GB RAM
* **Graphics:** NVIDIA GeForce RTX 3060
* **OS:** NixOS 25.11 (Plasma 6.5.5 / Wayland)
* **Philosophy:** Pure Functional (Stateless, Immutable, Declarative).

## 📂 The Battle Logs
Each entry below represents a successfully navigated architectural hurdle. These are the technical post-mortems of system implementation:

* **[PXE Orchestration & Stateless Lab Deployment](./pxe-server.readme.md)**
    * Deployment of a diskless worker node (Dell E5570) via the Ultra 7.
    * Overcoming kernel/LVM hardware locks and achieving automated storage persistence in a RAM-only environment.

* **[Final Project: TBD]**
    * The culmination of the NixOS/Nix engineering journey.

---

## 🧭 Principles
* **Declarative Sovereignty:** The `.nix` configuration is the only source of truth.
* **Hardware Abstraction:** Treating physical machines as ephemeral resources served by the Control Plane.
* **Immutable Logic:** Solving infrastructure challenges through functional derivation rather than imperative patching.
