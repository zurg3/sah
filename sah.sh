#!/bin/bash

### Simple AUR Helper (SAH) and Pacman wrapper
VERSION="0.8.2"

##### Settings

# Variables to paths
pkg_list_path="$HOME/.sah/sah_pkg_list"
pkg_list_path_v="$HOME/.sah/sah_pkg_list_v"
PKGBUILDs_path="/tmp/PKGBUILDs"
SAH_cache_path="$HOME/.sah/cache"
SAH_cache_list_path="$HOME/.sah/cache_list"
SAH_config_path="/etc/sah_config"
pacman_config_path="/etc/pacman.conf"
mirrorlist_path="/etc/pacman.d/mirrorlist"
SAH_help_path="/usr/share/sah/help"
SAH_changelog_path="/usr/share/sah/changelog"
aur_top_url="https://raw.githubusercontent.com/zurg3/sah/dev/aur_top.txt"
aur_top_path="/tmp/aur_top"

kernel_version=$(uname -r)
date_time_format=$(date +"%d.%m.%Y %H:%M:%S")

# Reading config options
read_config() {
  cat $SAH_config_path | grep $1 | awk -F "=" '{print $2}'
}

SAH_editor=$(read_config editor)
SAH_browser=$(read_config browser)

update_pacman_check=$(read_config update_pacman)
update_aur_check=$(read_config update_aur)
aur_update_notify_check=$(read_config aur_update_notify)
auto_cache_check=$(read_config auto_cache)

mirrorlist_country=$(read_config mirrorlist_country)
mirrorlist_protocol=$(read_config mirrorlist_protocol)
mirrorlist_ip_version=$(read_config mirrorlist_ip_version)

rmd_check=$(read_config rmd)
pgp_check=$(read_config pgp_check)
needed_check=$(read_config needed)
noconfirm_check=$(read_config noconfirm)

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

# No confirm (--noconfirm)
# Don't wait for user input before proceeding with operations
if [[ $noconfirm_check == "false" ]]; then
  makepkg_type="$makepkg_type"
elif [[ $noconfirm_check == "true" ]]; then
  makepkg_type="$makepkg_type --noconfirm"
fi

##### Functions

##### Main code

# SAH Install
if [[ $1 == "-S" || $1 == "install" ]]; then
  aur_pkg_range="${@:2}"
  for aur_pkg in $aur_pkg_range
  do
    git clone https://aur.archlinux.org/$aur_pkg.git
    if [[ $auto_cache_check == "true" ]]; then
      test -d $SAH_cache_path/$aur_pkg
      if [[ $? == "0" ]]; then
        cd $SAH_cache_path/$aur_pkg
        git pull
        cd - > /dev/null
      elif [[ $? == "1" ]]; then
        git clone -q https://aur.archlinux.org/$aur_pkg.git $SAH_cache_path/$aur_pkg
      fi
    fi
    cd $aur_pkg
    echo "Installing $aur_pkg..."
    makepkg $makepkg_type
    cd ..
    rm -rf $aur_pkg
  done
# SAH Install Pacman
elif [[ $1 == "-Sp" ]]; then
  sudo pacman -S ${@:2}
