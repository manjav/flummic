CD /d data/
FOR %%I in (*.*) DO ..\7za.exe a "%%I.zip" "%%I"
