# Script to reset local git repo as I am editing in test env. 
#   This will abandon local changes from my scratch directory and 
#   put a new version from github
# dan@dsblue.net  
#
# jq = JSON parser / wget = web file getter 

git fetch 
git reset --hard HEAD
git merge '@{u}'
