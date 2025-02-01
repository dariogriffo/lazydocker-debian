![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/lazydocker-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/lazydocker-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/lazydocker-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/lazydocker-debian)

<h1>
   <p align="center">
     <a href="https://lazydocker.org/"><img src="https://github.com/dariogriffo/lazydocker-debian/blob/main/lazydocker-logo.png" alt="lazydocker Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/lazydocker-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>lazydocker for Debian
   </p>
</h1>
<p align="center">
 lazydocker is a a simple terminal UI for both docker and docker-compose, written in Go with the gocui library.
</p>

# lazydocker for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [lazydocker](https://github.com/jesseduffield/lazydocker/) hosted at [debian.griffo.io](https://debian.griffo.io)

Currently supported debian distros are:
- Bookworm
- Trixie
- Sid

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the lazydocker source code, see
[lazydocker](https://github.com/jesseduffield/lazydocker/).

## Install/Update

### The Debian way

```sh
curl -sS https://debian.griffo.io/3B9335DF576D3D58059C6AA50B56A1A69762E9FF.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io//apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
sudo apt install -y lazydocker
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/lazydocker-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates

## Disclaimer

- This repo is not open for issues related to lazydocker. This repo is only for _unofficial_ Debian packaging.
- This repository is based on the amazing work of [Mike Kasberg](https://github.com/mkasberg) and his [lazydocker Ubuntu](https://github.com/mkasberg/lazydocker-ubuntu) packages
