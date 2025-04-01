# This file helps managing SSH CA a little, and probably not that fine, for
# example it doesn't care about serials yet. Maybe added later, dunno.
# If you need a good walkthrough here's one:
#
#	https://community.hetzner.com/tutorials/simple-ca-for-ssh
#
# To start signing keys you need:
#
#  1.	./server_ca and server_ca.pub, better make them encrypted and provide a
#	passphrase, you can create them with:
#
#	make server_ca
#
#  2.	Load the key and get ready (starts a subshell, inside which you have
#	passwordless access to your signing key):
#
#	make start
#
#  3.	Generate keys:
#
#	make
#
# Script assumes all host keys are stored in directories named after the
# hostname, like:
#
#	some.host/ssh_host_rsa_key.pub
#
# And all user keys stored under the "users" folder in filenames:
#
#	users/user@hostname.pub
#
# Script automatically echoes your certs to output, so you can copy them.
#
# (C) Volodymyr Kostyrko, 2023, arcade@b1t.name

HOSTS:=	${:!find . -maxdepth 1 -mindepth 1 -type d | grep -v 'users' | sed -e 's/^\.\///g'!}
USERS:=	${:!find users -type f -name '*@*.pub' | grep -v '\-cert.pub'!}
TYPES:=	ed25519 rsa
HOSTKEYS:=
USERKEYS:=

all: hostkeys userkeys
.if empty(HOSTS) && empty(USERS)
	: There is nothing to do, try running:
	: make help
.endif

.PHONY: all hostkeys userkeys start help

_PRINT: .USE
	: ==[ $@ ]==
	@cat $@
	: =-=-=-=-=

.for HOST in ${HOSTS}
.	for TYPE in ${TYPES}
.		if exists(${HOST}/ssh_host_${TYPE}_key.pub)
HOSTKEYS+=	${HOST}/ssh_host_${TYPE}_key-cert.pub
${HOST}/ssh_host_${TYPE}_key-cert.pub: ${HOST}/ssh_host_${TYPE}_key.pub _PRINT
	ssh-keygen -Us server_ca.pub -I "${HOST} host key" -n "${HOST},${HOST:C/\..*//g}" -h -V -1d:+1095d $>
.		endif
.	endfor
.endfor

.for USERKEY in ${USERS}
USERKEYS+=	${USERKEY:C/\.pub$/-cert.pub/}
${USERKEY:C/\.pub$/-cert.pub/}: ${USERKEY} _PRINT
	ssh-keygen -Us server_ca.pub -I "${USERKEY:C|^users/||} user key" -n ${USERKEY:C|^users/||:C|@.*||} -V -5m:+1095d $>
.endfor

hostkeys: ${HOSTKEYS}
userkeys: ${USERKEYS}

start: server_ca
	ssh-agent sh -c "ssh-add server_ca && sh"

server_ca:
	ssh-keygen -f server_ca -t ed25519

help:
	@awk '$$0~/^([^#]|$$)/{exit}$$0~/^#/{gsub("^# ?", "");print$$0}' Makefile
