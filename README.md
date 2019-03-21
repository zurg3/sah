# Simple AUR Helper (SAH)

**Author:** zurg3 (Stepan Skryabin)

**Created:** 12.02.2019

**License:** GNU GPL v3

**Changelog** is [here](https://github.com/zurg3/sah/blob/master/changelog.txt)

**Version history** is [here](https://github.com/zurg3/sah/blob/master/version_history.md)

## Dependencies:
- [bash](https://www.archlinux.org/packages/core/x86_64/bash/)
- [sudo](https://www.archlinux.org/packages/core/x86_64/sudo/)
- [pacman](https://www.archlinux.org/packages/core/x86_64/pacman/)
- [coreutils](https://www.archlinux.org/packages/core/x86_64/coreutils/)
- [git](https://www.archlinux.org/packages/extra/x86_64/git/)
- [wget](https://www.archlinux.org/packages/extra/x86_64/wget/)
- [grep](https://www.archlinux.org/packages/core/x86_64/grep/)
- [less](https://www.archlinux.org/packages/core/x86_64/less/)

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

Install package/packages from Pacman
```
$ sah -Sp [package1] [package2] ...
```

Update installed packages (Pacman + AUR)
```
$ sah -Syu
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