# SAH Install Package List
elif [[ $1 == "-Sf" || $1 == "-Spf" ]]; then
  if [[ $2 == "" ]]; then
    if [[ $1 == "-Sf" ]]; then
      install_package_list_message="Enter the path to the file with list of packages for installation (AUR): "
    elif [[ $1 == "-Spf" ]]; then
      install_package_list_message="Enter the path to the file with list of packages for installation (Pacman): "
    fi
    read -e -p "$install_package_list_message" install_pkg_list
  elif [[ $2 != "" ]]; then
    install_pkg_list=$2
  fi

  list_items_count=$(cat $install_pkg_list | wc -l)
  list_line=1
  pkg_string=""
  for (( i = 0; i < $list_items_count; i++ )); do
    list_item=$(sed -n ${list_line}p $install_pkg_list)
    if [[ $i == 0 ]]; then
      pkg_string="$list_item"
    else
      pkg_string="$pkg_string $list_item"
    fi
    list_line=$(($list_line + 1))
  done

  if [[ $1 == "-Sf" ]]; then
    aur_pkg_range=$pkg_string
    for aur_pkg in $aur_pkg_range
    do
      git clone https://aur.archlinux.org/$aur_pkg.git
      if [[ $auto_cache_check == "true" ]]; then
        test -d $SAH_cache_path/$aur_pkg
        if [[ $? == "0" ]]; then
          cd $SAH_cache_path/$aur_pkg
          git pull
          cd - > /dev/null
        elif [[ $? == "1" ]]; then
          git clone -q https://aur.archlinux.org/$aur_pkg.git $SAH_cache_path/$aur_pkg
        fi
      fi
      cd $aur_pkg
      echo "Installing $aur_pkg..."
      makepkg $makepkg_type
      cd ..
      rm -rf $aur_pkg
    done
  elif [[ $1 == "-Spf" ]]; then
    sudo pacman -S $pkg_string
  fi
# SAH Install Local/Remote Package
elif [[ $1 == "-U" ]]; then
  sudo pacman -U $2
# SAH Update Package Database
elif [[ $1 == "-Syy" || $1 == "update" ]]; then
  sudo pacman -Syy
# SAH Update
elif [[ $1 == "-Syu" || $1 == "upgrade" ]]; then
  if [[ $update_pacman_check == "true" ]]; then
    echo "Checking for updates from Pacman..."
    sudo pacman -Syu
  elif [[ $update_pacman_check == "false" ]]; then
    echo "Updating of Pacman packages is disabled."
  fi

  if [[ $update_aur_check == "true" ]]; then
    echo
    echo "Checking for updates from AUR..."

    sudo pacman -Qqm > $pkg_list_path
    sudo pacman -Qm > $pkg_list_path_v

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
      aur_update_notify_message="-> [$check_pkg_num / $pkgz] $check_pkg - new version is available."

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
          if [[ $check_pkg != "sah" && $auto_cache_check == "true" ]]; then
            test -d $SAH_cache_path/$check_pkg
            if [[ $? == "0" ]]; then
              cd $SAH_cache_path/$check_pkg
              git pull
              cd - > /dev/null
            elif [[ $? == "1" ]]; then
              git clone -q $git_clone_link $SAH_cache_path/$check_pkg
            fi
          fi
        elif [[ $check_pkg_v != $version_full ]]; then
          # Version from PKGBUILD may has the single quotes.
          echo "$version_full" | grep -q "'"
          if [[ $? == "0" ]]; then
            pkgver_sq=$(echo "$check_pkg_v" | awk -F "-" '{print $1}')
            pkgrel_sq=$(echo "$check_pkg_v" | awk -F "-" '{print $2}')
            check_pkg_v_sq="'$pkgver_sq'-'$pkgrel_sq'"
            if [[ $check_pkg_v_sq != $version_full ]]; then
              if [[ $aur_update_notify_check == "true" ]]; then
                echo "$aur_update_notify_message"
              elif [[ $aur_update_notify_check == "false" ]]; then
                echo "$update_message"
                git clone $git_clone_link
                if [[ $check_pkg != "sah" && $auto_cache_check == "true" ]]; then
                  test -d $SAH_cache_path/$check_pkg
                  if [[ $? == "0" ]]; then
                    cd $SAH_cache_path/$check_pkg
                    git pull
                    cd - > /dev/null
                  elif [[ $? == "1" ]]; then
                    git clone -q $git_clone_link $SAH_cache_path/$check_pkg
                  fi
                fi
                cd $check_pkg
                makepkg $makepkg_type
                cd ..
                rm -rf $check_pkg
              fi
            elif [[ $check_pkg_v_sq == $version_full ]]; then
              echo "$latest_version_message"
            fi
          elif [[ $? == "1" ]]; then
            if [[ $aur_update_notify_check == "true" ]]; then
              echo "$aur_update_notify_message"
            elif [[ $aur_update_notify_check == "false" ]]; then
              echo "$update_message"
              git clone $git_clone_link
              if [[ $check_pkg != "sah" && $auto_cache_check == "true" ]]; then
                test -d $SAH_cache_path/$check_pkg
                if [[ $? == "0" ]]; then
                  cd $SAH_cache_path/$check_pkg
                  git pull
                  cd - > /dev/null
                elif [[ $? == "1" ]]; then
                  git clone -q $git_clone_link $SAH_cache_path/$check_pkg
                fi
              fi
              cd $check_pkg
              makepkg $makepkg_type
              cd ..
              rm -rf $check_pkg
            fi
          fi
        fi
      elif [[ " ${aur_update_ignore[*]} " == *" $check_pkg "* ]]; then
        echo "$aur_update_ignore_message"
      fi
    done
    rm $pkg_list_path
    rm $pkg_list_path_v
    rm -rf $PKGBUILDs_path
  elif [[ $update_aur_check == "false" ]]; then
    echo
    echo "Updating of AUR packages is disabled."
  fi
