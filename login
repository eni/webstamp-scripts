#!/bin/bash
#
# login into webstamp from swisspost v0.1
# 2013-02: initial release
# 2013-05: update login process
# 2014-08: update login process again

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

USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36"


#urlencode function uses perl, not really fast, but works
urlencode(){ echo $1|perl -MURI::Escape -lne 'print uri_escape($_)'; }
WS_USER=`urlencode $_USER`
WS_PASS=`urlencode $_PASS`


#get cookie
echo "1/5"
URL="https://sso.post.ch/webstamp/?login&amp;deviceCategory=DESKTOP&amp;cl=2&amp;login&amp;lang=DE&amp;fallBackURL=https%3A%2F%2Fws.sso.post.ch%2F"
curl -S -L -A "$USER_AGENT" -c cc -b cc $URL > /tmp/ws-token00 2>/dev/null

#login step 1
echo "2/5"
DATA="isiwebuserid=$WS_USER&isiwebpasswd=$WS_PASS&submit=Login&checkIsSubmitted=fromFormLogin"
URL="https://sso.post.ch/webstamp/?login&deviceCategory=DESKTOP"
curl -S -L -A "$USER_AGENT" -c cc -b cc -d $DATA $URL > /tmp/ws-token01 2>/dev/null

#extract token data & step2
echo "3/5"
DAT_SAMLREQUEST=$(urlencode $(cat /tmp/ws-token01 | grep value | grep SAMLRequest | cut -d'"' -f6))
DAT_RELAYSTATE=$(urlencode "https://ws.sso.post.ch/sso/login/")
DATA="SAMLRequest=$DAT_SAMLREQUEST&RelayState=$DAT_RELAYSTATE&submit=Submit"
URL="https://sso.post.ch/idp/webstamp?login"
curl -S -L -A "$USER_AGENT" -c cc -b cc -d $DATA $URL > /tmp/ws-token02 2>/dev/null

#extract token2 & step3
echo "4/5"
DAT_SAMLRESPONSE=$(urlencode $(cat /tmp/ws-token02 | grep SAMLResponse | cut -d'"' -f6))
DAT_RELAYSTATE=$(urlencode `cat /tmp/ws-token02 | grep RelayState | cut -d'"' -f6`)
DATA="SAMLResponse=$DAT_SAMLRESPONSE&RelayState=$DAT_RELAYSTATE&submit=Continue"
URL="https://sso.post.ch/idp/webstamp?login"
curl -S -L  -A "$USER_AGENT" -c cc -b cc -d $DATA $URL > /tmp/ws-token03 2>/dev/null

echo "5/5"
DAT_SAMLRESPONSE=$(urlencode $(cat /tmp/ws-token02 | grep SAMLResponse | cut -d'"' -f6))
DAT_RELAYSTATE=$(urlencode `cat /tmp/ws-token02 | grep RelayState | cut -d'"' -f6`)
DATA="SAMLResponse=$DAT_SAMLRESPONSE&RelayState=$DAT_RELAYSTATE&submit=Continue"
URL="https://ws.sso.post.ch/module.php/saml/sp/saml2-acs.php/default-sp"
curl -S -L  -A "$USER_AGENT" -c cc -b cc -d $DATA $URL > /dev/null 2>/dev/null



#remove temporary tokens
rm /tmp/ws-token00 /tmp/ws-token01 /tmp/ws-token02 /tmp/ws-token03
