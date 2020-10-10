# ComputerCraftEdu Installer

**NOTE:** this project is incomplete. See this repository at a later date.

This is a cross-platform package and installer builder that automatically installs a version of minecraft with ComputerCraftEdu modded on top of the installation. The actual Minecraft client is downloaded at runtime, and is not packaged with the installer.

**Backstory:** This is a project that was written upon request by an anonymous non-profit organization that aims to teach kids how to write software using ComputerCraftEdu. Because this organization has switched to a virtual setup due to covid-19, this project serves as a simple means for children and/or parents to install the required software.

The installer creates desktop and menu entries on supported platforms that automatically launch the game. The launcher _does not authenticate with Minecraft's login servers_ to avoid issues with educators distributing minecraft accounts in a remote setting (and to avoid students having to navigate the vanilla game launcher). It's worth mentioning that this usage of Mojang services is a breach of the game's EULA, but not its copyright, but it is extremely unlikely to result in any change to the products and/or services provided by Mojang/Microsoft.

Educators should be aware that this version of the game is the original Java version, not the Education Edition (EE) that Microsoft offers to educators. Organizations interested in the latter should simply purchase a license, and if your organization already holds an educator's license, usage of this installer is discouraged due to the aforementioned EULA.