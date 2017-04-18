#!/bin/bash


# Copyright (c) 2016, John Kirkham, Howard Hughes Medical Institute
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.


# Exit immediately at any failure.
set -e

# Fix up the environment.
source ~/miniconda/bin/activate nanshenv

# Go into the workflow repo. Creating it, if it doesn't exist.
if ! $(test -d ~/nanshe_workflow);
then
  git clone https://github.com/nanshe-org/nanshe_workflow.git ~/nanshe_workflow
fi
cd ~/nanshe_workflow

# Check if the repo is clean. Error if not.
if [ $(git status --porcelain | wc -l) -gt 0 ];
then
  echo "The `nanshe_workflow` repo is dirty. Clean it up before running update."
  exit 1
fi

# Update the master branch with the remote
git checkout master
git pull --ff

# Build and install the workflow meta package.
conda build nanshe_workflow.recipe
conda install -y --use-local -n nanshenv nanshe_workflow

# Trust the notebook.
jupyter trust ~/nanshe_workflow/nanshe_ipython.ipynb
