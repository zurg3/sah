#!/bin/bash

### Simple AUR Helper (SAH)
VERSION="0.4.3"

##### Settings

# Variables to paths
pkg_list_path="/home/$USER/.sah_pkg_list"
pkg_list_path_v="/home/$USER/.sah_pkg_list_v"
PKGBUILDs_path="/tmp/PKGBUILDs"
SAH_config_path="/etc/sah_config"
SAH_changelog_path="/usr/share/sah/changelog"

# Reading config options
rmd_check=$(cat $SAH_config_path | grep "rmd" | awk -F "=" '{print $2}')
pgp_check=$(cat $SAH_config_path | grep "pgp_check" | awk -F "=" '{print $2}')
needed_check=$(cat $SAH_config_path | grep "needed" | awk -F "=" '{print $2}')

# Remove make dependencies (-si/-sir)
if [[ $rmd_check == "false" ]]; then
  makepkg_type="-si"
elif [[ $rmd_check == "true" ]]; then
  makepkg_type="-sir"
fi

# PGP check (--skippgpcheck)
if [[ $pgp_check == "false" ]]; then
  makepkg_type="$makepkg_type --skippgpcheck"
elif [[ $pgp_check == "true" ]]; then
  makepkg_type="$makepkg_type"
fi

# Needed (--needed)
# Don't reinstall packages if they are already up-to-date
if [[ $needed_check == "false" ]]; then
  makepkg_type="$makepkg_type"
elif [[ $needed_check == "true" ]]; then
  makepkg_type="$makepkg_type --needed"
fi

##### Main code

# SAH Install
if [[ $1 == "-S" ]]; then
  aur_pkg_range="${@:2}"
  for aur_pkg in $aur_pkg_range
  do
    git clone https://aur.archlinux.org/$aur_pkg.git
    cd $aur_pkg
    echo "Installing $aur_pkg..."
    makepkg $makepkg_type
    cd ..
    rm -rf $aur_pkg
  done
# SAH Install Pacman
elif [[ $1 == "-Sp" ]]; then
  sudo pacman -S ${@:2}
# SAH Update
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

  aur_update_ignore_count=$(cat $SAH_config_path | grep "aur_update_ignore" | awk -F "=" '{print $2}' | tr ',' '\n' | wc -l)
  for (( i = 0; i < $aur_update_ignore_count; i++ )); do
    aur_update_ignore_num=$(($i + 1))
    aur_update_ignore[$i]=$(cat $SAH_config_path | grep "aur_update_ignore" | awk -F "=" '{print $2}' | awk -F "," "{print \$$aur_update_ignore_num}")
  done

  mkdir $PKGBUILDs_path
  for (( i = 0; i < $pkgz; i++ )); do
    check_pkg=${pkg_list[$i]}
    check_pkg_v=${pkg_list_v[$i]}
    check_pkg_v=$(echo $check_pkg_v | awk '{print $2}')
    check_pkg_num=$(($i + 1))

    latest_version_message="-> [$check_pkg_num / $pkgz] $check_pkg - you have the latest version."
    update_message="-> [$check_pkg_num / $pkgz] Updating $check_pkg..."
    aur_update_ignore_message="-> [$check_pkg_num / $pkgz] $check_pkg - skipped."

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

    if [[ " ${aur_update_ignore[*]} " != *" $check_pkg "* ]]; then
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
    elif [[ " ${aur_update_ignore[*]} " == *" $check_pkg "* ]]; then
      echo "$aur_update_ignore_message"
    fi
  done
  rm $pkg_list_path
  rm $pkg_list_path_v
  rm -rf $PKGBUILDs_path
# SAH Clean
elif [[ $1 == "-Sc" ]]; then
  sudo pacman -Sc
# SAH Remove
elif [[ $1 == "-R" ]]; then
  sudo pacman -R ${@:2}
# SAH Remove With Dependencies
elif [[ $1 == "-Rs" ]]; then
  sudo pacman -Rs ${@:2}
# SAH Installed All
elif [[ $1 == "-Qe" ]]; then
  echo "Installed packages (All):"
  pacman -Qe
# SAH Installed AUR
elif [[ $1 == "-Qm" ]]; then
  echo "Installed packages (AUR):"
  pacman -Qm
# SAH Search
elif [[ $1 == "-Ss" ]]; then
  pacman -Ss $2
# SAH Search Installed
elif [[ $1 == "-Qs" ]]; then
  pacman -Qs $2
# SAH Show Info
elif [[ $1 == "-Si" ]]; then
  pacman -Si $2
# SAH Show Info Installed
elif [[ $1 == "-Qi" ]]; then
  pacman -Qi $2
# SAH Orphans
elif [[ $1 == "-Qdt" ]]; then
  pacman -Qdt
# SAH Config
elif [[ $1 == "config" ]]; then
  sudo nano $SAH_config_path
# SAH Changelog
elif [[ $1 == "changelog" ]]; then
  less $SAH_changelog_path
# SAH Version
elif [[ $1 == "--version" || $1 == "-V" ]]; then
  echo "Simple AUR Helper (SAH) v$VERSION"
# SAH Help
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
- nano

Show SAH changelog:
sah changelog

Examples:
Install package/packages from AUR
sah -S [package1] [package2] ...

Install package/packages from Pacman
sah -Sp [package1] [package2] ...

Update installed packages (Pacman + AUR)
sah -Syu

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
sah -Qdt

Configuration:
You can edit SAH config file to set up some settings
SAH config file path: $SAH_config_path

Also you can use 'sah config' to open config file via nano editor

Supported properties in config:
aur_update_ignore (package1,package2,...) - skip updating of some AUR packages
rmd (true/false) - remove make dependencies of AUR packages during installation or updating
pgp_check (true/false) - enable/disable verifying PGP signatures of source files
needed (true/false) - enable/disable reinstalling packages if they are already up-to-date

Properties examples:
aur_update_ignore=yay,dropbox,google-chrome
rmd=false
pgp_check=false
needed=false" | less
else
  echo "Something is wrong!"
fi
