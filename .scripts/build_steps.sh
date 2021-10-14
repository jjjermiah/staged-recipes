#!/usr/bin/env bash

# PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
# will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
# changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
# benefit from the improvement.

set -xeuo pipefail
export PYTHONUNBUFFERED=1

cat >~/.condarc <<CONDARC

channels:
 - conda-forge

conda-build:
 root-dir: /home/conda/staged-recipes/build_artifacts

show_channel_urls: true

CONDARC

# Copy the host recipes folder so we don't ever muck with it
cp -r /home/conda/staged-recipes ~/staged-recipes-copy

# Remove any macOS system files
find ~/staged-recipes-copy/recipes -maxdepth 1 -name ".DS_Store" -delete

# Find the recipes from main in this PR and remove them.
echo "Pending recipes."
ls -la ~/staged-recipes-copy/recipes
echo "Finding recipes merged in main and removing them from the build."
pushd /home/conda/staged-recipes/recipes > /dev/null
if [ "${AZURE}" == "True" ]; then
    git fetch --force origin main:main
fi
git ls-tree --name-only main -- . | xargs -I {} sh -c "rm -rf ~/staged-recipes-copy/recipes/{} && echo Removing recipe: {}"
popd > /dev/null


# Make sure build_artifacts is a valid channel
conda index /home/conda/staged-recipes/build_artifacts

conda install --yes --quiet "conda>4.7.12" conda-forge-ci-setup=3.* conda-forge-pinning networkx=2.4 "conda-build>=3.16" "boa>=0.7,<0.8"
export FEEDSTOCK_ROOT="${FEEDSTOCK_ROOT:-/home/conda/staged-recipes}"
export CI_SUPPORT="/home/conda/staged-recipes-copy/.ci_support"
setup_conda_rc "${FEEDSTOCK_ROOT}" "/home/conda/staged-recipes-copy/recipes" "${CI_SUPPORT}/${CONFIG}.yaml"
source run_conda_forge_build_setup

# yum installs anything from a "yum_requirements.txt" file that isn't a blank line or comment.
find ~/staged-recipes-copy/recipes -mindepth 2 -maxdepth 2 -type f -name "yum_requirements.txt" \
    | xargs -n1 cat | { grep -v -e "^#" -e "^$" || test $? == 1; } | \
    xargs -r /usr/bin/sudo -n yum install -y

python ${CI_SUPPORT}/build_all.py

touch "/home/conda/staged-recipes/build_artifacts/conda-forge-build-done"
