webstamp bash scripts
=======================

scripts for purchasing and stamping documents with
web-generated stamps from swisspost

v0.1-initial
(c) 2013 by cyrill von wattenwyl

License: Gnu PGL

Dependencies:
-----------------

* curl
* perl(URI)
* getopt

If you want to stamp PDF's directly, you need 

* pdftk

Usage:
------

**./login**

```
./login [username] [password]
```
*Example:*
```
./login "hansmeier@gmail.com" "pAssw0rd"
```
* For autologin, you need to edit the login file

```
./login
```


**./get_balance**

* Gets the current balance, is empty if not logged in

*Example:*
```
$ ./get_balance
CHF 8.85
```


**./purchase**

* Purchases one or more stamps with some options

```
./purchase -t A|B -n number -p L|R|U [-m nxm] [-s nxm] [-o output-filename] 

-t	--type		type of stamp: A (a-post) or B (b-post)
-n	--number	number of stamps
-p 	--position	position of stamp: L (left) R (right) U (user defined)
-m	--mediasize	size of media in mm HEIGHTxWIDTH, example 210x296
-s	--stamppos	position of stamp in mm LEFTxTOP, example 110x41
-o	--output	output file name
```
*Examples*
```
./purchase -t A -n 1 -p R
./purchase -t B -n 5 -p R -m 210x296 -s 110x92 -o /tmp/ws-tmp.pdf
./purchase --type=A --number=1 --position=L --output=filename.pdf
```


**./stamp**

* Stamp a document with a webstamp, Backups the Original as file.orig.pdf

```
./stamp document.pdf stamp.pdf
```
*Example:*
```
./stamp /home/eni/Documents/testbrief.pdf /tmp/ws-tmp.pdf
```



Workflow:
---------
```
$ ./login
$ ./purchase -t A -n 1 -p R -o /tmp/ws-tmp.pdf
$ ./stamp mydocument.pdf /tmp/ws-tmp.pdf
$ rm /tmp/ws-tmp.pdf
```
