cp -rf . ../device-detection-build/
cd ../device-detection-build
rm -rf d3-template/.git
rm -f .gitmodules
rm -rf .git/
git add .
git commit -am "heroku build"
git push -u heroku master