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


# Unset XDG_RUNTIME_DIR as we lose write permission to this directory in `qsub`
# and Jupyter wants to be able to write some files there if it is set.
#
# xref: https://github.com/jupyter/notebook/issues/1923
#
unset XDG_RUNTIME_DIR

# Remove the config variables file at the beginning and the end.
rm -f ~/ipython_notebook_config_vars
trap "rm -f ~/ipython_notebook_config_vars" EXIT

# Copy the notebook to the current work directory
WORKFLOW="nanshe_ipython.ipynb"
if [ ! -e $WORKFLOW ];
then
  cp -n ~/nanshe_workflow/$WORKFLOW ./$WORKFLOW
fi

# Launch the job and grab the output from launching it.
CWD=$(pwd)
if hash jupyter 2>/dev/null;
then
  $(cd ~ && splaunch jupyter notebook --no-browser --ip=* --notebook-dir=$CWD --port 9999 > ~/splaunch_startup_ipython_notebook.out 2> ~/splaunch_startup_ipython_notebook.err)
else
  $(cd ~ && splaunch ipython notebook --no-browser --ip=* --notebook-dir=$CWD --port 9999 > ~/splaunch_startup_ipython_notebook.out 2> ~/splaunch_startup_ipython_notebook.err)
fi

# Get the SGE job ID.
QJOB_ID=$(cat ~/splaunch_startup_ipython_notebook.out | tr "\"" "\n" | tail -2 | head -1)

# Remove the notebook when the script exits.
trap "qdel $QJOB_ID" EXIT

# Wait for the job to start.
while [ "$(qstat | grep "^\s\+$QJOB_ID\s\+" | grep "\s\+r\s\+" | wc -l)" == "0" ];
do
  sleep 1
done

# Gets the queue that it is running on.
QJOB_QUEUENAME=`LINE=$(qstat | grep "^\s\+$QJOB_ID\s\+"); VALS=($LINE); echo ${VALS[${#VALS[@]}-2]}`
QJOB_HOSTNAME=`VALS=(${QJOB_QUEUENAME/@/ }); VALS=${VALS[${#VALS[@]}-1]}; VALS=(${VALS/./ }); echo ${VALS[0]}`

# Wait for the log file to get some content.
QJOB_STDERR_PATH=~/$(qstat -j $QJOB_ID | grep stderr_path_list | tr ":" "\n" | tail -1)
until [ -s $QJOB_STDERR_PATH ];
do
  sleep 1
done

# Gets the iPython Notebook port used.
IPYTHON_PORT=$(grep "http://\[all ip addresses on your system\]:" $QJOB_STDERR_PATH | tr ":" "\n" | tail -1 | sed -e "s/\///g")
while [ -z "${IPYTHON_PORT}" ] && [ $(qstat -j $QJOB_ID) ];
do
  sleep 1
  IPYTHON_PORT=$(grep "http://\[all ip addresses on your system\]:" $QJOB_STDERR_PATH | tr ":" "\n" | tail -1 | sed -e "s/\///g")
done

# Get a port if one isn't provided.
if [[ -z "${LOGIN_NODE_PORT}" ]];
then
  LOGIN_NODE_PORT=9999
fi

# Try to create a tunnel using each port available until one works.
while [ true ];
do
  # Store the iPython config variables when we are ready for the connection. If it fails, up the port number on the login node.
  echo -e "QJOB_ID=$QJOB_ID\nQJOB_QUEUENAME=$QJOB_QUEUENAME\nQJOB_HOSTNAME=$QJOB_HOSTNAME\nIPYTHON_PORT=$IPYTHON_PORT\nLOGIN_NODE_PORT=$LOGIN_NODE_PORT" > ~/ipython_notebook_config_vars
  ssh -o ExitOnForwardFailure=yes -vnNTL $LOGIN_NODE_PORT:localhost:$IPYTHON_PORT $QJOB_HOSTNAME | cat
  [[ $? -eq 0 ]] || break
  ((LOGIN_NODE_PORT++))
done
