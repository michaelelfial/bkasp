echo %1
set rsvr=%windir%\SysWOW64\regsvr32.exe
%rsvr% newobjectspack1.dll
%rsvr% nwwebimage.dll
%rsvr% SQLITE3COMUTF8.dll
%rsvr% SQLITECOMUTF8.dll
%rsvr% HashCryptStreams.dll
%rsvr% HTMLParser.dll
%rsvr% NETStreams.dll
%rsvr% NWIndexerSvc.dll
%rsvr% nwtlbinterface.dll
pause