# Maintainer: zurg3 <https://t.me/zurg3channel>
pkgname=sah
pkgver=0.5.2
pkgrel=1
pkgdesc="Simple AUR Helper (SAH)"
arch=('any')
url="https://github.com/zurg3/sah"
license=('GPLv3')
depends=('bash' 'sudo' 'pacman' 'coreutils' 'git' 'wget' 'grep' 'less' 'nano' 'bash-completion')
source=("https://github.com/zurg3/sah/archive/v$pkgver.tar.gz")
md5sums=('SKIP')

test -f /etc/sah_config
if [[ $? == "1" ]]; then
  package() {
    cd "$srcdir/$pkgname-$pkgver"
    install -Dm755 sah.sh "$pkgdir/usr/bin/sah"
    install -Dm644 sah.8 "$pkgdir/usr/share/man/man8/sah.8"
    install -Dm644 sah_config_default "$pkgdir/etc/sah_config"
    install -Dm644 changelog.txt "$pkgdir/usr/share/sah/changelog"
    install -Dm644 sah_completion.bash "$pkgdir/etc/bash_completion.d/sah_completion.bash"
  }
elif [[ $? == "0" ]]; then
  package() {
    cd "$srcdir/$pkgname-$pkgver"
    install -Dm755 sah.sh "$pkgdir/usr/bin/sah"
    install -Dm644 sah.8 "$pkgdir/usr/share/man/man8/sah.8"
    install -Dm644 changelog.txt "$pkgdir/usr/share/sah/changelog"
    install -Dm644 sah_completion.bash "$pkgdir/etc/bash_completion.d/sah_completion.bash"
  }
fi
