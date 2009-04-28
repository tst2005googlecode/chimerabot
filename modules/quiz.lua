quiz = {channel = "", mode = 0, active = false}
bank = {current = 0, hintcount = 0, hintout = ""}
scores = {}

math.randomseed (os.clock())

set_timer("quiz_qq")

function on_chat(line)
	print("afterinrun >" .. line)
	if tonumber(quiz.mode) == 1 and target == quiz.channel and quiz.active == true then

		if bank.current == 0 then  --fetch a new question
			bank.current = math.random(#bank)
			reset_timer("quiz_qq")

			echo(ctcp_color(0,12) .. ctcp.underline .. 'Next question:',quiz.channel)
			echo(bank[bank.current].q,quiz.channel)

			for i = 1,#bank[bank.current].a,1 do
				if string.sub(bank[bank.current].a,i,i) ~= ' ' then 
					bank.hintout = bank.hintout .. '-'
				else
					bank.hintout = bank.hintout .. ' '
				end
			end
			reset_trigger("quiz_hint")
			start_timer("quiz_qq")
			
		end
		
		if string.lower(line) == string.lower(bank[bank.current].a) then
			pause_timer("quiz_qq")
			nickwin = mask_to_nick(source)
			wintime = math.floor(get_timer("quiz_qq"))
			echo(ctcp_color(0,12) .. nickwin .. ' answered correctly with \'' .. bank[bank.current].a .. '\' in ' .. wintime .. ' seconds!',quiz.channel)
			if scores[nickwin] then scores[nickwin] = scores[nickwin] + 1 else scores[nickwin] = 1 end
			echo(nickwin .. ' currently has ' .. ctcp_color(0,12) .. ctcp.bold .. scores[nickwin] .. ctcp.plain .. ' points.',quiz.channel)
			bank.current = 0
			reset_trigger("quiz_hint")
			bank.hintout = ""
		end
				
		if line == "hint" then give_hint() end

	end

end

function run_hint()
	print("inrun")
	on_chat("hint")
end

--timer_remove("quiz_qq")

function give_hint()
	reset_trigger("quiz_hint")
	print("giving hint")
	ans = bank[bank.current].a
	if bank.hintout == ans then okgo = true else okgo = false end
	while(okgo ~= true) do
		spot = math.random(#ans)
		if string.sub(bank.hintout,spot,spot) == "-" then 
			bank.hintout = string.sub(bank.hintout,1,spot - 1) .. string.sub(ans,spot,spot) .. string.sub(bank.hintout,spot + 1)
			print("ipooped")
			echo(ctcp_color(9) .. 'Hint: ' .. ctcp.plain .. bank.hintout,quiz.channel)
			okgo = true
		end
	end
	
end

function load_bank(filename)
	bankfile = io.open(filename,"r")
	count = 0
	ecount = 0
	for nline in bankfile:lines() do
		loc = string.find(nline,"*",1,true)
		if loc ~= nil then
			qq = string.sub(nline,1,loc - 1)
			aa = string.sub(nline,loc+1)
			checkdupe = string.find(aa,"*",1,true)
			if checkdupe ~= nil then aa = string.sub(aa,1,checkdupe - 1) end
			pushme = { q = qq, a = aa }
			table.insert(bank, pushme)
			count = count + 1
		else
			ecount = ecount + 1
		end
	end
	echo("File read. " .. count .. " questions processed. " .. ecount .. " lines with errors.")
	bankfile:close()

end

function start_quiz()
	quiz.active = true
	on_chat("")
end

function set_quiz(arg)
	if #bank == 0 then 
		echo(ctcp_color(1,9) .. ctcp.underline .. "ERROR:" .. ctcp.plain .. " No question bank loaded.")
	else
		if #bank > 0 then
			if tonumber(arg) == 0 then 
				quiz.mode = arg
				quiz.channel = target
				remove_trigger("quiz_hint") 
				pause_timer("quiz_qq")
				reset_timer("quiz_qq")
				quiz.active = false
			end
			if tonumber(arg) == 1 then 
				quiz.mode = arg
				quiz.channel = target
				echo(ctcp_color(0,12) .. ctcp.underline .. "Quiz starting in 10 seconds!",quiz.channel)
				start_timer("quiz_qq")
				set_trigger("quiz_hint",5,run_hint,"reset") 
				set_trigger("quiz_start",10,start_quiz,"die")
			end
		end
	end
end

function skip()
	bank.current = 0
	bank.hintout = ""
	echo(ctcp_color(4) .. "Skipping current question.",quiz.channel)
	on_chat("")
end

function check_leader()
	name = ""
	score = 0
	for k,v in pairs(scores) do
		if v > score and v ~= nil then 
			name = k
			score = v 
		end
	end
	echo(ctcp_color(4).. "=== " .. ctcp.plain .. "The current leader is " .. ctcp_color(0,12) .. name .. ctcp.plain	
	     .. " with " .. ctcp_color(0,12) .. ctcp.bold .. score .. ctcp.plain .. " points! " .. ctcp_color(4) .. "===",quiz.channel)
end

function get_score()
	name = mask_to_nick(source)
	score = scores[name]
	print("in")
	if score ~= nil then
		print("1")
		echo(ctcp_color(4) .. "=== The score for ".. name .. " is " .. score .. " points. ===",quiz.channel)
	else
		print("2")
		echo(ctcp_color(4) .. "=== There is no score for ".. name .. ". ===",quiz.channel)
	end
	
end

push_reaction("leader",false,0,false,"function",check_leader)
push_reaction("score",false,0,false,"function",get_score)
push_reaction("skip",true,0,false,"function",skip)
push_reaction("quiz",true,1,false,"function",set_quiz)
push_reaction("loadbank",true,1,false,"function",load_bank)
add_hook("parse_chat", "quiz", on_chat)