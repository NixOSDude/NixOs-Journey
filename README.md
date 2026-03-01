# 🌌 The NixOS Engineering Journal

This repository is a live documentation of my independent study into **NixOS, Nix Language, and Pure Functional Infrastructure**. 

Nix isn't learned in a classroom; it's learned at the terminal. This is a journey driven by a love for high-tech architecture and the belief that infrastructure should be as pure and predictable as a mathematical function.

## 🛠️ The Tech Stack
* **Primary Engine:** Intel Ultra 7 265KF (20 Cores)
* **Graphics:** NVIDIA GeForce RTX 3060
* **OS:** NixOS 25.11 (Plasma 6.5.5 / Wayland)
* **Philosophy:** Pure FP (No nulls, Immutable values, Tail Recursion).

## 📂 Engineering Chapters (Independent Modules)
Each file below represents a solved architectural hurdle:

1. **[PXE Server & Remote Orchestration](./pxe-server.md)**
   * Status: **Complete**
   * Key Lessons: Stateless booting, SSH-key injection, LVM disk-lock resolution, and automated 1TB lab mounting.
   
2. **[The Haskell/C++23 Toolchain](./toolchain.md)**
   * Status: *In Progress*
   * Focus: Building O(n) complexity solutions using pinned Nix derivations.

3. **[Blockchain Infrastructure (finanskell.online)](./finanskell.md)**
   * Status: *Planned*
   * Focus: Deploying functional nodes to the cloud.

---

## 🧭 The Core Tenets
* **Declarative Truth:** If it isn't in the code, it doesn't exist.
* **Stateless Operation:** Boot from RAM, treat hardware as an ephemeral resource.
* **Pure Logic:** Aim for zero-side-effect configurations.
