# Simple AUR Helper (SAH) and Pacman wrapper

**Author:** zurg3 (Stepan Skryabin)

**Created:** 12.02.2019

**License:** GNU GPL v3

**Changelog** is [here](https://github.com/zurg3/sah/blob/master/changelog.txt)

**Version history** is [here](https://github.com/zurg3/sah/blob/master/version_history.md)

## Some notes:
- [Issues](https://github.com/zurg3/sah/issues) and [Pull Requests](https://github.com/zurg3/sah/pulls) are welcome.
- If this repository will get at least 20 stars, I'll add the PKGBUILD to AUR.

## Dependencies (most of them installed by default):
- [bash](https://archlinux.org/packages/core/x86_64/bash/)
- [sudo](https://archlinux.org/packages/core/x86_64/sudo/)
- [pacman](https://archlinux.org/packages/core/x86_64/pacman/)
- [coreutils](https://archlinux.org/packages/core/x86_64/coreutils/)
- [git](https://archlinux.org/packages/extra/x86_64/git/)
- [wget](https://archlinux.org/packages/extra/x86_64/wget/)
- [grep](https://archlinux.org/packages/core/x86_64/grep/)
- [less](https://archlinux.org/packages/core/x86_64/less/)
- [nano](https://archlinux.org/packages/core/x86_64/nano/)
- [bash-completion](https://archlinux.org/packages/extra/any/bash-completion/)
- [curl](https://archlinux.org/packages/core/x86_64/curl/)
- [sed](https://archlinux.org/packages/core/x86_64/sed/)
- [libxml2](https://archlinux.org/packages/extra/x86_64/libxml2/)

## Optional dependencies:
- [vim](https://archlinux.org/packages/extra/x86_64/vim/) - *an alternative editor to edit configs*
- [firefox](https://archlinux.org/packages/extra/x86_64/firefox/) - *to browse packages from Arch Linux website*
- [bat](https://archlinux.org/packages/community/x86_64/bat/) - *an alternative text viewer to view text files*

## Installation:
```
$ git clone https://github.com/zurg3/sah.git
$ cd sah
$ makepkg -si
$ cd ..
$ rm -rf sah
```

## Reset to default SAH config file from GitHub repo:
```
$ sah resetconfig
```

## Open Pacman config file via selected text editor:
```
$ sah pacconf
```

## Open mirrorlist file via selected text editor:
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

## Cache AUR package/packages:
```
$ sah cache [package1] [package2] ...
```

## Install AUR package/packages from cache:
```
$ sah cache install [package1] [package2] ...
```

## Update cached AUR package/packages:
```
$ sah cache update [package1] [package2] ...
```

## Update all cached AUR packages:
```
$ sah cache update --all
```

## Remove AUR package/packages from cache:
```
$ sah cache remove [package1] [package2] ...
```

## Show all cached AUR packages:
```
$ sah cache list
```

## Remove all cached AUR packages:
```
$ sah cache clean
```

## Browse all packages from Arch Linux website via web browser:
```
$ sah browse
```

## Browse the package from Arch Linux website via web browser:
```
$ sah browse [package]
```

## View PKGBUILD of AUR package:
```
$ sah view [package]
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

Install packages from file with list of packages (AUR)
```
$ sah -Sf [file]
```

Install packages from file with list of packages (Pacman)
```
$ sah -Spf [file]
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

Remove packages-orphans
```
$ sah -Ro
```

Show installed packages (All)
```
$ sah -Q
```

Show installed packages (Explicitly)
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

Show packages statistics
```
$ sah stat
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

Show installed packages
```
$ sah list
```

## Configuration:
You can edit SAH config file to set up some settings

SAH config file path: **/etc/sah_config**

Also you can use
```
$ sah config
```
to open SAH config file via selected text editor

### Supported properties in config
| Property | Value/Values | Description |
| -------- | ------------ | ----------- |
| editor | package | text editor for editing configs |
| viewer | package | text viewer for viewing text files |
| browser | package | web browser to browse packages from Arch Linux website |
| update_pacman | true/false | enable/disable updating of Pacman packages |
| update_aur | true/false | enable/disable updating of AUR packages |
| aur_update_notify | true/false | notify about new versions of AUR packages during updating |
| auto_cache | true/false | enable/disable auto caching for AUR packages |
| aur_update_ignore | package1,package2,... | skip updating of some AUR packages |
| mirrorlist_country | country code | mirrors country |
| mirrorlist_protocol | http/https | mirrors protocol |
| mirrorlist_ip_version | 4/6 | mirrors IP version |
| rmd | true/false | remove make dependencies of AUR packages during installation or updating |
| pgp_check | true/false | enable/disable verifying PGP signatures of source files |
| needed | true/false | enable/disable reinstalling packages if they are already up-to-date |
| noconfirm | true/false | enable/disable waiting for user input before proceeding with operations |

### Properties examples:
editor=*nano*

viewer=*less*

browser=*firefox*

update_pacman=*true*

update_aur=*true*

aur_update_notify=*false*

auto_cache=*true*

aur_update_ignore=*yay,dropbox,google-chrome*

mirrorlist_country=*RU*

mirrorlist_protocol=*http*

mirrorlist_ip_version=*4*

rmd=*false*

pgp_check=*false*

needed=*false*

noconfirm=*false*
