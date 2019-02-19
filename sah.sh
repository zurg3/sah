#!/bin/bash

### Simple AUR Helper (SAH)
VERSION="0.3"

pkg_list_path="/home/$USER/.sah_pkg_list"
pkg_list_path_v="/home/$USER/.sah_pkg_list_v"
PKGBUILDs_path="/tmp/PKGBUILDs"
# Remove make dependencies
if [[ ${@: -1} != "--rmd" ]]; then
  makepkg_type="-si --skippgpcheck"
elif [[ ${@: -1} == "--rmd" ]]; then
  makepkg_type="-sir --skippgpcheck"
fi

if [[ $1 == "-S" ]]; then
  if [[ ${@: -1} != "--rmd" ]]; then
    aur_pkg_range="${@:2}"
  elif [[ ${@: -1} == "--rmd" ]]; then
    aur_pkg_range="${@:2:$#-2}"
  fi

  for aur_pkg in $aur_pkg_range
  do
    git clone https://aur.archlinux.org/$aur_pkg.git
    cd $aur_pkg
    makepkg $makepkg_type
    cd ..
    rm -rf $aur_pkg
  done
elif [[ $1 == "-Sp" ]]; then
  sudo pacman -S ${@:2}
elif [[ $1 == "-Syu" ]]; then
  echo "Checking for updates from Pacman..."
  sudo pacman -Syu

  echo
  echo "Checking for updates from AUR..."

  pacman -Qqm > $pkg_list_path
  pacman -Qm > $pkg_list_path_v

  readarray -t pkg_list < $pkg_list_path
  readarray -t pkg_list_v < $pkg_list_path_v
  pkgz=${#pkg_list[@]}
  pkgz_v=${#pkg_list_v[@]}

  mkdir $PKGBUILDs_path
  for (( i = 0; i < $pkgz; i++ )); do
    check_pkg=${pkg_list[$i]}
    check_pkg_v=${pkg_list_v[$i]}
    check_pkg_v=$(echo $check_pkg_v | awk '{print $2}')

    latest_version_message="-> $check_pkg - you have the latest version."
    update_message="Updating $check_pkg..."

    # Exceptions
    if [[ $check_pkg != "sah" ]]; then
      wget_link="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$check_pkg"
      git_clone_link="https://aur.archlinux.org/$check_pkg.git"
    elif [[ $check_pkg == "sah" ]]; then
      wget_link="https://raw.githubusercontent.com/zurg3/$check_pkg/master/PKGBUILD"
      git_clone_link="https://github.com/zurg3/$check_pkg.git"
    fi

    wget -q $wget_link -O $PKGBUILDs_path/$check_pkg.txt

    version_main=$(cat $PKGBUILDs_path/$check_pkg.txt | grep "pkgver" | head -n 1 | awk -F "=" '{print $2}')
    version_patch=$(cat $PKGBUILDs_path/$check_pkg.txt | grep "pkgrel" | head -n 1 | awk -F "=" '{print $2}')
    version_full="$version_main-$version_patch"

    if [[ $check_pkg_v == $version_full ]]; then
      echo "$latest_version_message"
    elif [[ $check_pkg_v != $version_full ]]; then
      # Version from PKGBUILD may has the single quotes.
      echo "$version_full" | grep -q "'"
      if [[ $? == "0" ]]; then
        pkgver_sq=$(echo "$check_pkg_v" | awk -F "-" '{print $1}')
        pkgrel_sq=$(echo "$check_pkg_v" | awk -F "-" '{print $2}')
        check_pkg_v_sq="'$pkgver_sq'-'$pkgrel_sq'"
        if [[ $check_pkg_v_sq != $version_full ]]; then
          echo "$update_message"
          git clone $git_clone_link
          cd $check_pkg
          makepkg $makepkg_type
          cd ..
          rm -rf $check_pkg
        elif [[ $check_pkg_v_sq == $version_full ]]; then
          echo "$latest_version_message"
        fi
      elif [[ $? == "1" ]]; then
        echo "$update_message"
        git clone $git_clone_link
        cd $check_pkg
        makepkg $makepkg_type
        cd ..
        rm -rf $check_pkg
      fi
    fi
  done
  rm $pkg_list_path
  rm $pkg_list_path_v
  rm -rf $PKGBUILDs_path
elif [[ $1 == "-Sc" ]]; then
  sudo pacman -Sc
elif [[ $1 == "-R" ]]; then
  sudo pacman -R ${@:2}
elif [[ $1 == "-Rs" ]]; then
  sudo pacman -Rs ${@:2}
elif [[ $1 == "-Qe" ]]; then
  echo "Installed packages (All):"
  pacman -Qe
elif [[ $1 == "-Qm" ]]; then
  echo "Installed packages (AUR):"
  pacman -Qm
elif [[ $1 == "-Ss" ]]; then
  pacman -Ss $2
elif [[ $1 == "-Qs" ]]; then
  pacman -Qs $2
elif [[ $1 == "-Si" ]]; then
  pacman -Si $2
elif [[ $1 == "-Qi" ]]; then
  pacman -Qi $2
elif [[ $1 == "-Qdt" ]]; then
  pacman -Qdt
elif [[ $1 == "--version" || $1 == "-V" ]]; then
  echo "Simple AUR Helper (SAH) v$VERSION"
elif [[ $1 == "" || $1 == "--help" || $1 == "-h" ]]; then
  echo "Simple AUR Helper (SAH)

Version: $VERSION
Author: zurg3 (Stepan Skryabin)
Created: 12.02.2019
License: GNU GPL v3

Dependencies:
- bash
- sudo
- pacman
- coreutils
- git
- wget
- grep
- less

Examples:
Install package/packages from AUR
sah -S [package1] [package2] ...

Install package/packages from AUR and remove make dependencies
sah -S [package1] [package2] ... --rmd

Install package/packages from Pacman
sah -Sp [package1] [package2] ...

Update installed packages (Pacman + AUR)
sah -Syu

Update installed packages (Pacman + AUR) and remove make dependencies of updated AUR packages
sah -Syu --rmd

Clean the package cache
sah -Sc

Remove package/packages
sah -R [package1] [package2] ...

Remove package/packages with dependencies which aren't required by any other installed packages
sah -Rs [package1] [package2] ...

Show installed packages (All)
sah -Qe

Show installed packages (AUR)
sah -Qm

Search for packages in the database
sah -Ss [package]

Search for already installed packages
sah -Qs [package]

Show information about package
sah -Si [package]

Show information about package (for locally installed packages)
sah -Qi [package]

Show all packages no longer required as dependencies (orphans)
sah -Qdt" | less
else
  echo "Something is wrong!"
fi
