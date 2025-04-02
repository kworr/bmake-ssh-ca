# bmake-ssh-ca
Automation script to handle your own small SSH CA setup.

This one is created with BSDs in mind, where default make is bmake. Try `make
help` should be selfexplanatory. Useful if you have a small setup with just a
dozen of hosts, or if you just want to look better at how SSH CA works.

## What it does

Saves you time digging the docs and sets a minimum standard to organize all your
pubkeys/certs.

## What it doesn't

Configures your hosts, automates deployment etc. You have to update server
configuration yourself, but it's mostly static, script it the way you want.

## Security concirns

Please choose a good password, I beg you. Also please don't share the contents
of directory anywhere. Even better, move it to some flash drive and keep it
offline, preferrably in 2 copies.

## Periodic checks

You can add this to your crontab to make periodic checks for expiring
certificates:

    @weekly make check -C /path/to/your/folder

It will only generate some output if there are some keys expiring soon.
