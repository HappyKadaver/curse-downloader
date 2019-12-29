# Curse downloader
This is a ruby script that uses capybara to download minecraft modpacks from curseforge.
Since the twitch launcher doesn't work on linux and curseforge added cloudflare filtering...
I have created a script that will control a chrome instance with capybara and webdriver to visit every download page and download the mods of a given modpack...
This isn't the fastest solution by far but it allows linux users to actually play modpacks that were created for the twitch launcher.

# setup
1. install ruby if you haven't already
2. clone this repository
3. run bundle install

# usage
1. download the zip file of the modpack
2. unpack the zip
3. run `./main.rb <path/to/the/manifest.json>`
4. wait
5. your mods are in the mods directory
6. move the mods and the overrides directory to your minecraft installation and override every confilict
7. have fun