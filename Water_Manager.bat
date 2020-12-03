@echo off
rem
rem ####################################################################################################################
rem *** Water_Manager erlang project
rem --------------------------------------------------------------------------------------------------------------------
setlocal
    set F_NAME=water_manager
    set COMPILE=
    if /i "%1"=="--compile" (
       set COMPILE=S
    )
    if "%COMPILE%"=="S" (
       echo Compiling %F_NAME%...
       call erlc %F_NAME%.erl
       echo Done! Running:
       shift
    )
    call escript %F_NAME%.beam %1 %2 %3 %4 %5
:End
endlocal
