@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::              GITHUB REPOSITORY SETUP WIZARD
:: ============================================================

title Collaborative Unity Project Repository Setup

set "SCRIPT_DIR=%~dp0"
set "GIT_EXE=git"
set "GH_EXE=gh"

:: ============================================================
:: START
:: ============================================================

:START

cls

echo.
echo  ==================================================
echo             GITHUB REPOSITORY SETUP
echo  ==================================================
echo.
echo  This wizard will:
echo.
echo    [1] Check/install Git
echo    [2] Check/install GitHub CLI
echo    [3] Log into GitHub
echo    [4] Select a project folder
echo    [5] Initialize Git and Git LFS
echo    [6] Setup your git identity using GitHub authentication
echo    [7] Create an initial commit
echo    [8] Create a GitHub repository
echo    [9] Push the project to GitHub
echo.
echo  ==================================================
echo.

pause


:: ============================================================
:: CHECK GIT
:: ============================================================

:CHECK_GIT

cls

echo.
echo  ==================================================
echo              CHECKING REQUIREMENTS
echo  ==================================================
echo.

echo  Checking Git....................

where git >nul 2>&1

if errorlevel 1 (
    echo  Git was not found.
    echo.
    goto INSTALL_GIT
)

for /f "tokens=*" %%G in ('git --version 2^>nul') do (
    echo  %%G
)

echo  Git............................. OK
echo.

goto CHECK_GH


:: ============================================================
:: INSTALL GIT
:: ============================================================

:INSTALL_GIT

echo.
echo  Git is not installed.
echo.
echo  Git for Windows will now be installed.
echo.
echo  Checking for Windows Package Manager...
echo.

where winget >nul 2>&1

if errorlevel 1 (
    echo.
    echo  ERROR: Windows Package Manager ^(winget^) was
    echo  not found on this computer.
    echo.
    echo  Please install Git manually from:
    echo  https://git-scm.com/install/windows
    echo.
    pause
    exit /b 1
)

echo  Installing Git...
echo.

winget install --id Git.Git -e --source winget

if errorlevel 1 (
    echo.
    echo  ERROR: Git installation failed.
    echo.
    pause
    exit /b 1
)

echo.
echo  Git installation complete.
echo.

:: The current CMD process may not have the new PATH yet.
if exist "%ProgramFiles%\Git\cmd\git.exe" (
    set "GIT_EXE=%ProgramFiles%\Git\cmd\git.exe"
)

if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" (
    set "GIT_EXE=%ProgramFiles(x86)%\Git\cmd\git.exe"
)

"%GIT_EXE%" --version

if errorlevel 1 (
    echo.
    echo  ERROR: Git was installed but could not be found.
    echo.
    echo  Please close this window and run the setup again.
    echo.
    pause
    exit /b 1
)

echo.
pause

goto CHECK_GH


:: ============================================================
:: CHECK GITHUB CLI
:: ============================================================

:CHECK_GH

cls

echo.
echo  ==================================================
echo              CHECKING REQUIREMENTS
echo  ==================================================
echo.

echo  Git............................. OK
echo.

echo  Checking GitHub CLI.............

where gh >nul 2>&1

if errorlevel 1 (
    echo  GitHub CLI was not found.
    echo.
    goto INSTALL_GH
)

for /f "tokens=*" %%G in ('gh --version 2^>nul') do (
    echo  %%G
    goto GH_VERSION_DONE
)

:GH_VERSION_DONE

echo  GitHub CLI...................... OK
echo.

goto CHECK_LFS


:: ============================================================
:: INSTALL GITHUB CLI
:: ============================================================

:INSTALL_GH

echo.
echo  GitHub CLI is not installed.
echo.
echo  Checking for Windows Package Manager...
echo.

where winget >nul 2>&1

if errorlevel 1 (
    echo.
    echo  ERROR: Windows Package Manager ^(winget^) was
    echo  not found on this computer.
    echo.
    echo  Please install GitHub CLI manually from:
    echo  https://cli.github.com/
    echo.
    pause
    exit /b 1
)

echo  Installing GitHub CLI...
echo.

winget install --id GitHub.cli -e --source winget

if errorlevel 1 (
    echo.
    echo  ERROR: GitHub CLI installation failed.
    echo.
    pause
    exit /b 1
)

