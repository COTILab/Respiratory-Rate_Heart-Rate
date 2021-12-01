@echo off
IF "%1"=="x64" (
	xcopy /D /S /F /Y "%OPENNI2_REDIST64%\*" "Bin\x64-Release\"
) ELSE (
	xcopy /D /S /F /Y "%OPENNI2_REDIST%\*" "Bin\Win32-Release\"
)
@"%0\..\BuildJavaWindows.py" "%1" "%0\..\Bin" "%0\..\src\org\openni\Samples\SimpleViewer" org.openni.Samples.SimpleViewer org.openni.jar org.openni.Samples.SimpleViewer.SimpleViewerApplication
