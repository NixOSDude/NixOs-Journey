# 🛠️ Battle Log: PXE Orchestration & Stateless Lab

### **The Objective**
Establish a stateless, network-booted (PXE) worker node using a Dell E5570 ("nixlab"), served entirely by the Ultra 7 control plane.

### **The Hurdles**

#### 1. The LVM "Busy" Lock
* **The Struggle:** Attempting to format the internal 1TB drive for lab storage resulted in `Device or resource busy`. 
* **The Reality:** Residual LVM and Swap signatures from a previous OS were automatically claimed by the kernel at boot, locking the hardware.
* **The Fix:** Forcibly deactivating Volume Groups (`vgchange -an`) and clearing device mapper nodes (`dmsetup remove_all`) to release the kernel's grip.

#### 2. Kernel Cognitive Dissonance
* **The Struggle:** `parted` successfully wrote a new GPT table, but `mkfs.ext4` claimed the device `/dev/sda1` did not exist.
* **The Reality:** The kernel was protecting its active memory map of the disk. Since the device was "busy" during the initial partitioning, the `ioctl` to refresh the table failed.
* **The Fix:** Orchestrated a synchronized reboot where the Ultra 7 served a fresh image containing the `fileSystems` logic, forcing the Dell's kernel to re-scan the hardware on wake.

#### 3. Identity Injection
* **The Struggle:** Eliminating manual friction (passwords) for a remote, headless node.
* **The Victory:** Injected Ed25519 SSH keys and `wheelNeedsPassword = false` directly into the `netboot-minimal` derivation.

### **The Result**
A "Zero-Touch" lab node. The Dell boots into RAM, identifies as `nixlab`, and automatically mounts a 916GB persistent storage block at `/mnt/lab` based on the disk label `DEll_LAB`.
