Open Command prompt as administrator.
CD to this directory
execute register32.cmd on 32 bit windows and register64.cmd on 64 bit windows.
message boxes will appear, just dismiss them. If they all state some kind of error you are probably running the wrong cmd file - try the other one.


The COM DLL needed by the server side ASP Classic code.
Note that HTMLParser.DLL and SQLITECOMUTF8.DLL are provided mostly "just in case" for
impor/export of old data formats and some rarely needed tasks.

NWIndexerSvc.dll is a simple scripting interface to the IFilter COM interface which is provided
by various IFilter DLL for various file formats. The Windows registration  includes mime type and
file extensions mapping, but there is no guarantee which filters will be installed on a particular 
system and one may need to collect them or install the software that registers them as part of its
installation process (some may refer to a number of other DLL).

ALL DLL are 32 bit and on 64bit systems should be registered with the regsvr32 from the 
%WINDIR%\SysWOW64 folder! The registration will fail with the 64bit one.