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

## Installation:
```
$ git clone https://github.com/zurg3/sah.git
$ cd sah
$ makepkg -si
$ cd ..
$ rm -rf sah
```

## Examples:
Install package/packages from AUR
```
$ sah -S [package1] [package2] ...
```

Install package/packages from AUR and remove make dependencies
```
$ sah -S [package1] [package2] ... --rmd
```

Install package/packages from Pacman
```
$ sah -Sp [package1] [package2] ...
```

Update installed packages (Pacman + AUR)
```
$ sah -Syu
```

Update installed packages (Pacman + AUR) and remove make dependencies of updated AUR packages
```
$ sah -Syu --rmd
```

Clean the package cache
```
$ sah -Sc
```

Remove package/packages
```
$ sah -R [package1] [package2] ...
```

Remove package/packages with dependencies which aren't required by any other installed packages
```
sah -Rs [package1] [package2] ...
```

Show installed packages (All)
```
$ sah -Qe
```

Show installed packages (AUR)
```
$ sah -Qm
```

Search for packages in the database
```
sah -Ss [package]
```

Search for already installed packages
```
sah -Qs [package]
```

Show information about package
```
sah -Si [package]
```

Show information about package (for locally installed packages)
```
sah -Qi [package]
```

Show all packages no longer required as dependencies (orphans)
```
sah -Qdt
```
