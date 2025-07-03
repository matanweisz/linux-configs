# Save Gnome Extentions To a File:
```bash
dconf dump /org/gnome/shell/extensions/ > gnome-extensions.txt
```
# Load The Extensions From The File:
```bash
dconf load /org/gnome/shell/extensions/ < gnome-extensions.txt
```
