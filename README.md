# giti
*git-i* (i for IBM i). 5250 green screen repository browser inspired by [gitk](https://git-scm.com/docs/gitk).

### How to build

This project uses [Relic Package Manager](https://github.com/OSSILE/RelicPackageManager) to build it's objects.

Simply run: `RELICGET PLOC('https://github.com/Club-Seiden/giti/archive/master.zip') PDIR('giti-master') PNAME(QTEMP)`

### How to use

1. Change your currect directory to an IFS location which is a git repository
2. Run `GITI` in your interactive job.

The display has three columns: the commit author, date and message. There is only a single entry field in the program at the moment, which is the 'file' field. You can enter in a file within the repository in which you would like to find the commits for. Currently, the option parameter for each commit does not function.

![Using giti on the giti repo](http://i.imgur.com/RKApXjU.png)
