:: APEX Install Build
::-----------------------------
:: %1 = Build zip file
:: %2 = APEX App Id
:: %3 = Workspace name
:: %4 = DB connection string
:: %5 = New App Alias (optional)    
::-----------------------------
:: Recreate the temporary stage directory and change directory to it
@echo off
if exist %TEMP%\stage_f%2 rmdir /s /q %TEMP%\stage_f%2
mkdir %TEMP%\stage_f%2
copy %1 %TEMP%\stage_f%2
pushd %TEMP%\stage_f%2
jar xvf %1
:: Change directory to the root directory of the expanded archive
set "firstdir="
for /f "delims=" %%d in ('dir /b/ad/on *') do if not defined firstdir set "firstdir=%%d"
cd "%firstdir%"
:: Install APEX application and apply database schema object changes
(
echo connect %4
echo declare
echo     l_workspace apex_workspaces.workspace%%type := q'[%3]';
echo     l_app_id apex_applications.application_id%%type := q'[%2]';
echo     l_connection varchar2(4000^^^) := q'[%4]';
echo     l_schema apex_workspace_schemas.schema%%type := upper(regexp_substr(l_connection,'[^^^^\/]+'^^^)^^^);
echo     l_app_alias apex_applications.alias%%type := q'[%5]';
echo begin
echo     apex_application_install.set_workspace(l_workspace^^^);
echo     apex_application_install.set_application_id(l_app_id^^^);
echo     apex_application_install.set_auto_install_sup_obj( 
echo                                p_auto_install_sup_obj => true );
echo     if l_app_alias is not null then
echo         apex_application_install.generate_offset(^^^);
echo         apex_application_install.set_schema(l_schema^^^);
echo         apex_application_install.set_application_alias(l_app_alias^^^);
echo     end if;
echo end;
echo /
echo @install.sql
) | sql /nolog
popd
