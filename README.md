# Automatic Collaborative Worlds Setup - ACWS
Modern problems require 20 year old-programming-language solutions (screw batch scripts)

# What this is
A custom installer that installs all you need to upload your Unity project to GitHub
Once your set up is correct, it will let you select a project to upload and completely set it up and upload it to GitHub, opening the resulting repository

# How to use
- Place "Collaborative Worlds Setup.bat" in the same folder that contains your Unity Project's folder 
- Run it

It will help you through all the requirements of getting your project to GitHub safely

>[!warning]
> Do not place it **inside** the Unity Project's folder, it has to be right outside it, if you are able to select or even see the Assets folder, you're in the wrong folder

# ".bat files are scary!"
Agreed, so, full disclosure on what the script does:
- The script only works within the same folder it is placed at, it doesn't do anything outside that
- It does not delete anything
- The script can alter git and git-cli configs to help you get the correct setup for this
