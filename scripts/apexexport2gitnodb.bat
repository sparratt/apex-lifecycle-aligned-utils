:: APEX Export to Git
::-----------------------------
:: %1 = APEX App Id
:: %2 = Git workarea directory
:: %3 = DB connection string
::-----------------------------
:: Recreate the temporary stage directory and change directory to it
@echo off
if exist %TEMP%\stage_f%1 rmdir /s /q %TEMP%\stage_f%1
mkdir %TEMP%\stage_f%1
cd %TEMP%\stage_f%1
:: Export APEX application and schema to stage directory
(
echo connect %3
echo apex export -applicationid %1 -split -skipExportDate -expOriginalIds -expSupportingObjects Y -expType APPLICATION_SOURCE,READABLE_YAML
) | sql /nolog
:: Copy APEX application export files in the ./fNNN subdirectory to Git Working Area directory
robocopy %TEMP%\stage_f%1\f%1 %2 * /mir /xd ".git"
:: Remove APEX export files, leaving only Liquibase DB export artifacts
rmdir /s /q %TEMP%\stage_f%1\f%1
:: Copy the Liquibase DB export artifacts to ./database subdir of Git Working Area
if not exist %2\database mkdir %2\database
robocopy %TEMP%\stage_f%1 %2\database * /mir /xd ".git"
:: Change directory to the Git Workarea 
cd %2
:: Add all changed files to the Git worklist from any subdirectory
git add .
