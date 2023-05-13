forfiles /p "F:\Monitor File" /d -120 /s /m *.* /c "cmd /c del /f /q @path"
forfiles /p "G:\Monitor File" /d -150 /s /m *.* /c "cmd /c del /f /q @path"