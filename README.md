### badbr0ker
# Support
If you need any kind of support, please join our [discord server](https://discord.gg/nrMVY29MUb) for help
### If you would like the script to do everything for you:
```bash
git clone https://github.com/crosbreaker/badbr0ker
cd badbr0ker
bash buildfull_badbr0ker.sh <board>
```
### If you would like to use a local recovery image:
```bash
git clone https://github.com/crosbreaker/badbr0ker
cd badbr0ker
bash update_downloader.sh <board>
sudo ./build_badrecovery.sh -i image.bin -t unverified
```
### What is this?
badbr0ker is br0ker injected into badrecovery unverified, allowing for unenrollment on keyrolled kv5 ChromeOS devices.
### How do I make a usb?
Download an prebuilt from the [prebuilts section](#prebuilts), or build an image your self with the above commands.  Flash it using the [Chromebook Recovery Utility](https://chromewebstore.google.com/detail/chromebook-recovery-utili/pocpnlppkickgojjlmhdmidojbmbodfm), or anything else that etches
### I have a usb, what now?
Complete [sh1ttyOOBE](https://github.com/crosbreaker/sh1ttyOOBE), then enter developer mode and recover to your usb
### Prebuilts
[Crosbreaker](https://dl.crosbreaker.dev/ChromeOS/badbr0ker/)

[Fanqyxl](https://dl.fanqyxl.net/Crosbreaker/badbr0ker)

[GitHub actions](https://nightly.link/crosbreaker/badbr0ker/actions/runs/16983496435)
### Credits:
[HarryJarry1](https://github.com/HarryJarry1) - All badbr0ker development 

[BinBashBanana](https://github.com/binbashbanana) - original br0ker, badrecovery

[Lxrd](https://github.com/SPIRAME) - Sh1ttyOOBE

[Crossjbly](https://github.com/crossjbly) - Fixing a few things
