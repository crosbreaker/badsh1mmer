### badsh1mmer

# Support
If you need any kind of support, please join our [discord server](https://discord.gg/nrMVY29MUb) for help
### If you would like the script to do everything for you:
```bash
git clone https://github.com/crosbreaker/badsh1mmer
cd badsh1mmer
bash buildfull_badsh1mmer.sh <board>
```
### If you would like to use a local recovery image:
```bash
git clone https://github.com/crosbreaker/badsh1mmer
cd badsh1mmer
bash update_downloader.sh <board>
sudo ./build_badrecovery.sh -i image.bin -t unverified
```
### What is this?
badsh1mmer is a sh1mmer payloads menu injected into badrecovery unverified, allowing for unenrollment on keyrolled kv6 ChromeOS devices.

### How do I make a usb?
Download an prebuilt from the [prebuilts section](#prebuilts), or build an image yourself with the above commands.  
On Windows, use Rufus to flash.
On Linux, use dd as follows:
```sh
sudo dd if=/path/to/badsh1mmer.bin of=/dev/sdX bs=1M status=progress
```

(remember to replace X with the actual usb's letter identifier)
### I have a usb, what now?
If below kv6, complete [sh1ttyOOBE](https://github.com/crosbreaker/sh1ttyOOBE), then enter developer mode and recover to your usb <br>
Else, complete [sh1ttyexec](https://github.com/crosbreaker/sh1ttyexec)
### Prebuilts
- [GitHub Release](https://github.com/crosbreaker/badsh1mmer/releases/latest)

### Licensing
- [LICENSE](/LICENSE) - main license for all badsh1mmer code
- [LICENSE-RELEASES](/LICENSE-RELEASES) - license for github workflow
- [LICENSE-shrink_image](/LICENSE-shrink_image) - license for `shrink_image.sh` script

### Credits:
- [HarryTarryJarry](https://github.com/HarryTarryJarry) - Badbr0ker, finding the VPD vulnerability
- [BinBashBanana](https://github.com/binbashbanana) - original br0ker, badrecovery
- [Crossjbly](https://github.com/crossjbly) - Creating menu, anything new that was added ontop of the original badbr0ker source code
- [Lxrd](https://github.com/SPIRAME) - Sh1ttyOOBE
- [codenerd87](https://github.com/codenerd87) - more board support on badbr0ker
