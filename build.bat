@echo off
echo ====================================================
echo      Building FitnessScript Interpreter (.fit)
echo ====================================================

bin\win_bison.exe -d fitness.y
bin\win_flex.exe fitness.l

if not exist lex.yy.c (
    echo [ERROR] Flex generation failed! lex.yy.c not found.
    pause
    exit /b 1
)

if not exist fitness.tab.c (
    echo [ERROR] Bison generation failed! fitness.tab.c not found.
    pause
    exit /b 1
)

echo Compiling C code...
bin\tcc\tcc\tcc.exe lex.yy.c fitness.tab.c -o fitness.exe

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Build successful! Created fitness.exe
    echo.
    echo Running sample.fit...
    echo ----------------------------------------------------
    fitness.exe sample.fit
    echo ----------------------------------------------------
    echo.
    echo Running error_sample.fit...
    echo ----------------------------------------------------
    fitness.exe error_sample.fit
    echo ----------------------------------------------------
) else (
    echo [ERROR] Compilation failed!
)

pause
