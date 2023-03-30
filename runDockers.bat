for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set TODAY=%dt:~6,2%
set CPU=%NUMBER_OF_PROCESSORS%
if %CPU% LSS 4 (
	set CPU_CORE=1
) ELSE (
	set /a CPU_CORE=%CPU%-2
)

docker-compose up --build