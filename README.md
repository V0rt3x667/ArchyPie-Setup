# ArchyPie-Setup
A clone of RetroPie for Arch Linux Based Systems

# I am currently rewritting ArchyPie to bring it back into line with RetroPie. Along the way I have had to hack n' slash the code to get things working. After trying to make a port for Void Linux and adding back missing features into ArchyPie, as well as trying to get things working on the Raspberry Pi it is clear a fresh start is required. Please continue to use the main branch for now and report any bugs you find. Thanks for trying ArchyPie, I hope to update the code soon. 

To run the ArchyPie Setup Script make sure that your pacman repositories are up-to-date and that Git is installed:

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
