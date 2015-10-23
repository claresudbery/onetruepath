@ECHO off

SetLocal

SET action=%1
SET mode=%2
SET serverGroup=%3

IF NOT DEFINED action (
	SET ACTION=build
)

IF NOT DEFINED mode (
	SET MODE=debug
)

IF NOT DEFINED serverGroup (
	SET SERVERGROUP=debug
)

@powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\build-scripts\__build.ps1' -mode %MODE% -action %ACTION% -serverGroup %SERVERGROUP%; exit $LASTEXITCODE"

EndLocal