#!/bin/sh

cd "$(dirname "$0")"
python bin/esptool.py erase_flash
