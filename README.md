# Simple AUR Helper (SAH) and Pacman wrapper

**Author:** zurg3 (Stepan Skryabin)

**Created:** 12.02.2019

**License:** GNU GPL v3

**Changelog** is [here](https://github.com/zurg3/sah/blob/master/changelog.txt)

**Version history** is [here](https://github.com/zurg3/sah/blob/master/version_history.md)

## Some notes:
- [Issues](https://github.com/zurg3/sah/issues) and [Pull Requests](https://github.com/zurg3/sah/pulls) are welcome.
- If this repository will get at least 10 stars, I'll add the PKGBUILD to AUR.

## Dependencies:
- [bash](https://www.archlinux.org/packages/core/x86_64/bash/)
- [sudo](https://www.archlinux.org/packages/core/x86_64/sudo/)
- [pacman](https://www.archlinux.org/packages/core/x86_64/pacman/)
- [coreutils](https://www.archlinux.org/packages/core/x86_64/coreutils/)
- [git](https://www.archlinux.org/packages/extra/x86_64/git/)
- [wget](https://www.archlinux.org/packages/extra/x86_64/wget/)
- [grep](https://www.archlinux.org/packages/core/x86_64/grep/)
- [less](https://www.archlinux.org/packages/core/x86_64/less/)
- [nano](https://www.archlinux.org/packages/core/x86_64/nano/)
- [bash-completion](https://www.archlinux.org/packages/extra/any/bash-completion/)
- [curl](https://www.archlinux.org/packages/core/x86_64/curl/)

## Installation:
```
$ git clone https://github.com/zurg3/sah.git
$ cd sah
$ makepkg -si
$ cd ..
$ rm -rf sah
```

## Update SAH config file from GitHub repo:
```
$ sah updateconfig
```

## Open Pacman config file via nano editor:
```
$ sah pacconf
```

## Open mirrorlist file via nano editor:
```
$ sah mirrorlist
```

## Update mirrorlist from Arch Linux website:
```
$ sah updatemirrors
```

## Show SAH changelog:
```
$ sah changelog
```

## Show AUR TOP-10 packages:
```
$ sah top
```

## Install package from AUR TOP-10:
```
$ sah top [1-10]
```

## Show SAH log (if logging is enabled):
```
$ sah log
```

## Clear SAH log file (if logging is enabled):
```
$ sah clearlog
```

## Examples:
### Pacman-style:
Install package/packages from AUR
```
$ sah -S [package1] [package2] ...
```

Install package/packages from Pacman
```
$ sah -Sp [package1] [package2] ...
```

Install local or remote package
```
$ sah -U [package]
```

Update package database
```
$ sah -Syy
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
$ sah -Rs [package1] [package2] ...
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
$ sah -Ss [package]
```

Search for already installed packages
```
$ sah -Qs [package]
```

Show information about package
```
$ sah -Si [package]
```

Show information about package (for locally installed packages)
```
$ sah -Qi [package]
```

Show all packages no longer required as dependencies (orphans)
```
$ sah -Qdt
```

Execute custom Pacman operation
```
$ sah custom [operation]
```

### APT-style:
Install package/packages from AUR
```
$ sah install [package1] [package2] ...
```

Update package database
```
$ sah update
```

Update installed packages (Pacman + AUR)
```
$ sah upgrade
```

Clean the package cache
```
$ sah autoremove
```

Remove package/packages
```
$ sah remove [package1] [package2] ...
```

Remove package/packages with dependencies which aren't required by any other installed packages
```
$ sah purge [package1] [package2] ...
```

## Configuration:
You can edit SAH config file to set up some settings

SAH config file path: **/etc/sah_config**

Also you can use
```
$ sah config
```
to open SAH config file via nano editor

### Supported properties in config
| Property | Value/Values | Description |
| -------- | ------------ | ----------- |
| logging | true/false | enable/disable logging |
| update_pacman | true/false | enable/disable updating of Pacman packages |
| update_aur | true/false | enable/disable updating of AUR packages |
| aur_update_notify | true/false | notify about new versions of AUR packages during updating |
| aur_update_ignore | package1,package2,... | skip updating of some AUR packages |
| mirrorlist_country | country code | mirrors country |
| mirrorlist_protocol | http/https | mirrors protocol |
| mirrorlist_ip_version | 4/6 | mirrors IP version |
| rmd | true/false | remove make dependencies of AUR packages during installation or updating |
| pgp_check | true/false | enable/disable verifying PGP signatures of source files |
| needed | true/false | enable/disable reinstalling packages if they are already up-to-date |

### Properties examples:
logging=*true*

update_pacman=*true*

update_aur=*true*

aur_update_notify=*false*

aur_update_ignore=*yay,dropbox,google-chrome*

mirrorlist_country=*RU*

mirrorlist_protocol=*http*

mirrorlist_ip_version=*4*

rmd=*false*

pgp_check=*false*

needed=*false*
