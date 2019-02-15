# Simple AUR Helper (SAH)

**Author:** zurg3 (Stepan Skryabin)
**Created:** 12.02.2019
**License:** GNU GPL v3

## Dependencies:
- bash
- sudo
- pacman
- coreutils
- git
- wget
- grep

## Examples:
Install package/packages from AUR
```
sah -S [package1] [package2] ...
```

Install package/packages from AUR and remove make dependencies
```
sah -S [package1] [package2] ... --rmd
```

Install package/packages from Pacman
```
sah -Sp [package1] [package2] ...
```

Update installed packages (Pacman + AUR)
```
sah -Syu
```

Update installed packages (Pacman + AUR) and remove make dependencies of updated AUR packages
```
sah -Syu --rmd
```

Remove package/packages
```
sah -R [package1] [package2] ...
```

Show installed packages (All)
```
sah -Qe
```

Show installed packages (AUR)
```
sah -Qm
```
