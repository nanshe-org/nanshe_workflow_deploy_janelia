# Install GitHub Desktop.

* Install ( https://desktop.github.com/ )
* Login to GitHub with the app
* Quit
* Restart
* This should configure your ssh key for cloning of private repos.

# Setup passwordless ssh to nodes on the cluster (required for job submission).

* Connect to the cluster `ssh login1.int.janelia.org`.
* Create a key and setup passwordless `ssh` for launching jobs by running this `ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys` and hitting enter all the way through.
* Copy everything returned by this `cat ~/.ssh/id_rsa.pub`.

# Configure the cluster

* Connect to the cluster `ssh login1.int.janelia.org`.
* Run `bsub -Is -tty /bin/bash`.
* Run our configuration file `curl https://raw.githubusercontent.com/nanshe-org/nanshe_workflow_deploy_janelia/master/1_preinstall_nanshe_workflow.sh | bash`.
* Alternatively, this can be run in the background `echo 'curl https://raw.githubusercontent.com/nanshe-org/nanshe_workflow_deploy_janelia/master/1_preinstall_nanshe_workflow.sh | bash' | bsub`. Check to make sure it is done by running `bjobs` and verifying `STDIN` is no longer in the job list returned.
* Logout of the cluster. All changes will take effect on the next login.

# Installing/Updating

* Connect to the cluster `ssh login1.int.janelia.org`.
* Run this `singularity build ~/nanshe_workflow.simg docker://nanshe/nanshe_workflow`.
* Alternatively, this can be run in the background with `bsub singularity build ~/nanshe_workflow.simg docker://nanshe/nanshe_workflow`. Check to make sure it is done by running `bjobs` and verifying the job is no longer in the list returned.
* If this fails for any reason, try opening GitHub Desktop. Once it is fully loaded close it. Then, open a new Terminal or Git Bash (GitHub). Finally, rerun these steps.

# Running

* Connect to the cluster `ssh login1.int.janelia.org`.
* Switch to a directory with data using `cd`.
* Run `bsub -Is -tty /bin/bash` and then run `singularity run --bind /misc --bind /scratch ~/nanshe_workflow.simg`.
* Alternatively run the `bsub singularity run --bind /misc --bind /scratch ~/nanshe_workflow.simg` and then wait a little and run `bpeek`.
* It will take a little bit to start then it will print a bunch of stuff to the screen and hang (this is intentional).
* Open a new terminal, and run the following `curl https://raw.githubusercontent.com/nanshe-org/nanshe_workflow_deploy_janelia/master/4_connect_nanshe_workflow.sh > 4_connect_nanshe_workflow.sh && bash 4_connect_nanshe_workflow.sh ; rm 4_connect_nanshe_workflow.sh`. It will prompt you for your password twice and hang (this is intentional).
* Open <http://127.0.0.1:8888> in your browser.
* Select `nanshe_ipython.ipynb`.
* Find the cell with `os.environ["CORES"]` and comment that line and add a line like this `os.environ["CORES"] = "8"` below it. Replace `8` with the number of cores desired to run.

# Shutting down

* Save and close your notebook.
* Terminate both `ssh` processes by pressing `Ctrl+c` in each terminal.
* Get on the cluster `ssh login1.int.janelia.org` and make sure there are no remaining jobs `bjobs`.
* Clean any remaining jobs with `bkill`.

# Security

* Everything I just told you can still leave you **vulnerable**!
* An improvement on this procedure is to create a password to access the notebook.
* To do this run the following `python -c "from IPython.lib import passwd; print passwd()"`.
* Enter a password ideally different from your existing one, twice.
* This will return something like this `sha1:HHHHHHHHHHHH:HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH` where `H` is a hex number.
* Go into the file `~/.ipython/profile_default/ipython_notebook_config.py` on the cluster and find the line with `c.NotebookApp.password`.
* Uncomment it and place the full string in there. It will look like this `c.NotebookApp.password = u'sha1:HHHHHHHHHHHH:HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH'`
* Now if someone tries to get into your notebook, they will have to enter a password.
* However, this password is going over the wire unencrypted (in an SSH tunnel). If this is a concern for you, create a certificate.
* Run the following, `openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ipython.pem -out ipython.pem`.
* This will give you a certificate that will last for roughly a year. It contains the key and certificate data.
* To use this certificate, go into the file `~/.ipython/profile_default/ipython_notebook_config.py` on the cluster look for the line with `c.NotebookApp.certfile`.
* Uncomment replace that line with this `c.NotebookApp.certfile = u'ipython.pem'`.
* This certificate will be unsigned, which will make your browser very upset, but it can be coerced into acceptance.
