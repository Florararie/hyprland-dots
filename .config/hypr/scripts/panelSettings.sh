#!/bin/bash

if pgrep -f "wayle shell" > /dev/null; then
    wayle panel settings
elif pgrep -f "noctalia-shell" > /dev/null; then
    qs -c noctalia-shell ipc call settings open
fi