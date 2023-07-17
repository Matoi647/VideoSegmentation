@echo off
setlocal enabledelayedexpansion

set ffmpeg_path=ffmpeg.exe
set ffprobe_path=ffprobe.exe
set input_file=%~1
REM 起始时间
set /a start_time=0
REM 结束时间
set /a end_time=2
REM 每段视频时长（秒）
set /a segment_length=2
REM 视频总时长
set /a video_length=0

REM 提取文件名和扩展名
for %%A in ("%input_file%") do (
    set file_name=%%~nA
    set file_ext=%%~xA
)

REM 创建输出目录
set output_folder=%~dp0\%file_name%
mkdir "%output_folder%" 2>nul

REM 调用ffprobe获取视频时长
for /f "delims=" %%a in ('%ffprobe_path% -v error -select_streams v:0 -show_entries stream^=duration -of default^=noprint_wrappers^=1:nokey^=1 -i "%input_file%"') do (
    set video_length_float=%%a
    REM 将浮点数转为整数
    set /a video_length=!video_length_float!
)

REM 计算分段数
set /a seg_num=%video_length%/%segment_length%
set /a rest=%video_length%%%%segment_length%
if %rest% neq 0 (
    set /a seg_num=%seg_num%+1
)

echo video_length=%video_length%, seg_num=%seg_num%

REM 调用ffmpeg分割视频
for /l %%i in (1, 1, %seg_num%) do (
    echo start time=!start_time!, end time=!end_time!
    ffmpeg -i "%input_file%" -ss !start_time! -to !end_time! "%output_folder%\%file_name%_part_%%i%file_ext%"
    set /a start_time=!start_time!+%segment_length%
    set /a end_time=!end_time!+%segment_length%
)

echo finished
pause