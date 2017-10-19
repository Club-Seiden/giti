# giti
*git-i* (i for IBM i). 5250 green screen repository browser inspired by [gitk](https://git-scm.com/docs/gitk).

### How to build

This project uses [Relic Package Manager](https://github.com/OSSILE/RelicPackageManager) to build it's objects.

Simply run: `RELICGET PLOC('https://github.com/Club-Seiden/giti/archive/master.zip') PDIR('giti-master') PNAME(QTEMP)`

### How to use

1. Change your currect directory to an IFS location which is a git repository
2. Run `GITI` in your interactive job.

The display has three columns: the commit author, date and message. There is only a single entry field in the program at the moment, which is the 'file' field. You can enter in a file within the repository in which you would like to find the commits for. Currently, the option parameter for each commit does not function.

![Using giti on the giti repo](http://i.imgur.com/3WuncIn.png)
![Using giti to look at a commit](http://i.imgur.com/cgUu7Lb.png)
![Using giti to select a branch](http://i.imgur.com/fuiqK4H.png)

### Not listing your commits?

You might find that if your commits aren't listing, then Git cannot be found QP2TERM.

#### Fix 1

Check your `PASE_PATH` environment variable using `WRKENVVAR`. It should look something like this:

```
/QOpenSys/usr/bin:/usr/ccs/bin:/QOpenSys/usr/bin/X11:/usr/bin/X11:/usr/sbin:.:/usr/bin
```

If it doesn't, add those paths to that list.

#### Fix 2

If you are not able to change the `PASE_PATH` environment variable, there is another simple way.

1. Create `.profile` in your home directory. 
2. Paste `export PATH=/QOpenSys/usr/bin:/usr/ccs/bin:/QOpenSys/usr/bin/X11:/usr/bin/X11:/usr/sbin:.:/usr/bin` into that stream file.
3. Re-signon and try Giti again.
