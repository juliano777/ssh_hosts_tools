#!/bin/bash

##############################################################################
#                                                                            # 
# Shell program to connect in each node of the cluster and accept its server #
# key.                                                                       #
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

# First parameter, the file the contains the hosts (second column):

export CLUSTER=`cat ${HOSTS_FILE}`

# Environment variable for the user with sudo power:
read -p 'What is the user with sudo: ' SUDO_USER

export SUDO_USER

# Environment variable for the ssh user:

read -p 'What is the SSH user: ' SSH_USER

export SSH_USER

# Loop for connect in each node and accept its keys server:

for h in ${CLUSTER}; do

    for i in ${CLUSTER}; do
        CMD="ssh -oStrictHostKeyChecking=no ${h} uptime"
        CMD="sudo su - ${SSH_USER} -c \"${CMD}\""
        CMD="ssh ${SUDO_USER}@${i} '${CMD}'"
        eval ${CMD}
    done
done

