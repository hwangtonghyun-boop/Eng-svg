@echo off
chcp 65001 >nul
setlocal

rem ============================================================
rem  claude-free.bat
rem  Claude 한도가 찼을 때 OmniRoute(무료 모델)로 Claude Code 실행
rem  - 이 파일을 작업할 프로젝트 폴더에 넣고 더블클릭하세요.
rem  - OmniRoute 키는 파일에 저장하지 않고 실행할 때마다 입력받습니다.
rem ============================================================

set "OMNI=http://127.0.0.1:20128"
cd /d "%~dp0"

echo.
echo [1/3] OmniRoute 서버 확인 중... (%OMNI%)
call :probe
if not "%CODE%"=="000" goto ask_key

echo.
echo  OmniRoute 서버가 꺼져 있습니다.
choice /c YN /m " 새 창에서 서버를 켤까요"
if errorlevel 2 goto end
start "OmniRoute server (do not close)" cmd /k "set OMNIROUTE_SERVER_HOST=127.0.0.1&& omniroute serve"
echo  서버 시작을 기다리는 중... (최대 60초)
set /a TRIES=0

:wait_server
timeout /t 2 /nobreak >nul
call :probe
if not "%CODE%"=="000" goto server_up
set /a TRIES+=1
if %TRIES% lss 30 goto wait_server
echo.
echo  [오류] 서버가 켜지지 않았습니다. 서버 창의 메시지를 확인하세요.
goto end

:server_up
echo  서버가 켜졌습니다.

:ask_key
echo.
echo [2/3] OmniRoute 키 입력
echo  (대시보드 Endpoints / API Manager 에서 만든 키. Gemini 키가 아닙니다)
set "ANTHROPIC_AUTH_TOKEN="
set /p "ANTHROPIC_AUTH_TOKEN= OmniRoute 키: "
if not defined ANTHROPIC_AUTH_TOKEN set "ANTHROPIC_AUTH_TOKEN=none"
call :probe "%ANTHROPIC_AUTH_TOKEN%"
if "%CODE%"=="200" goto run
if "%CODE%"=="401" goto bad_key
if "%CODE%"=="403" goto bad_key
echo  [경고] 서버 응답 코드 %CODE% - 그래도 실행해 봅니다.
goto run

:bad_key
echo  [오류] 키가 맞지 않습니다. 다시 입력하세요.
goto ask_key

:run
set "ANTHROPIC_BASE_URL=%OMNI%"
set "ANTHROPIC_MODEL=auto"
echo.
echo [3/3] Claude Code 실행 (무료 모델, 폴더: %CD%)
echo   1. 직전 대화 이어서 (claude --continue)
echo   2. 새 대화 시작 (claude)
choice /c 12 /m " 선택"
if errorlevel 2 goto run_new
claude --continue
goto end

:run_new
claude
goto end

rem ---- 서버 응답 코드 확인 (000 = 연결 안 됨) ----
:probe
set "CODE=000"
if "%~1"=="" (
  for /f %%c in ('curl -s -o nul -w "%%{http_code}" --max-time 3 %OMNI%/v1/models 2^>nul') do set "CODE=%%c"
) else (
  for /f %%c in ('curl -s -o nul -w "%%{http_code}" --max-time 3 -H "Authorization: Bearer %~1" %OMNI%/v1/models 2^>nul') do set "CODE=%%c"
)
exit /b

:end
echo.
pause
endlocal
