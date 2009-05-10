--[[------------------------------------------------------------
Lexical module 
NewbLuck - Started 5/6/2009 11:47:38 AM

Somewhat ai-ish lexical parser and constructor.
It turns out this is somewhat of a Zipf approach.

To add:
	* Terminator frequencies
	* Topic detection and word association
	  +--Inside-out line construction
]]--------------------------------------------------------------

--Namespace
require_mod("corefunc")


allocate_namespace("ai")
ai  = {}


--Primary word assc. cloud.
--ai.cloud = nil
ai.cloud = {}

--[[
	Structure

	ai.cloud["word"].usage = usage count
	ai.cloud["word"].to = {} 
	ai.cloud["word"].to["target"] = #hits
	
	eventually add a from structure if needed for building form endpoints etc
]]--

--Holds our frequencies for opening words.
--ai.openers = nil
ai.openers = {}
--Holds our "no-no" words.
ai.badlist = {}
--Holds our bad triplets.
ai.triplets = {}
--Holds our valid one and two letter words.
ai.smallwords = {}

ai.smallfile = "modules/small_words.txt"
ai.tripfile = "modules/bad_triplets.txt"
ai.badfile = "modules/bad_words.txt"



--Validates a given word based on valid letter triplet checking.
function ai.validate(word)

	if #word < 3 then 
		local match = false

		for i,v in ipairs(ai.smallwords) do
			if v == word then match = true end
		end
		
		if match == false then return "###" end

	else
		
		local i = #word - 2

		for x = 1,i,1 do
			local chunk = string.sub(word,x,x+2)
			for i,v in ipairs(ai.triplets) do
				if chunk == v then return "###" end
			end
		end
	end	

	return word	

end

--Rejects words that are in a "no-no" list.
function ai.badword(word)
	for i,v in ipairs(ai.badlist) do
		if v == word then return "###" end
	end

	return word
end

--Chops a line up
function ai.tableize(line)
	
	if #line < 1 then print("ofuck"); return nil, "Err[ai.tableize]: Line empty" end
	--builds numerical indexed table containing words
	--im pretty sure we can use core.lop here
	local chunk = ""
	local outtable = {}	

	while(line ~= "") do
		print("--")
		chunk, line = core.lop(line)
		chunk = ai.badword(chunk)
		chunk = ai.validate(chunk)
		table.insert(outtable,chunk)
	end
	
	return outtable

end

function ai.learn(line)

	line = string.lower(line)
	--split out punctuation

	linetable = ai.tableize(line)
	
	if linetable == nil or #linetable < 1 then print("fuck"); return nil, "Err[ai.learn]: Table empty" end
	
	--we assume that now all words are valid english language.  no grammar assertion yet.
	for i = 1, #linetable, 1 do
		local cword = linetable[i]		

		if cword == "###" then break end --if word has been marked as bad then skip it		

		if i > 1 then --not the first word
			--Process leading word info when we add that
		else --is the first word
			--Create or add one to starter word frequency
			if type(ai.openers[cword]) == "nil" then
				ai.openers[cword] = 1
			else
				ai.openers[cword] = ai.openers[cword] + 1
			end
		end

----------------------------------------------------------		
		--Add one to our freq. and flesh out the assc. table if needed
		if type(ai.cloud[cword]) == "nil" then 
			ai.cloud[cword] = {}
			ai.cloud[cword].usage = 1
			ai.cloud[cword].to = {}
		else
			ai.cloud[cword].usage = ai.cloud[cword].usage + 1
		end
----------------------------------------------------------
		if i < #linetable then --not the last word
			local nword = linetable[i+1]  --lol, n-word
			if nword ~= "###" then
				if type(ai.cloud[cword].to[nword]) == "nil" then
					ai.cloud[cword].to[nword] = 1
				else
					ai.cloud[cword].to[nword] = ai.cloud[cword].to[nword] + 1
				end
			end
		
		else
			--Add terminating word freq when we add that.
		end
	end
	
	-- line has been parsed and frequencies stored.
end

function ai.construct(number)
	local outline = ""
	local currword = ""
	--THIS IS THE FUN PART LOL
	local rsel = {}
	for k,v in pairs(ai.openers) do
		for x = 1,v,1 do
			table.insert(rsel,k)
		end
	end
	local pick = math.random(#rsel)
	outline = rsel[pick]
	currword = outline
	
	for iter = 1,number,1 do
		local rsel = {}
		for k,v in pairs(ai.cloud[currword].to) do
			for x = 1,v,1 do
				table.insert(rsel,k)
			end
		end
		if #rsel >= 1 then 
			local pick = math.random(#rsel)
			outline = outline .. " " .. rsel[pick]
			currword = rsel[pick]
		else 
			for k,v in pairs(ai.openers) do
				for x = 1,v,1 do
					table.insert(rsel,k)
				end
			end
			local pick = math.random(#rsel)
			outline = (outline or "") .. ", " .. rsel[pick]
			currword = rsel[pick]
		end
	end
	

	echo(outline)
end

function ai.initalize()
	
	--Loads our data files.-----------------------
	for nline in io.lines("modules/small_words.txt") do table.insert(ai.smallwords,nline) end
	for nline in io.lines("modules/bad_triplets.txt") do table.insert(ai.triplets,nline) end
	for nline in io.lines("modules/bad_words.txt") do table.insert(ai.badlist,nline) end
end

ai.initalize()

function ai.testprint()
	poostr = '' 
	for k,v in pairs(ai.cloud) do 
		poostr = poostr .. k .. '[' .. v.usage .. '] ' 
	end 
	echo(poostr, '#test2')
end

function savecloud() 
	table.save(ai.cloud, 'cloudfile.txt') 
	table.save(ai.openers, 'openerfile.txt') 
end

function loadcloud() 
	ai.cloud = table.load('cloudfile.txt') 
	ai.openers = table.load('openerfile.txt')
end

add_hook("parse_chat","ai_learn",ai.learn)
--hook in learn function to parsechat
--hook in line spitout to cycle w/ timer
push_reaction("parsefile",true,1,false,"dynamic","for nline in io.lines('modules/' .. arglist[1]) do ai.learn(nline) end")
push_reaction("savecloud",true,0,false,"function",savecloud)
push_reaction("loadcloud",true,0,false,"function",loadcloud)
push_reaction("talk",true,1,false,"function",ai.construct)
