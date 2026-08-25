#!/bin/bash
# Copyright 2026 EditorOne XI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

check-cmd() {
    if [ -z "$1" ]; then return 1; fi
    if ! command -v "$1" >/dev/null; then
        echo "$CMDNAME: Command $1 not installed. Aborted." >&2
        exit 1
    fi
}
check-cmd zip

# Android Environment Variables
__aadm_bash_androidenv() {
    touch ~/.bashrc
    echo "
# ANDROID ENV VARIABLES
export ANDROID_HOME=\"\$HOME/.android-sdk\"
export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\"
export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\"
" >> ~/.bashrc
}

__aadm_zsh_androidenv() {
    touch ~/.zshrc
    echo "
# ANDROID ENV VARIABLES
export ANDROID_HOME=\"\$HOME/.android-sdk\"
export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\"
export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\"
" >> ~/.zshrc
}

__aadm_fish_androidenv() {
    mkdir -p ~/.config/fish/
    touch ~/.config/fish/config.fish
    echo "
# ANDROID ENV VARIABLES
set -gx ANDROID_HOME \"\$HOME/.android-sdk\"
set -gx ANDROID_SDK_ROOT \"\$ANDROID_HOME\"
set -gx PATH \"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\"
" >> ~/.config/fish/config.fish
}

__aadm_Neither_androidenv() {
    echo "[NOTE]
Make sure you export these variables to your Termux shell:
ANDROID_HOME = \"\$HOME/.android-sdk\"
ANDROID_SDK_ROOT = \"\$ANDROID_HOME\"
PATH = \"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\"
"
}

AADM_CMD="$HOME/.local/share/quilantia-aadm/aadm"
PDD_CMD="$HOME/.local/share/quilantia-aadm/pdd"
ANDROID_RES="$HOME/.local/share/quilantia-aadm/res"

if [ ! -f "$AADM_CMD" ] || [ ! -f "$PDD_CMD" ] || [ ! -d "$ANDROID_RES" ]; then
    echo "Unable to find aadm files. Aborted." >&2
    exit 1
fi

echo "Setting up aadm files..."
ln -fs "$AADM_CMD" "$PREFIX/bin/aadm"
ln -fs "$PDD_CMD" "$PREFIX/bin/pdd"

LASTDIR="$PWD"
cd "$ANDROID_RES"
zip -q -r ../android_res.zip ./
cd "$LASTDIR"
rm -rf "$ANDROID_RES"

echo "Select Shell to set Android Environment Variables:"
echo
select defsh in 'bash' 'zsh' 'fish' 'Neither'; do
    echo
    [[ "$defsh" != "Neither" ]] && echo "Setting up Android Environment Variables to ${defsh}..."
    __aadm_${defsh}_androidenv
    break
done
echo "Initial setup done."
