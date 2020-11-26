@echo off
rem
rem ####################################################################################################################
rem *** Explanation of the the standard script.
rem --------------------------------------------------------------------------------------------------------------------
setlocal
    set F_NAME=%1
    if /i "%F_NAME%"=="" (
       echo "Filename not supplied. && goto :End
    )
    echo "Compiling..."
    call erlc %F_NAME%.erl
    call escript %F_NAME%.beam %2 %3 %4 %5
:End
endlocal
