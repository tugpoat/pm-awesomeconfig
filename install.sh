#!/bin/bash
TARGET=$HOME/.config/awesome
cp dist/* $HOME/.config/awesome
cp lib/awesome-appmenu/awesome-appmenu "$TARGET"
cp lib/awesome-appmenu/menurc.py "$TARGT"
cp -rp lib/awesome-shifty/* "$TARGET/shifty"