# SAH Clean
elif [[ $1 == "-Sc" || $1 == "autoremove" ]]; then
  sudo pacman -Sc
# SAH Remove
elif [[ $1 == "-R" || $1 == "remove" ]]; then
  sudo pacman -R ${@:2}
# SAH Remove With Dependencies
elif [[ $1 == "-Rs" || $1 == "purge" ]]; then
  sudo pacman -Rs ${@:2}
# SAH Installed All
elif [[ $1 == "-Q" || $1 == "list" ]]; then
  query_pkg_count=$(sudo pacman -Q | wc -l)
  echo "Installed packages (All) [$query_pkg_count packages]:"
  sudo pacman -Q
# SAH Installed Explicitly
elif [[ $1 == "-Qe" ]]; then
  query_pkg_count=$(sudo pacman -Qe | wc -l)
  echo "Installed packages (Explicitly) [$query_pkg_count packages]:"
  sudo pacman -Qe
# SAH Installed AUR
elif [[ $1 == "-Qm" ]]; then
  query_pkg_count=$(sudo pacman -Qm | wc -l)
  echo "Installed packages (AUR) [$query_pkg_count packages]:"
  sudo pacman -Qm
# SAH Search
elif [[ $1 == "-Ss" ]]; then
  sudo pacman -Ss $2
# SAH Search Installed
elif [[ $1 == "-Qs" ]]; then
  sudo pacman -Qs $2
# SAH Show Info
elif [[ $1 == "-Si" ]]; then
  sudo pacman -Si $2
# SAH Show Info Installed
elif [[ $1 == "-Qi" ]]; then
  sudo pacman -Qi $2
# SAH Orphans
elif [[ $1 == "-Qdt" ]]; then
  query_pkg_count=$(sudo pacman -Qdt | wc -l)
  echo "Packages no longer required as dependencies (orphans) [$query_pkg_count packages]:"
  sudo pacman -Qdt
# SAH Custom Pacman Operation
elif [[ $1 == "custom" ]]; then
  sudo pacman ${@:2}
# SAH Statistics
elif [[ $1 == "stat" ]]; then
  query_pkg_count_Q=$(sudo pacman -Q | wc -l)
  query_pkg_count_Qe=$(sudo pacman -Qe | wc -l)
  query_pkg_count_Qm=$(sudo pacman -Qm | wc -l)
  query_pkg_count_Qdt=$(sudo pacman -Qdt | wc -l)

  echo "Packages statistics"

  echo "Installed packages (All): $query_pkg_count_Q"
  echo "Installed packages (Explicitly): $query_pkg_count_Qe"
  echo "Installed packages (AUR): $query_pkg_count_Qm"
  echo "Packages no longer required as dependencies (orphans): $query_pkg_count_Qdt"
