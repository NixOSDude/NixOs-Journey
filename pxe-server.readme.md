# 🛠️ Battle Log: The PXE "Stage 1" Trench War

## **1. The Objective: Sovereignty via the Wire**
The mission was deceptively simple: Turn the **Ultra 7 (NixOsEng)** into a high-performance Control Plane that serves a 100% functional, stateless NixOS environment to a **Dell Latitude E5570 (nixlab)** over the network. No USB sticks, no local SSD OS, no manual intervention.

## **2. The Reality Check: NixOS is Not a Distro, It’s a Compiler**
Coming from 15 years of "Imperative IT" (Ubuntu, Fedora, Windows Server), the first hurdle wasn't technical—it was mental. In those worlds, you `sudo nano` a file, you `chmod` a directory, and you "fix" things. In NixOS, those habits are "Anti-Patterns."

> **The Epiphany:** If you didn't define it in the `.nix` expression on the Ultra 7, it doesn't exist on the Dell. Period.

---

## **3. The Hurdles: Engineering the Bridge**

### **A. The "Stage 1" /mnt-root Death Loop**
* **The Struggle:** The Dell would catch the PXE signal, download the kernel, start the boot sequence... and then scream `/mnt-root` error before kernel-panicking. 
* **The Reality:** This is the "Nix Gatekeeper." The kernel was alive, but it couldn't find its "Brain" (the Nix Store). In a traditional netboot, the kernel expects to find a root filesystem on a disk.
* **The Fix:** We had to move the entire OS into the RAM. We refactored `pxe-server.nix` to build a **SquashFS** image containing the full system closure. By adding `boot.kernelParams = [ "copytoram" ];`, we forced the Dell to pull the entire Nix Store into its 24GB of RAM during Stage 1.

### **B. The `L+` Symlink Nightmare (Orchestrating `dnsmasq`)**
* **The Struggle:** `dnsmasq` kept reporting "File Not Found." We tried to treat `/srv/tftpboot` like a normal folder, but Nix kept wiping our changes or pointing to empty space.
* **The Reality:** NixOS is **Declarative**. You cannot manually "administer" a TFTP directory when the source files are immutable hashes that change every time you tweak the code.
* **The Fix:** We mastered `systemd.tmpfiles.rules` using the **`L+` (Link Plus)** argument.
    * **The Logic:** `L+ /srv/tftpboot/bzImage - - - - ${netboot.kernel}/bzImage`
    * The `+` is the "Hammer." It tells NixOS to overwrite any existing junk and force a dynamic bridge between the static PXE firmware and the ever-changing Nix Store.

### **C. Live Monitoring: Watching the Handshake**
* **The Reality:** You can't debug PXE in the dark. We had to monitor the Ultra 7's logs in real-time to see if the Dell was actually "talking" to us.
* **The Tool:** `sudo journalctl -u dnsmasq.service -f`
* **The Evidence:** Seeing these lines confirmed the orchestration was working:
  ```text
  Feb 28 18:47:24 NixOsEng dnsmasq-tftp: sent /srv/tftpboot/bzImage to 192.168.68.146
  Feb 28 18:48:07 NixOsEng dnsmasq-tftp: sent /srv/tftpboot/initrd to 192.168.68.146
  Feb 28 18:48:23 NixOsEng dnsmasq-dhcp: DHCPACK(enp129s0) 192.168.68.146 nixlab
