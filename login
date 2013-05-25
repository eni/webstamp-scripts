#!/bin/bash
#
# login into webstamp from swisspost v0.1
# 2013-02: initial release
# 2013-05: update login process
# usage:
# ./login [username] [password]
# (c) 2013 by cyrill von wattenwyl
#

if [ -z "$1" ]; then
	#edit value for autologin username
	_USER="hans@test.ch"
else
	_USER=$1
fi;
if [ -z "$2" ]; then
	#edit value for autologin password
	_PASS="password"
else 
	_PASS=$2
fi;


#urlencode function uses perl, not really fast, but works
urlencode(){ echo $1|perl -MURI::Escape -lne 'print uri_escape($_)'; }
WS_USER=`urlencode $_USER`
WS_PASS=`urlencode $_PASS`

#get cookie
echo "1/4"
URL="https://sso.post.ch/webstamp/?login&deviceCategory=DESKTOP&cl=1&login&amp;service=webstamp&amp;lang=DE&amp;fallBackURL=https%3A%2F%2Fws.sso.post.ch%2Fmembers%2F%3F_step%3D19"
curl -S -L -c cc -b cc $URL > /tmp/ws-token00 2>/dev/null

#login step 1
echo "2/4"
DATA="isiwebuserid=$WS_USER&isiwebpasswd=$WS_PASS&submit=Login&checkIsSubmitted=fromFormLogin"
URL="https://sso.post.ch/webstamp/?login&service=webstamp&lang=DE&fallBackURL=https%3A%2F%2Fws.sso.post.ch%2F"
curl -S -L -c cc -b cc -d $DATA $URL > /tmp/ws-token01 2>/dev/null

#extract token data & step2
echo "3/4"
DAT_ALLVALUES=`cat /tmp/ws-token01 | grep value | cut -d"=" -f4 | cut -d'"' -f2`
DAT_SAMLREQUEST=$(urlencode `echo $DAT_ALLVALUES | cut -d" " -f1`)
DAT_RELAYSTATE=$(urlencode `echo $DAT_ALLVALUES | cut -d" " -f2`)
DATA="SAMLRequest=$DAT_SAMLREQUEST&RelayState=$DAT_RELAYSTATE"
URL="https://sso.post.ch/idp/webstamp?login"
curl -S -L -c cc -b cc -d $DATA $URL > /tmp/ws-token02 2>/dev/null

#extract token2 & step3
echo "4/4"
DAT_ALLVALUES=`cat /tmp/ws-token02 | grep value | cut -d"=" -f4 | cut -d'"' -f2`
DAT_SAMLRESPONSE=$(urlencode `echo $DAT_ALLVALUES | cut -d" " -f1`)
DAT_RELAYSTATE=$(urlencode `cat /tmp/ws-token02 | grep RelayState | cut -d'"' -f12`)
DATA="SAMLResponse=$DAT_SAMLRESPONSE&RelayState=$DAT_RELAYSTATE&submit=Continue"
URL=`cat /tmp/ws-token02 | grep action | cut -d'"' -f2`
curl -S -L -c cc -b cc -d $DATA $URL > /dev/null 2>&1

#remove temporary tokens
rm /tmp/ws-token00 /tmp/ws-token01 /tmp/ws-token02
