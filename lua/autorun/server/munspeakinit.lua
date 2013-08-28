-- Client files to send
AddCSLuaFile( "autorun/client/cl_munspeak.lua" )
AddCSLuaFile( "munspeakclient/cl_munspeakclient.lua" )

MunSpeak = {}

include("munspeakserver/munspeakmain.lua")
print("@@@@@@@@@@ The MUNSPEAK SERVER INIT RAM @@@@@@@@@@")