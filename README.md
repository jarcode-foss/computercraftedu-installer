# ComputerCraftEdu Installer

**NOTE:** this project is incomplete. See this repository at a later date.

This is a cross-platform package and installer builder that automatically installs a version of minecraft with ComputerCraftEdu modded on top of the installation. The actual Minecraft client is downloaded at runtime, and is not packaged with the installer.

**Backstory:** This is a project that was written upon request by an anonymous non-profit organization that aims to teach kids how to write software using ComputerCraftEdu. Because this organization has switched to a virtual setup due to covid-19, this project serves as a simple means for children and/or parents to install the required software.

The installer creates desktop and menu entries on supported platforms that automatically launch the game. The launcher _does not authenticate with Minecraft's login servers_ to avoid issues with educators distributing minecraft accounts in a remote setting (and to avoid students having to navigate the vanilla game launcher). It's worth mentioning that this usage of Mojang services is a breach of the game's EULA, but not its copyright, but it is extremely unlikely to result in any change to the products and/or services provided by Mojang/Microsoft.

Educators should be aware that this version of the game is the original Java version, not the Education Edition (EE) that Microsoft offers to educators. Organizations interested in the latter should simply purchase a license, and if your organization already holds an educator's license, usage of this installer is discouraged due to the aforementioned EULA.

## Supported Platforms:

| OS | ! | Extra Details
| :---: | --- | --- |
| Windows 7/8.1/10 64-bit | ![-](https://placehold.it/15/118932/000000?text=+) | |
| Windows 7/8.1/10 32-bit | ![-](https://placehold.it/15/118932/000000?text=+) | |
| Windows XP 64/32-bit | ![-](https://placehold.it/15/1589F0/000000?text=+) | Likely works, untested. |
| ChromeOS x86_64 | ![-](https://placehold.it/15/118932/000000?text=+) | Requires Linux application compatibility to be enabled (often disabled on managed devices) |
| ChromeOS arm64 | ![-](https://placehold.it/15/f03c15/000000?text=+) | Currently unsupported, will be supported in the future. |
| Debian/Ubuntu Linux | ![-](https://placehold.it/15/118932/000000?text=+) | Should also function on any debian-based distribution. |
| Arch Linux | ![-](https://placehold.it/15/118932/000000?text=+) | Should also function on any arch-based distribution. Installed with `pacman -U`. |
| OSX | ![-](https://placehold.it/15/f03c15/000000?text=+) | Currently unsupported, support may be added in the future. |

## Usage

If you are simply planning to use these packages, please use the pre-built ones under the releases section. In the future, a site address may be provided that detects the OS in use for students or parents to easily navigate.

If you are a programmer or administrator willing to dive into how these packages are built, read on.

### Manual Building

The build process _requires_ a Linux environment to function correctly, due to the usage of cross-compilation tools It is advised to use Arch Linux for ease of accessing AUR packages, and although other distributions will function*, this will assume you are on that distribution.

Required packages: `base-devel`, `meson`, `libuv`, `lua`, `dpkg`, `mingw-w64-gcc`, `mingw-w64-libuv`, `mingw-w64-lua`
Required AUR packages: `msitools`, `debhelper`, `debian-utils`, `perl-pod-parser`

Once you've tracked down all the dependencies, simply run `./package_all.sh`. This will produce packages for all platforms in `pkg_out`.

* Building Pacman packages on other distributions may prove difficult

## License

This software is licensed under GPLv3 (see `COPYING`). ComputerCraftEdu is licensed under the CCPL.

Copyright 2020 Levi Webb