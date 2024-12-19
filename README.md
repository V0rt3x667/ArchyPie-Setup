# ArchyPie-Setup
A clone of RetroPie for Arch Linux based systems with extra seasoning!

 To run the ArchyPie Setup Script make sure that your Pacman repositories are up-to-date and that Git is installed:

```shell
sudo pacman -Syyu
sudo pacman -S git
```

Then you can download the latest ArchyPie setup script with:

```shell
git clone --depth 1 https://github.com/V0rt3x667/ArchyPie-Setup.git
```

The script is executed with:

```shell
cd ArchyPie-Setup
sudo ./archypie_setup.sh
