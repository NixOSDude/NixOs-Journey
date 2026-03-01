#!/usr/bin/env bash
qemu-system-x86_64 \
  -m 8G \
  -smp 8 \
  -cpu host \
  -enable-kvm \
  -drive file=ubuntu-disk.qcow2,format=qcow2 \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -display gtk,zoom-to-fit=on \
  -vga virtio
