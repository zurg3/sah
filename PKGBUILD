# Maintainer: zurg3 <zurg3mail@mail.ru>
pkgname=sah
pkgver=0.9.2
pkgrel=1
pkgdesc="Simple AUR Helper (SAH) and Pacman wrapper"
arch=('any')
url="https://github.com/zurg3/sah"
license=('GPLv3')
depends=('bash' 'sudo' 'pacman' 'coreutils' 'git' 'wget' 'grep' 'less' 'nano' 'bash-completion' 'curl' 'sed' 'libxml2')
optdepends=('vim: an alternative editor to edit configs'
            'firefox: to browse packages from Arch Linux website'
            'bat: an alternative text viewer to view text files')
backup=('etc/sah_config')
source=("https://github.com/zurg3/sah/archive/v$pkgver.tar.gz")
md5sums=('SKIP')

package() {
  cd "$srcdir/$pkgname-$pkgver"
  install -Dm755 sah.sh "$pkgdir/usr/bin/sah"
  install -Dm644 sah.8 "$pkgdir/usr/share/man/man8/sah.8"
  install -Dm644 sah_config_default "$pkgdir/etc/sah_config"
  install -Dm644 help.txt "$pkgdir/usr/share/sah/help"
  install -Dm644 changelog.txt "$pkgdir/usr/share/sah/changelog"
  install -Dm644 sah_completion.bash "$pkgdir/etc/bash_completion.d/sah_completion.bash"
}
