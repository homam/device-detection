#cp -rf . ../device-detection-build/
rsync -av --exclude=".*" . ../device-detection-build/
cd ../device-detection-build
rm -rf d3-template/.git
rm -f .gitmodules
# do not copy .git directory in the first place
#rm -rf .git/

git add .
git commit -am "heroku build"
git push -u heroku master