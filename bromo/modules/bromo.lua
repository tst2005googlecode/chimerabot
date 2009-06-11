--[[------------------------------------------------------------
Bromo module 
NewbLuck - Started 5/6/2009 11:47:38 AM

]]--------------------------------------------------------------

--Namespace
require_mod("corefunc")


allocate_namespace("bm")
bm  = {}

function bm.runbmbot(bmess)
		
	os.execute("bromobot " .. bmess)
	
end


--add_hook("parse_chat","ai_learn",ai.learn)
--hook in learn function to parsechat
--hook in line spitout to cycle w/ timer
push_reaction("bromote",true,0,true,"function",bm.runbmbot)
