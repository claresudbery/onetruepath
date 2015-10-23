@ECHO off

SetLocal

SET action=%1
SET mode=%2

IF NOT DEFINED action (
	SET ACTION=tests
)

IF NOT DEFINED mode (
	SET MODE=debug
)

@powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\build-scripts\__build.ps1' -mode %MODE% -action %ACTION%; exit $LASTEXITCODE"

EndLocal