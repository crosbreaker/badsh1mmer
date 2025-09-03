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
badsh1mmer is a sh1mmer payloads menu injected into badrecovery unverified, allowing for unenrollment on keyrolled kv5 ChromeOS devices.

### How do I make a usb?
Download an prebuilt from the [prebuilts section](#prebuilts), or build an image your self with the above commands.  Flash it using the [Chromebook Recovery Utility](https://chromewebstore.google.com/detail/chromebook-recovery-utili/pocpnlppkickgojjlmhdmidojbmbodfm), or anything else that etches
### I have a usb, what now?
Complete [sh1ttyOOBE](https://github.com/crosbreaker/sh1ttyOOBE), then enter developer mode and recover to your usb
### Prebuilts

[GitHub actions](https://nightly.link/crosbreaker/badsh1mmer/actions/runs/17413105574)
### Credits:
[HarryJarry1](https://github.com/HarryJarry1) - Badbr0ker, finding the VPD vulnerability

[BinBashBanana](https://github.com/binbashbanana) - original br0ker, badrecovery

[Crossjbly](https://github.com/crossjbly) - Creating menu, anything new that was added ontop of the original badbr0ker source code

[Lxrd](https://github.com/SPIRAME) - Sh1ttyOOBE

[codenerd87](https://github.com/codenerd87) - more board support on badbr0ker
