#!/bin/sh

cd "$(dirname "$0")"
python bin/esptool.py  --chip esp32 --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode qout --flash_freq 80m --flash_size detect 0x10000 ../firmware/firmware.bin
