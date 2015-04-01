#!/bin/bash

ipa build -c Release
scp -i /Users/s-takai/.ssh/webdesign_ec2.pem SMBFileReader.ipa root@dev.mobile-kaigi2.com:/var/www/html/client/webdesign
