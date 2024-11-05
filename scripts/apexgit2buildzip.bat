:: APEX Create Build Zip from Git Workarea
::----------------------------------------
:: %1 = Git workarea for APEX App
::-----------------------------
@echo off
set curDir=%cd%
pushd %1 > NUL
for %%f in ("%cd%") do set dirToZip=%%~nxf
cd ..
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined curDate set curDate=%%x
jar cvfM  %curDir%/%dirToZip%_%curDate:~2,10%.zip ^
          %dirToZip%/install.sql ^
          %dirToZip%/application ^
          %dirToZip%/database ^
          %dirToZip%/workspace    
popd > NUL