# SAH Config
elif [[ $1 == "config" ]]; then
  sudo $SAH_editor $SAH_config_path
# SAH Reset Config
elif [[ $1 == "resetconfig" ]]; then
  sudo curl -s "https://raw.githubusercontent.com/zurg3/sah/v$VERSION/sah_config_default" -o $SAH_config_path
  sudo $SAH_editor $SAH_config_path
# SAH Pacman Config
elif [[ $1 == "pacconf" ]]; then
  sudo $SAH_editor $pacman_config_path
# SAH Pacman Mirrorlist
elif [[ $1 == "mirrorlist" ]]; then
  sudo $SAH_editor $mirrorlist_path
# SAH Pacman Update Mirrors
elif [[ $1 == "updatemirrors" ]]; then
  sudo curl -s "https://www.archlinux.org/mirrorlist/?country=$mirrorlist_country&protocol=$mirrorlist_protocol&ip_version=$mirrorlist_ip_version" -o $mirrorlist_path
  sudo $SAH_editor $mirrorlist_path
# SAH Changelog
elif [[ $1 == "changelog" ]]; then
  less $SAH_changelog_path
# SAH AUR TOP Packages
elif [[ $1 == "top" ]]; then
  wget -q $aur_top_url -O $aur_top_path
  readarray -t aur_top < $aur_top_path
  aur_top_date=${aur_top[0]}
  if [[ $2 == "" ]]; then
    aur_top_num=1
    echo "TOP-10 popular AUR packages (updated on $aur_top_date):"
    for (( i = 1; i < 11; i++ )); do
      echo "$aur_top_num. ${aur_top[$i]}"
      aur_top_num=$(($aur_top_num + 1))
    done
  elif [[ $2 != "" ]]; then
    if (( $2 >= 1 && $2 <= 10 )); then
      aur_top_install=$2
      aur_pkg=${aur_top[$aur_top_install]}
      git clone https://aur.archlinux.org/$aur_pkg.git
      if [[ $auto_cache_check == "true" ]]; then
        test -d $SAH_cache_path/$aur_pkg
        if [[ $? == "0" ]]; then
          cd $SAH_cache_path/$aur_pkg
          git pull
          cd - > /dev/null
        elif [[ $? == "1" ]]; then
          git clone -q https://aur.archlinux.org/$aur_pkg.git $SAH_cache_path/$aur_pkg
        fi
      fi
      cd $aur_pkg
      echo "Installing $aur_pkg..."
      makepkg $makepkg_type
      cd ..
      rm -rf $aur_pkg
    else
      echo "You can install packages only in the range from 1 to 10!"
    fi
  fi
