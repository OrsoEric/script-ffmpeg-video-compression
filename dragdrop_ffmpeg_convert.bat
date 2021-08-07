rem 2021-02-26 moved from VLC to ffmpeg h265
rem 2021-04-14 added conversion mp4->mp4 h264. added check destination file exist

@echo off
setlocal ENABLEDELAYEDEXPANSION
rem Take the cmd-line, remove all until the first parameter
set "params=!cmdcmdline:~0,-1!"
set "params=!params:*" =!"
set count=0

rem Split the parameters on spaces but respect the quotes
for %%G IN (!params!) do (
  set /a count+=1
  set "extension_!count!=%%~xG"
  set "source_!count!=%%~G"
  set "dest_!count!=%%~dpG%%~nG.mp4"
  set "dest_mp4_!count!=%%~dpG%%~nG _compressed.mp4" 
  rem echo !count! %%~G
)
D:
rem compute path to ffmpeg. ffmpeg.exe is supposed to be on the same folder as the bat file
set ffmpeg_path=!%~dp0!ffmpeg.exe
echo "!ffmpeg_path!"
rem list the parameters
for /L %%n in (1,1,!count!) DO (
	echo "!extension_%%n!"
	echo "!source_%%n!"
	echo "!dest_%%n!"
	echo "!dest_mp4_%%n!"
	if /i "!extension_%%n!"==".avi" (
		REM Convert video
		REM START /WAIT !ffmpeg_path! -i "!source_%%n!" -c:v libx265 -preset ultrafast -vf format=yuv420p "!dest_%%n!"
		ECHO /WAIT !ffmpeg_path! -i "!source_%%n!" -c:v libx264 -preset slow -vf format=yuv420p "!dest_%%n!"
		START /WAIT !ffmpeg_path! -i "!source_%%n!" -c:v libx264 -preset slow -vf format=yuv420p "!dest_%%n!"
		REM if destination exists
		iF EXIST "!dest_mp4_%%n!" (
			REM delete source file without asking for confirmation
			del "!source_%%n!" /Q
		) else (
			ECHO FAILED
		)
	) else (
		if /i "!extension_%%n!"==".mp4" (
			REM Convert video
			ECHO /WAIT !ffmpeg_path! -i "!source_%%n!" -c:v libx264 -preset slow -vf format=yuv420p "!dest_mp4_%%n!"
			START /WAIT !ffmpeg_path! -i "!source_%%n!" -c:v libx264 -preset slow -vf format=yuv420p "!dest_mp4_%%n!"
			REM if destination exists
			iF EXIST "!dest_mp4_%%n!" (
				REM delete source file without asking for confirmation
				del "!source_%%n!" /Q
			) else (
				ECHO FAILED
			)
		) else (
			echo NO
		)
	)
)
pause

REM ** The exit is important, so the cmd.ex doesn't try to execute commands after ampersands
exit
