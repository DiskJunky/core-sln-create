@echo off


REM --------------------------------
REM Project initiation...
REM --------------------------------

REM make sure we have something to work with
set currdir=

REM default to the name of the working dir if no argument was supplied
if [%1]==[] for %%I in (.) do set currdir=%%~nxI
if NOT [%1]==[] call :createsolutionfolder %1 



REM basic solution initialization...
call :createsolutionroot


REM app specific setup...
call :createproject App console
call :createproject Library classlib


REM general purpose testing framework...
call :createtests


echo.
echo Done.
echo.
goto successful_exit



REM --------------------------------
REM Subroutines...
REM --------------------------------
:createsolutionroot
REM create the route solution and solution files...
echo Creating solution [%currdir%]...
if exist %currdir%.sln echo Solution file [%currdir%] already exists...
if not exist %currdir%.sln dotnet new sln

call :createifnotexists nuget.config nugetconfig
call :createifnotexists global.json globaljson
exit /b


:createtests
REM Standard test setup...
call :createproject Tests.UnitTests nunit
call :createproject Tests.IntegrationTests nunit
call :createproject Tests.Builders classlib
call :createproject Tests.Mocks classlib
exit /b


:createsolutionfolder
REM use the project name supplied and create a folder with that name
set currdir=%1

if not exist %currdir% mkdir %currdir%
if errorlevel 1 (
    echo There was a problem trying to create a subfolder called [%currdir%]
    goto exit
)
cd %currdir%
exit /b


:createifnotexists
REM Call "dotnet new (%2)" if the the file specified in (%1) doesn't exist
echo debug: argument passed; %1
if exist %1 echo File [%1] already exists...
if not exist %1 dotnet new %2
exit /b


:createproject
REM Create a project (%1) folder and project file within it of the specified type (%2)
set project=%currdir%.%1

if exist %project% echo Project folder [%project%] already exists...
if not exist %project% mkdir %project%

cd %project%
call :createifnotexists %project%.csproj %2
cd..

dotnet sln add %project%\%project%.csproj
exit /b



REM --------------------------------
REM Exit gotos...
REM --------------------------------

:successful_exit
echo Solution [%currdir%] created successfully.

:exit
echo.
