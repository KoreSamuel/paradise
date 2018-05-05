#!/bin/bash
set -ev

git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master

cd ../
mv .deploy_git/.git/ ./public/

cd ./public

git config user.name "swust-xiaoj"  #修改name
git config user.email "swustxiaojie@163.com"  #修改email
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"

git push --force --quiet "https://${travis}@${GH_REF}" master:master  #travis是在Travis中配置token的名称