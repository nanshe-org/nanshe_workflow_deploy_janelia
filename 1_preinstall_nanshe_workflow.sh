#!/bin/bash


# Copyright (c) 2016-2019, John Kirkham, Howard Hughes Medical Institute
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


# Fix up the bash profile.
touch ~/.bash_profile
if ! $(grep -q "source ~/.nanshe_workflow.sh" ~/.bash_profile);
then
  echo "" >> ~/.bash_profile
  echo "source ~/.nanshe_workflow.sh" >> ~/.bash_profile
fi

# (Re)Create our bash startup script to setup the environment.
rm -f ~/.nanshe_workflow.sh
touch ~/.nanshe_workflow.sh
echo '# Set the temporary directory.' >> ~/.nanshe_workflow.sh
echo 'TMPDIR="$HOME/tmp"' >> ~/.nanshe_workflow.sh
echo 'TEMP="$TMPDIR"' >> ~/.nanshe_workflow.sh
echo 'TMP="$TMPDIR"' >> ~/.nanshe_workflow.sh
echo 'export TMPDIR TEMP TMP' >> ~/.nanshe_workflow.sh
echo 'mkdir -p "$TMPDIR"' >> ~/.nanshe_workflow.sh
echo '' >> ~/.nanshe_workflow.sh
echo '# Export Grid Engine and DRMAA variables, if available.' >> ~/.nanshe_workflow.sh
echo '# May not be available when using Linux locally or Windows with Git Bash.' >> ~/.nanshe_workflow.sh
echo 'if [[ -f /sge/current/default/common/settings.sh ]]; then' >> ~/.nanshe_workflow.sh
echo '    source /sge/current/default/common/settings.sh' >> ~/.nanshe_workflow.sh
echo '    export SGE_DRMAA_LIBRARY_PATH="$SGE_ROOT/lib/lx-amd64/libdrmaa.so.1.0"' >> ~/.nanshe_workflow.sh
echo '    export DRMAA_LIBRARY_PATH="$SGE_DRMAA_LIBRARY_PATH"' >> ~/.nanshe_workflow.sh
echo 'fi' >> ~/.nanshe_workflow.sh
echo '# Export LSF variables, if available.' >> ~/.nanshe_workflow.sh
echo '# May not be available when using Linux locally or Windows with Git Bash.' >> ~/.nanshe_workflow.sh
echo 'if [[ -f /misc/lsf/conf/profile.lsf ]]; then' >> ~/.nanshe_workflow.sh
echo '    source /misc/lsf/conf/profile.lsf' >> ~/.nanshe_workflow.sh
echo '    export LSB_STDOUT_DIRECT='Y'' >> ~/.nanshe_workflow.sh
echo '    export LSB_JOB_REPORT_MAIL='N'' >> ~/.nanshe_workflow.sh
echo '    export LSF_DRMAA_LIBRARY_PATH="/misc/sc/lsf-glibc2.3/lib/libdrmaa.so.0.1.1"' >> ~/.nanshe_workflow.sh
echo '    export DRMAA_LIBRARY_PATH="$LSF_DRMAA_LIBRARY_PATH"' >> ~/.nanshe_workflow.sh
echo 'fi' >> ~/.nanshe_workflow.sh
echo '' >> ~/.nanshe_workflow.sh
echo '# Set the number of OpenBLAS threads to 1.' >> ~/.nanshe_workflow.sh
echo '# As we parallelize blocks of data being processed' >> ~/.nanshe_workflow.sh
echo '# and that gives us the most power when processing data,' >> ~/.nanshe_workflow.sh
echo '# we don't find parallelism from the BLAS to be too helpful.' >> ~/.nanshe_workflow.sh
echo '# So we ensure that it isn't parallelized.' >> ~/.nanshe_workflow.sh
echo 'export OPENBLAS_NUM_THREADS=1' >> ~/.nanshe_workflow.sh
echo '' >> ~/.nanshe_workflow.sh
echo '# Set the Jupyter runtime directory in the user's home.' >> ~/.nanshe_workflow.sh
echo '# This simply follows the recommendation of our cluster admins' >> ~/.nanshe_workflow.sh
echo '# to redirect this to a different location than XDG_RUNTIME_DIR.' >> ~/.nanshe_workflow.sh
echo '# This is just what Jupyter picks when XDG_RUNTIME_DIR is disabled.' >> ~/.nanshe_workflow.sh
echo 'export JUPYTER_RUNTIME_DIR="$HOME/.local/share/jupyter/runtime"' >> ~/.nanshe_workflow.sh
