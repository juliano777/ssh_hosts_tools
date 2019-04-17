#!/bin/bash

##############################################################################
#                                                                            # 
# Shell program to send public keys to all nodes in a cluster.               #
#                                                                            #
# Revisions:                                                                 # 
#                                                                            #
# 2019-04-17	File created.                                                # 
# Author: Juliano Atanazio (juliano777@gmail.com)                            #
##############################################################################

LICENSE='
This software is licensed under the New BSD Licence.
******************************************************************************
Copyright (c) 2015, Juliano Atanazio - juliano777@gmail.com
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
-        Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
-        Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
-        Neither the name of the Juliano Atanazio nor the names of its
    contributors may be used to endorse or promote products derived from this
    software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIAB
LE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
******************************************************************************
'



# Environment variable that contains the hosts (mandatory!):

export HOSTS_FILE="${1}"

if [ -z ${HOSTS_FILE} ]; then
    echo "Usage: ${0} host_file"
    exit 1
fi

# Create a new or erase the authorized keys file:

echo '' > /tmp/authorized_keys

# Environment variable for the user with sudo power:
read -p 'What is the user with sudo: ' SUDO_USER

export SUDO_USER

# Environment variable for the ssh user:

read -p 'What is the SSH user: ' SSH_USER

export SSH_USER

# Environment variable for the Hadoop group:

read -p "What is the SSH user group: " SSH_GROUP

# "hadoop" is the default group:

export SSH_GROUP="${SSH_GROUP:-${SSH_USER}}"


# First parameter, the file the contains the hosts (second column):

export CLUSTER=`cat ${HOSTS_FILE}`

# Get the master node hostname:

export MASTER_NODE=`head -1 ${HOSTS_FILE}`


# Get ther workers nodes hostnames:

export WORKERS_NODES=`fgrep -v ${MASTER_NODE} ${HOSTS_FILE}`


# Loop for generate SSH keys and the authorized_keys file

for host in ${CLUSTER}; do
    CMD_KEYGEN="ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa > /dev/null"
    CMD_CAT_KEY="cat ~/.ssh/id_rsa.pub"
    CMD_1="sudo su - ${SSH_USER} -c \\\"${CMD_KEYGEN}\\\""
    CMD_2="sudo su - ${SSH_USER} -c \\\"${CMD_CAT_KEY}\\\""
    
    CMD_1="ssh ${SUDO_USER}@${host} \"$CMD_1\""
    CMD_2="ssh ${SUDO_USER}@${host} \"$CMD_2\""
    eval "${CMD_1}"
    eval "${CMD_2}" >> /tmp/authorized_keys
done

# Loop for send the authorized_keys to all remaining nodes in /tmp:

for host in ${WORKERS_NODES}; do
    scp /tmp/authorized_keys ${SUDO_USER}@${host}:/tmp
done

# Loop for move the authorized_keys file to ~/.ssh, ownership and permissions:

for host in ${CLUSTER}; do
    CMD_1="sudo mv /tmp/authorized_keys ~${SSH_USER}/.ssh/"
    CMD_2="sudo chown -R ${SSH_USER}:${SSH_GROUP} ~${SSH_USER}/.ssh/"
    CMD_3="sudo chmod -R 0600 ~${SSH_USER}/.ssh"
    CMD_4="sudo chmod 0700 ~${SSH_USER}/.ssh"
    ssh ${SUDO_USER}@${host} "${CMD_1}"
    ssh ${SUDO_USER}@${host} "${CMD_2}"
    ssh ${SUDO_USER}@${host} "${CMD_3}"
    ssh ${SUDO_USER}@${host} "${CMD_4}"
    
done

# Remove the authorized_keys temporary file:

rm -f /tmp/authorized_keys
