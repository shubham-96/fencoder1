#!/bin/bash

set -euo pipefail
exec > /var/log/mount-ebs.log 2>&1

DEVICE=/dev/nvme1n1
MOUNTPOINT=/mnt/data
TIMEOUT=60
SLEEP_INTERVAL=5
ELAPSED=0

echo "[INFO] Waiting for device $DEVICE to be ready..."
while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  if [ -e $DEVICE ]; then
    echo "[INFO] Device $DEVICE is ready."
    break
  fi
  echo "[WARN] Device $DEVICE not found. Retrying in $SLEEP_INTERVAL seconds..."
  sleep "$SLEEP_INTERVAL"
  ELAPSED=$((ELAPSED + SLEEP_INTERVAL))
done

if [ ! -b "$DEVICE" ]; then
  echo "[ERROR] Device $DEVICE not found after 30s. Exiting."
  exit 1
fi

FSTYPE=$(blkid -s TYPE -o value "$DEVICE" || true)
if [ -z "$FSTYPE" ]; then
  echo "[INFO] No filesystem found. Formatting as ext4..."
  mkfs.ext4 -F "$DEVICE"
else
  echo "[INFO] Found existing filesystem: $FSTYPE"
fi

mkdir -p $MOUNTPOINT
mount $DEVICE $MOUNTPOINT
echo "[INFO] Mounted $DEVICE to $MOUNTPOINT"

# Change ownership to default user for Ubuntu AMIs
chown ubuntu:ubuntu $MOUNTPOINT
echo "[INFO] Changed ownership to ec2-user"

UUID=$(blkid -s UUID -o value "$DEVICE")
if ! grep -q "$UUID" /etc/fstab; then
  echo "UUID=$UUID $MOUNTPOINT ext4 defaults,nofail 0 2" >> /etc/fstab
  echo "[INFO] Added entry to /etc/fstab"
else
  echo "[INFO] UUID already present in /etc/fstab"
fi