# SAH Cache
elif [[ $1 == "cache" ]]; then
  if [[ $2 != "install" && $2 != "update" && $2 != "remove" && $2 != "list" && $2 != "clean" ]]; then
    aur_pkg_range="${@:2}"
    for aur_pkg in $aur_pkg_range
    do
      test -d $SAH_cache_path/$aur_pkg
      if [[ $? == "1" ]]; then
        echo "Caching $aur_pkg..."
        git clone https://aur.archlinux.org/$aur_pkg.git $SAH_cache_path/$aur_pkg
      fi
    done
  fi

  aur_pkg_range="${@:3}"
  if [[ $2 == "install" ]]; then
    for aur_pkg in $aur_pkg_range
    do
      test -d $SAH_cache_path/$aur_pkg
      if [[ $? == "0" ]]; then
        cd $SAH_cache_path/$aur_pkg
        echo "Installing $aur_pkg..."
        makepkg $makepkg_type
      elif [[ $? == "1" ]]; then
        echo "$aur_pkg - package not found."
      fi
    done
  elif [[ $2 == "update" ]]; then
    if [[ $3 != "--all" ]]; then
      for aur_pkg in $aur_pkg_range
      do
        test -d $SAH_cache_path/$aur_pkg
        if [[ $? == "0" ]]; then
          cd $SAH_cache_path/$aur_pkg
          echo "Updating $aur_pkg..."
          git pull
        elif [[ $? == "1" ]]; then
          echo "$aur_pkg - package not found."
        fi
      done
    elif [[ $3 == "--all" ]]; then
      ls -1 $SAH_cache_path > $SAH_cache_list_path
      readarray -t cache_list < $SAH_cache_list_path
      cache_list_num=${#cache_list[@]}
      for (( i = 0; i < $cache_list_num; i++ )); do
        test -d $SAH_cache_path/${cache_list[$i]}
        if [[ $? == "0" ]]; then
          cd $SAH_cache_path/${cache_list[$i]}
          echo "Updating ${cache_list[$i]}..."
          git pull
        elif [[ $? == "1" ]]; then
          echo "${cache_list[$i]} - package not found."
        fi
      done
    fi
  elif [[ $2 == "remove" ]]; then
    for aur_pkg in $aur_pkg_range
    do
      test -d $SAH_cache_path/$aur_pkg
      if [[ $? == "0" ]]; then
        rm -rf $SAH_cache_path/$aur_pkg
        echo "Removed $aur_pkg..."
      elif [[ $? == "1" ]]; then
        echo "$aur_pkg - package not found."
      fi
    done
  elif [[ $2 == "list" ]]; then
    ls -1 $SAH_cache_path
  elif [[ $2 == "clean" ]]; then
    rm -rf $SAH_cache_path/*
  fi
# SAH Browse
elif [[ $1 == "browse" ]]; then
  if [[ $SAH_browser == "" ]]; then
    echo "You need specify a web browser in SAH config!"
  elif [[ $SAH_browser != "" ]]; then
    if [[ $2 == "" ]]; then
      echo "Usage: sah browse [--pacman|--aur] or sah browse [--pacman|--aur] [package]"
    elif [[ $2 != "" ]]; then
      if [[ $3 == "" ]]; then
        if [[ $2 == "--pacman" ]]; then
          $SAH_browser https://www.archlinux.org/packages/
        elif [[ $2 == "--aur" ]]; then
          $SAH_browser https://aur.archlinux.org/packages/
        else
          echo "Usage: sah browse [--pacman|--aur] or sah browse [--pacman|--aur] [package]"
        fi
      elif [[ $3 != "" ]]; then
        if [[ $2 == "--pacman" ]]; then
          $SAH_browser https://www.archlinux.org/packages/?q=$3
        elif [[ $2 == "--aur" ]]; then
          $SAH_browser https://aur.archlinux.org/packages/$3
        else
          echo "Usage: sah browse [--pacman|--aur] or sah browse [--pacman|--aur] [package]"
        fi
      fi
    fi
  fi
# SAH Version
elif [[ $1 == "--version" || $1 == "-V" ]]; then
  echo "Simple AUR Helper (SAH) and Pacman wrapper v$VERSION"
# SAH Help
elif [[ $1 == "" || $1 == "--help" || $1 == "-h" ]]; then
  less $SAH_help_path
# SAH Debug
elif [[ $1 == "debug" ]]; then
  # Man page preview: nroff -man sah.8 | less

  version_length=${#VERSION}
  if [[ $version_length == "3" ]]; then
    debug_art="=========================="
  elif [[ $version_length == "5" ]]; then
    debug_art="============================"
  elif [[ $version_length == "6" ]]; then
    debug_art="============================="
  elif [[ $version_length == "7" ]]; then
    debug_art="=============================="
  else
    debug_art="= = = = ="
  fi

  echo "===== SAH Debug v$VERSION ====="
  echo "$debug_art"
  echo "Arch Linux $kernel_version"
  echo "$USER@$HOSTNAME"
  echo "$date_time_format"
  echo "$debug_art"
else
  echo "Something is wrong!"
fi
