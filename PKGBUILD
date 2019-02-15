# Maintainer: zurg3 <https://t.me/zurg3channel>
pkgname=sah
pkgver=0.1
pkgrel=1
pkgdesc="Simple AUR Helper (SAH)"
arch=('any')
url="https://github.com/zurg3/sah"
license=('GPLv3')
depends=('bash' 'sudo' 'pacman' 'coreutils' 'git' 'wget' 'grep')
source=("https://raw.githubusercontent.com/zurg3/sah/master/sah.sh")
md5sums=('SKIP')

package() {
  install -Dm755 sah.sh "$pkgdir/usr/bin/sah"
}
