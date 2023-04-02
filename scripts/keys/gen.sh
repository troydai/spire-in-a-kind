#!/bin/sh

WORKDIR=`dirname $0`
DATADIR=".data"
ROOTKEY="$DATADIR/root.key.pem"
ROOTCRT="$DATADIR/root.crt.pem"

cd $WORKDIR

echo "Generating keys and certificates"
echo "Working directory `PWD`"

rm -rf $DATADIR && mkdir -p $DATADIR
echo "Keys and certificates are generated on `date`" > $DATADIR/README.md

# Root CA private key
echo "Creating $ROOTKEY ..."
openssl ecparam -out $ROOTKEY -name secp521r1 -genkey -noout

# Root CA self-signed certificate
echo "Creating $ROOTCRT ..."
openssl req -x509 -sha256 -new -nodes -key $ROOTKEY -days 3650 -out $ROOTCRT \
	-subj '/CN=spire-in-a-box.troydai.cc/C=US/ST=WA/L=Redmond/O=TDFUND'
