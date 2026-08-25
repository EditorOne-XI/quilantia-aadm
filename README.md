# Quilantia AADM

**Quilantia Android Application Development Manager** (aadm), is a CLI wrapper for managing Android Application build and projects for [Termux](https://github.com/termux).

> [!CAUTION]
> This setup is for educational purposes only. Only use this when needed as this setup might break eventually.

> [!WARNING]
> This setup utilizes both Termux and Debian PRoot, where Termux is used for coding and patching, then Debian PRoot is for Android SDK and Android app building.

This setup has support for generating Java classpaths for Neovim with custom Java LSP configuration.

## Features

The wrapper comes with an automatic project generator and reconfiguration for projects normally created on Android Studio. This includes:

- Gradle wrapper rebuild.
- Compatibility Android SDK build.
- Generate new projects. (EmptyViewsActivity only, Java)

The wrapper includes `classpath` for listing Java/Kotlin classes, and `install` for automatic app installation.

For my custom Java LSP, you can check it [here](neovim_lsp.md).

## Requirements

- Termux
- Termux:API
- At least 5-6 GB free disk space. (Equivalent to Android Studio Mobile + proot-distro)
- (_Optional_) NeoVim with LazyVim. (tests were made with NvChad UI Framework)

## Installation

To install this setup to your local device. Update Termux packages and install required utilities:

```bash
yes | pkg upgrade
yes | pkg install termux-api tar zip openjdk-21 neovim git wget proot-distro aapt2 tree
```
---

Next, clone this repository to your `~/.local/share/`:

```bash
git clone https://github.com/EditorOne-XI/quilantia-aadm.git ~/.local/share/quilantia-aadm
cd ~/.local/share/quilantia-aadm
```
---

Then execute initial setup:

```bash
bash ./init.sh
```
- There are two main component after executing initial setup:
  - Added `pdd` command, which opens `proot-distro login debian` with options for environmental variables and Android workplace binded paths.
  - Added `aadm` command for the build setup and project workflow.

---

Now, install **Debian (trixie)** PRoot:

```bash
proot-distro install debian
```
---

After installing Debian PRoot, copy a directory path if you will use a specific workplace path. Then login to debian with only this command:

```bash
pdd
```

> [!NOTE]
> You can adjust the configuration of the command with `nvim "$PREFIX/bin/pdd"` if you have other configurations with it. <br>
> Default binded workplace path would be `~/androidAppDev`. It turns into a symbolic link if you specified a workplace path from the login.

---

After logging in to Debian, update Debian packages and install required utilities:

```bash
apt update -y
apt install openjdk-21-jdk wget git zip -y
```

---

Now that you have installed all the required packages, you can use the `aadm` command to set up Android CLI, Gradle, and new or existing projects.

Workflow:
- `aadm new` to create new projects.
- `aadm exists` to reconfigure existing projects.
- `./gradlew [args]...` for build management.
- `aadm install` to install APK which uses the `termux-open` command from the termux-api package.

> [!NOTE]
> You can change the version of OpenJDK and any configuration the default generates, but Gradle 9+ and newer Android SDK might not be compatible with this custom setup.

## License

    Copyright 2026 EditorOne XI | EditorOne5312

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

- The resource files in `res/`, and template code generated from `aadm` are derived from [Android Studio](https://developer.android.com/studio) using the 'EmptyViewsActivity' project template created by Google LLC, licensed under Apache 2.0.

### Acknowledgments

- [Termux](https://github.com/termux)
- [Oracle](https://openjdk.org/)
- [Google LLC](https://about.google/)
- [Gradle](https://gradle.org/)
- Inspired by [tmatz/build_android_app_on_termux.md](https://gist.github.com/tmatz/817bf03433e059bf89c63dc33f286ccb).

---

Project started on 2026, August 18th.

Thank You! <br> - EditorOne XI