echo.
echo  GitHub CLI installation complete.
echo.

:: The current CMD process may not have the new PATH yet.
if exist "%ProgramFiles%\GitHub CLI\gh.exe" (
    set "GH_EXE=%ProgramFiles%\GitHub CLI\gh.exe"
)

if exist "%ProgramFiles(x86)%\GitHub CLI\gh.exe" (
    set "GH_EXE=%ProgramFiles(x86)%\GitHub CLI\gh.exe"
)

"%GH_EXE%" --version

if errorlevel 1 (
    echo.
    echo  ERROR: GitHub CLI was installed but could not
    echo  be found.
    echo.
    echo  Please close this window and run the setup again.
    echo.
    pause
    exit /b 1
)

echo.
pause

goto CHECK_LFS


:: ============================================================
:: CHECK GIT LFS
:: ============================================================

:CHECK_LFS

cls

echo.
echo  ==================================================
echo              CHECKING REQUIREMENTS
echo  ==================================================
echo.

echo  Git............................. OK
echo  GitHub CLI...................... OK
echo.

echo  Checking Git LFS.................

"%GIT_EXE%" lfs version >nul 2>&1

if errorlevel 1 (
    echo.
    echo  ERROR: Git LFS was not found.
    echo.
    echo  Git for Windows should normally include
    echo  Git LFS.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%L in ('"%GIT_EXE%" lfs version 2^>nul') do (
    echo  %%L
)

echo  Git LFS......................... OK
echo.

goto GITHUB_LOGIN


:: ============================================================
:: GITHUB LOGIN
:: ============================================================

:GITHUB_LOGIN

cls

echo.
echo  ==================================================
echo                   GITHUB LOGIN
echo  ==================================================
echo.

echo  Checking GitHub authentication...
echo.

"%GH_EXE%" auth status --active --hostname github.com >nul 2>&1

if errorlevel 1 (

    echo  You are not currently logged into GitHub.
    echo.
    echo  Your browser will open and GitHub will ask
    echo  you to authorize GitHub CLI.
    echo.
    pause

    "%GH_EXE%" auth login --web --hostname github.com --git-protocol https

    if errorlevel 1 (
        echo.
        echo  ERROR: GitHub authentication failed.
        echo.
        pause
        exit /b 1
    )
)

:: ------------------------------------------------------------
:: Get authenticated GitHub username
:: ------------------------------------------------------------

set "GITHUB_USER="
set "GH_USER_FILE=%TEMP%\github_setup_user_%RANDOM%.tmp"

"%GH_EXE%" api user --jq ".login" > "%GH_USER_FILE%"

if errorlevel 1 (
    echo.
    echo  ERROR: GitHub authentication succeeded, but
    echo  GitHub CLI could not query the account.
    echo.
    echo  GitHub CLI returned:
    echo.
    type "%GH_USER_FILE%"
    echo.
    del "%GH_USER_FILE%" >nul 2>&1
    pause
    exit /b 1
)

set /p "GITHUB_USER="<"%GH_USER_FILE%"

del "%GH_USER_FILE%" >nul 2>&1

if not defined GITHUB_USER (
    echo.
    echo  ERROR: GitHub CLI authenticated successfully,
    echo  but no GitHub username was returned.
    echo.
    pause
    exit /b 1
)

echo.
echo  Logged into GitHub as:
echo.
echo      !GITHUB_USER!
echo.

:: ------------------------------------------------------------
:: Configure GitHub authentication for Git
:: ------------------------------------------------------------

echo  Configuring GitHub authentication for Git...
echo.

"%GH_EXE%" auth setup-git --hostname github.com

if errorlevel 1 (
    echo.
    echo  ERROR: Could not configure Git authentication.
    echo.
    pause
    exit /b 1
)

echo.
echo  GitHub authentication........... OK
echo.

pause

goto SELECT_FOLDER


:: ============================================================
:: SELECT PROJECT FOLDER
:: ============================================================

:SELECT_FOLDER

cls

echo.
echo  ==================================================
echo              SELECT PROJECT FOLDER
echo  ==================================================
echo.
echo  Select the folder to turn into a GitHub
echo  repository:
echo.

set "COUNT=0"

for /d %%D in ("%SCRIPT_DIR%*") do (
    set /a COUNT+=1
    set "FOLDER[!COUNT!]=%%~fD"
    set "FOLDER_NAME[!COUNT!]=%%~nxD"
    echo    [!COUNT!] %%~nxD
)

echo.

if "%COUNT%"=="0" (
    echo  No folders were found next to this script.
    echo.
    echo  Place this .bat file next to your project
    echo  folders and run it again.
    echo.
    pause
    exit /b 1
)

set /p "CHOICE=  Enter selection: "

set "REPO_DIR="
set "REPO_NAME="

:: ============================================================
:: CHECK FOLDER IS NOT EMPTY
:: ============================================================

set "HAS_CONTENT="

for /f "delims=" %%F in ('dir /b /a "!REPO_DIR!" 2^>nul') do (
    set "HAS_CONTENT=1"
    goto FOLDER_NOT_EMPTY
)

:FOLDER_EMPTY

cls

echo.
echo  ==================================================
echo                FOLDER IS EMPTY
echo  ==================================================
echo.
echo  The selected folder contains no files or folders.
echo.
echo      !REPO_DIR!
echo.
echo  Please add your project files to the folder and
echo  run this setup again.
echo.
pause
exit /b 0

:FOLDER_NOT_EMPTY

for /l %%N in (1,1,%COUNT%) do (
    if "%CHOICE%"=="%%N" (
        set "REPO_DIR=!FOLDER[%%N]!"
        set "REPO_NAME=!FOLDER_NAME[%%N]!"
    )
)

if not defined REPO_DIR (
    echo.
    echo  Invalid selection.
    echo.
    pause
    goto SELECT_FOLDER
)

echo.
echo  Selected project:
echo.
echo      !REPO_NAME!
echo      !REPO_DIR!
echo.

pause


:: ============================================================
:: CHECK EXISTING REPOSITORY
:: ============================================================

if exist "!REPO_DIR!\.git" (

    cls

    echo.
    echo  ==================================================
    echo               EXISTING GIT REPOSITORY
    echo  ==================================================
    echo.
    echo  WARNING:
    echo.
    echo  This folder already contains a .git directory.
    echo.
    echo      !REPO_DIR!
    echo.

    choice /C YN /N /M "  Continue anyway? [Y/N] "

    if errorlevel 2 (
        echo.
        echo  Operation cancelled.
        echo.
        pause
        exit /b 0
    )
)


:: ============================================================
:: DETECT UNITY PROJECT
:: ============================================================

set "IS_UNITY=0"

if exist "!REPO_DIR!\Assets" if exist "!REPO_DIR!\ProjectSettings" (
    set "IS_UNITY=1"
)


:: ============================================================
:: REPOSITORY VISIBILITY
:: ============================================================

:VISIBILITY

cls

echo.
echo  ==================================================
echo             REPOSITORY VISIBILITY
echo  ==================================================
echo.
echo  How should the GitHub repository be created?
echo.
echo      [1] Private
echo             Only users that have been granted access can see it
echo             Not searchable on GitHub, permission needed
echo      [2] Public
echo             Anyone can view it
echo             Anyone may download it
echo             Access needs to be granted to upload changes
echo             Searchable on GitHub
echo.
echo  Private is recommended unless you specifically
echo  want the repository to be publicly accessible.
echo.

choice /C 12 /N /M "  Select: "

if errorlevel 2 (
    set "VISIBILITY=public"
) else (
    set "VISIBILITY=private"
)

:: ============================================================
:: HANDLE GIT SAFE DIRECTORY
:: ============================================================

echo  Checking repository ownership.......
echo.

"%GIT_EXE%" config --global --add safe.directory "!REPO_DIR!"

if errorlevel 1 (
    echo.
    echo  ERROR: Could not configure Git safe directory.
    echo.
    pause
    exit /b 1
)

echo  Repository ownership.............. OK
echo.

:: ============================================================
:: INITIALIZE GIT
:: ============================================================

cls

echo.
echo  ==================================================
echo              INITIALIZING PROJECT
echo  ==================================================
echo.
echo  Project:
echo      !REPO_NAME!
echo.
echo  Location:
echo      !REPO_DIR!
echo.

echo  Initializing Git repository......
echo.

"%GIT_EXE%" -C "!REPO_DIR!" init -b main

if errorlevel 1 (
    echo.
    echo  ERROR: Could not initialize Git repository.
    echo.
    pause
    exit /b 1
)

echo  Git repository.................. OK
echo.

:: ============================================================
:: CONFIGURE GIT IDENTITY
:: ============================================================

echo  Checking Git identity...........
echo.

set "GIT_NAME="
set "GIT_EMAIL="

:: Check the effective Git configuration.
for /f "delims=" %%N in (
    '"%GIT_EXE%" config user.name 2^>nul'
) do (
    set "GIT_NAME=%%N"
)

for /f "delims=" %%E in (
    '"%GIT_EXE%" config user.email 2^>nul'
) do (
    set "GIT_EMAIL=%%E"
)

if defined GIT_NAME if defined GIT_EMAIL (

    echo  Existing Git identity found.
    echo.
    echo      Name:  !GIT_NAME!
    echo      Email: !GIT_EMAIL!
    echo.

    goto IDENTITY_DONE
)

echo  Git identity is incomplete.
echo  Getting identity from GitHub...
echo.

:: ------------------------------------------------------------
:: Get GitHub email
:: ------------------------------------------------------------

set "GITHUB_EMAIL="

for /f "delims=" %%E in (
    '"%GH_EXE%" api user --jq ".email // empty" 2^>nul'
) do (
    set "GITHUB_EMAIL=%%E"
)

:: If the public email is hidden, look for the primary
:: verified email associated with the authenticated account.

if not defined GITHUB_EMAIL (

    for /f "delims=" %%E in (
        '"%GH_EXE%" api user/emails --jq ".[] ^| select(.verified == true) ^| select(.primary == true) ^| .email" 2^>nul'
    ) do (
        set "GITHUB_EMAIL=%%E"
    )
)

:: Final fallback.
if not defined GITHUB_EMAIL (
    set "GITHUB_EMAIL=!GITHUB_USER!@users.noreply.github.com"
)

if not defined GIT_NAME (
    set "GIT_NAME=!GITHUB_USER!"
)

if not defined GIT_EMAIL (
    set "GIT_EMAIL=!GITHUB_EMAIL!"
)

:: Configure identity locally for THIS repository only.
"%GIT_EXE%" -C "!REPO_DIR!" config user.name "!GIT_NAME!"
"%GIT_EXE%" -C "!REPO_DIR!" config user.email "!GIT_EMAIL!"

if errorlevel 1 (
    echo.
    echo  ERROR: Could not configure Git identity.
    echo.
    pause
    exit /b 1
)

echo.
echo  Git identity configured:
echo.
echo      Name:  !GIT_NAME!
echo      Email: !GIT_EMAIL!
echo.

:IDENTITY_DONE

echo  Git identity................... OK
echo.


:: ============================================================
:: CREATE UNITY GITIGNORE
:: ============================================================

if "!IS_UNITY!"=="1" (

    echo  Unity project detected.
    echo  Creating Unity .gitignore........
    echo.

    (
        echo # Unity
        echo [Ll]ibrary/
        echo [Tt]emp/
        echo [Oo]bj/
        echo [Bb]uild/
        echo [Bb]uilds/
        echo [Ll]ogs/
        echo [Uu]ser[Ss]ettings/
        echo [Mm]emoryCaptures/
        echo [Rr]ecordings/
        echo.
        echo # Asset Store Tools
        echo [Aa]sset[Ss]tore[Tt]ools*
        echo.
        echo # Visual Studio
        echo .vs/
        echo.
        echo # Rider
        echo .idea/
        echo.
        echo # Generated project files
        echo *.csproj
        echo *.unityproj
        echo *.sln
        echo *.suo
        echo *.user
        echo *.userprefs
        echo *.pidb
        echo *.booproj
        echo.
        echo # OS files
        echo .DS_Store
        echo Thumbs.db
    ) > "!REPO_DIR!\.gitignore"

    echo  Unity .gitignore................ OK
    echo.
)

:: ============================================================
:: INITIALIZE GIT LFS
:: ============================================================

echo  Initializing Git LFS.............
echo.

"%GIT_EXE%" lfs install

if errorlevel 1 (
    echo.
    echo  ERROR: Git LFS initialization failed.
    echo.
    pause
    exit /b 1
)

echo  Git LFS initialized.
echo  Git LFS......................... OK
echo.

:: ============================================================
:: CONFIGURE GIT LFS TRACKING
:: ============================================================

echo  Configuring Git LFS patterns....
echo.

pushd "!REPO_DIR!"

echo  Tracking PSD files...
"%GIT_EXE%" lfs track "*.psd"

if errorlevel 1 (
    echo.
    echo  ERROR: Failed to configure PSD files for Git LFS.
    echo.
    popd
    pause
    exit /b 1
)

echo  Tracking PSB files...
"%GIT_EXE%" lfs track "*.psb"

if errorlevel 1 (
    echo.
    echo  ERROR: Failed to configure PSB files for Git LFS.
    echo.
    popd
    pause
    exit /b 1
)

echo  Tracking FBX files...
"%GIT_EXE%" lfs track "*.fbx"

if errorlevel 1 (
    echo.
    echo  ERROR: Failed to configure FBX files for Git LFS.
    echo.
    popd
    pause
    exit /b 1
)

echo  Tracking Blender files...
"%GIT_EXE%" lfs track "*.blend"

if errorlevel 1 (
    echo.
    echo  ERROR: Failed to configure Blender files for Git LFS.
    echo.
    popd
    pause
    exit /b 1
)

popd

if not exist "!REPO_DIR!\.gitattributes" (
    echo.
    echo  ERROR: Git LFS did not create .gitattributes.
    echo.
    echo  Git LFS tracking could not be configured.
    echo.
    pause
    exit /b 1
)

echo  Git LFS patterns................ OK
echo.

:: ============================================================
:: STAGE FILES
:: ============================================================

echo  Staging files...................
echo.

"%GIT_EXE%" -C "!REPO_DIR!" add .

if errorlevel 1 (
    echo.
    echo  ERROR: Could not stage files.
    echo.
    pause
    exit /b 1
)

echo  Files staged.................... OK
echo.


:: ============================================================
:: INITIAL COMMIT
:: ============================================================

echo  Creating initial commit.........
echo.

"%GIT_EXE%" -C "!REPO_DIR!" commit -m "Initial commit"

if errorlevel 1 (
    echo.
    echo  ERROR: Initial commit failed.
    echo.
    echo  Check the Git identity and project contents.
    echo.
    pause
    exit /b 1
)

echo.
echo  Initial commit.................. OK
echo.

:: ============================================================
:: CREATE GITHUB REPOSITORY + PUSH
:: ============================================================

cls

echo.
echo  ==================================================
echo              CREATING GITHUB REPOSITORY
echo  ==================================================
echo.
echo  GitHub account:
echo      !GITHUB_USER!
echo.
echo  Repository:
echo      !REPO_NAME!
echo.
echo  Visibility:
echo      !VISIBILITY!
echo.
echo  The repository will now be created on GitHub
echo  and the initial commit will be pushed.
echo.

pause

"%GH_EXE%" repo create "!REPO_NAME!" --source "!REPO_DIR!" --remote origin --!VISIBILITY! --push

if errorlevel 1 (
    echo.
    echo  ==================================================
    echo                    SETUP FAILED
    echo  ==================================================
    echo.
    echo  The GitHub repository could not be created
    echo  or the initial push failed.
    echo.
    echo  Your local Git repository is still intact:
    echo.
    echo      !REPO_DIR!
    echo.
    echo  You can retry the GitHub portion manually.
    echo.
    pause
    exit /b 1
)


:: ============================================================
:: SUCCESS
:: ============================================================

cls

echo.
echo  ==================================================
echo                    SETUP COMPLETE!
echo  ==================================================
echo.
echo  GitHub account:
echo      !GITHUB_USER!
echo.
echo  Repository:
echo      !REPO_NAME!
echo.
echo  Location:
echo      !REPO_DIR!
echo.
echo  Git............................. OK
echo  Git LFS......................... OK
echo  GitHub authentication........... OK
echo  Git identity.................... OK
echo  Initial commit.................. OK
echo  GitHub repository............... OK
echo  Initial push.................... OK
echo.
echo  ==================================================
echo.
echo  Your project is now on GitHub.
echo.
echo  Opening the repository...
echo.

set "URL_REPO_NAME=!REPO_NAME: =-!"
start "" "https://github.com/!GITHUB_USER!/!URL_REPO_NAME!"

echo.
echo  ==================================================
echo.

pause

endlocal
exit /b 0