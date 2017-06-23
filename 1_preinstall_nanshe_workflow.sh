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


# Download and install conda.
rm -rf ~/miniconda
curl -L https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh > ~/miniconda.sh
bash ~/miniconda.sh -b -p ~/miniconda
rm -f ~/miniconda.sh

# Fix up the environment.
source ~/miniconda/bin/activate root

# Pin packages that need pinning.
rm -f ~/miniconda/conda-meta/pinned
touch ~/miniconda/conda-meta/pinned

# Add channels.
conda config --add channels conda-forge
conda config --add channels nanshe

# Update, install some needed tools, and cleanup.
conda update -y --all
conda install -y conda-build
conda install -y anaconda-client
conda install -y jinja2

# Create an environment for the workflow.
conda remove -y -n nanshenv --all
conda create -y -n nanshenv python
conda install -y -n nanshenv nanshe

# Install some other dependencies that will be needed.
conda install -y -n nanshenv drmaa splauncher
conda install -y -n nanshenv ipython-notebook

# Clean after all installs.
conda clean -yitps

# Setup iPython profiles for cluster usage.
rm -f ~/.ipython/profile_default/ipcluster_config.py
~/miniconda/envs/nanshenv/bin/ipython profile create --parallel
echo -e "import os\n\n\nc = get_config()\n\nc.IPClusterEngines.n = int(os.environ[\"CORES\"]) - 1\n\nc.HubFactory.ip = '\*'\nc.HubFactory.engine_ip = '\*'\nc.HubFactory.db_class = \"SQLiteDB\"\n\nc.IPEngineApp.wait_for_url_file = 60\nc.EngineFactory.timeout = 60" > ~/.ipython/profile_default/ipcluster_config.py
rm -f ~/.ipython/profile_sge/ipcluster_config.py
~/miniconda/envs/nanshenv/bin/ipython profile create --parallel --profile=sge
echo -e "import os\n\n\nc = get_config()\n\nc.IPClusterStart.controller_launcher_class = \"SGE\"\nc.IPClusterEngines.engine_launcher_class = \"SGE\"\nc.IPClusterEngines.n = int(os.environ[\"CORES\"]) - 1\n\nc.HubFactory.ip = '*'\nc.HubFactory.engine_ip = '*'\nc.HubFactory.db_class = \"SQLiteDB\"\n\nc.IPEngineApp.wait_for_url_file = 60\nc.EngineFactory.timeout = 60" > ~/.ipython/profile_sge/ipcluster_config.py
rm -f ~/.ipython/profile_lsf/ipcluster_config.py
~/miniconda/envs/nanshenv/bin/ipython profile create --parallel --profile=lsf
echo -e "import os\n\n\nc = get_config()\n\nc.IPClusterStart.controller_launcher_class = \"LSF\"\nc.IPClusterEngines.engine_launcher_class = \"LSF\"\nc.IPClusterEngines.n = int(os.environ[\"CORES\"]) - 1\n\nc.HubFactory.ip = '*'\nc.HubFactory.engine_ip = '*'\nc.HubFactory.db_class = \"SQLiteDB\"\n\nc.IPEngineApp.wait_for_url_file = 60\nc.EngineFactory.timeout = 60" > ~/.ipython/profile_lsf/ipcluster_config.py

# Fix up the bash profile.
echo "" >> ~/.bash_profile
if ! $(grep -q "source ~/.nanshe_workflow.sh" ~/.bash_profile);
then
  echo "source ~/.nanshe_workflow.sh" >> ~/.bash_profile
fi

# (Re)Create our bash startup script to setup the environment.
rm -f ~/.nanshe_workflow.sh
touch ~/.nanshe_workflow.sh
echo "# Set the temporary directory." >> ~/.nanshe_workflow.sh
echo "TMPDIR=\$HOME/tmp" >> ~/.nanshe_workflow.sh
echo "TEMP=\$TMPDIR" >> ~/.nanshe_workflow.sh
echo "TMP=\$TMPDIR" >> ~/.nanshe_workflow.sh
echo "export TMPDIR TEMP TMP" >> ~/.nanshe_workflow.sh
echo "mkdir -p \$TMPDIR" >> ~/.nanshe_workflow.sh
echo "" >> ~/.nanshe_workflow.sh
echo "# Export Grid Engine and DRMAA variables, if available." >> ~/.nanshe_workflow.sh
echo "# May not be available when using Linux locally or Windows with Git Bash." >> ~/.nanshe_workflow.sh
echo "if [[ -f /sge/current/default/common/settings.sh ]]; then" >> ~/.nanshe_workflow.sh
echo "    source /sge/current/default/common/settings.sh" >> ~/.nanshe_workflow.sh
echo "    export DRMAA_LIBRARY_PATH=\$SGE_ROOT/lib/lx-amd64/libdrmaa.so.1.0" >> ~/.nanshe_workflow.sh
echo "fi" >> ~/.nanshe_workflow.sh
echo "# Export LSF variables, if available." >> ~/.nanshe_workflow.sh
echo "# May not be available when using Linux locally or Windows with Git Bash." >> ~/.nanshe_workflow.sh
echo "if [[ -f /misc/lsf/conf/profile.lsf ]]; then" >> ~/.nanshe_workflow.sh
echo "    source /misc/lsf/conf/profile.lsf" >> ~/.nanshe_workflow.sh
echo "fi" >> ~/.nanshe_workflow.sh
echo "" >> ~/.nanshe_workflow.sh
echo "# Set the number of OpenBLAS threads to 1." >> ~/.nanshe_workflow.sh
echo "# As we parallelize blocks of data being processed" >> ~/.nanshe_workflow.sh
echo "# and that gives us the most power when processing data," >> ~/.nanshe_workflow.sh
echo "# we don't find parallelism from the BLAS to be too helpful." >> ~/.nanshe_workflow.sh
echo "# So we ensure that it isn't parallelized." >> ~/.nanshe_workflow.sh
echo "export OPENBLAS_NUM_THREADS=1" >> ~/.nanshe_workflow.sh
echo "" >> ~/.nanshe_workflow.sh
echo "# Add miniconda root to the path" >> ~/.nanshe_workflow.sh
echo "PATH=\$HOME/miniconda/bin:\$PATH" >> ~/.nanshe_workflow.sh
echo "" >> ~/.nanshe_workflow.sh
echo "# Activate the nanshe environment at login" >> ~/.nanshe_workflow.sh
echo "# Normally would do \`source activate nanshenv\` however this messes up NoMachine" >> ~/.nanshe_workflow.sh
echo "export CONDA_DEFAULT_ENV=nanshenv" >> ~/.nanshe_workflow.sh
echo "export CONDA_ENV_PATH=\$HOME/miniconda/envs/\$CONDA_DEFAULT_ENV" >> ~/.nanshe_workflow.sh
echo "export PATH=\$CONDA_ENV_PATH/bin:\$PATH" >> ~/.nanshe_workflow.sh
echo "#export PS1=(\$CONDA_DEFAULT_ENV)\$PS1" >> ~/.nanshe_workflow.sh
