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
cat > ~/.nanshe_workflow.sh << 'EOF'
# Set the temporary directory.
TMPDIR="$HOME/tmp"
TEMP="$TMPDIR"
TMP="$TMPDIR"
export TMPDIR TEMP TMP
mkdir -p "$TMPDIR"

# Export Grid Engine and DRMAA variables, if available.
# May not be available when using Linux locally or Windows with Git Bash.
if [[ -f /sge/current/default/common/settings.sh ]]; then
    source /sge/current/default/common/settings.sh
    export SGE_DRMAA_LIBRARY_PATH="$SGE_ROOT/lib/lx-amd64/libdrmaa.so.1.0"
    export DRMAA_LIBRARY_PATH="$SGE_DRMAA_LIBRARY_PATH"
fi
# Export LSF variables, if available.
# May not be available when using Linux locally or Windows with Git Bash.
if [[ -f /misc/lsf/conf/profile.lsf ]]; then
    source /misc/lsf/conf/profile.lsf
    export LSB_STDOUT_DIRECT="Y"
    export LSB_JOB_REPORT_MAIL="N"
    export LSF_DRMAA_LIBRARY_PATH="/misc/sc/lsf-glibc2.3/lib/libdrmaa.so.0.1.1"
    export DRMAA_LIBRARY_PATH="$LSF_DRMAA_LIBRARY_PATH"
fi
EOF
