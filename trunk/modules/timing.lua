timer_list = {}
trigger_list = {}
timing = {}
timing.current = 0
timing.last = 0

function get_clock()
	ctime = os.time()
	return ctime
end

function set_timer(setname)
	toadd = {name = setname, elapsed = 0, running = false}
	table.insert(timer_list,toadd)
end

function start_timer(ctimer)
	for i,v in ipairs(timer_list) do 
		if v.name == ctimer then
			timer_list[i].running = true
		end
	end
end

function pause_timer(ctimer)
	for i,v in ipairs(timer_list) do 
		if v.name == ctimer then
			timer_list[i].running = false
		end
	end
end

function reset_timer(ctimer)
	for i,v in ipairs(timer_list) do 
		if v.name == ctimer then
			timer_list[i].elapsed = 0
		end
	end
end

function get_timer(ctimer)
	for i,v in ipairs(timer_list) do 
		if v.name == ctimer then
			return v.elapsed
		end
	end
	return nil
end

function remove_timer(ctimer)
	for i,v in ipairs(timer_list) do 
		if v.name == ctimer then
			table.remove(timer_list,i)
		end
	end
end

function set_trigger(cname, etafire, tolink, modetype)
	print("set_trigger")
	toadd = {name = cname, current = 0, target = tonumber(etafire), link = tolink, mode = modetype or "die"}
	table.insert(trigger_list,toadd)
end

function reset_trigger(cname)
	for i,v in ipairs(trigger_list) do 
		if v.name == cname then
			trigger_list[i].elapsed = 0
		end
	end
end

function remove_trigger(cname)
	for i,v in ipairs(trigger_list) do 
		if v.name == cname then
			table.remove(trigger_list,i)
	        print("Remove trigger " .. cname)		
		end
	end
end

function handle_timing()
	timing.last = timing.current
	timing.current = get_clock()
	delta = os.difftime (timing.current, timing.last)

	for i,v in ipairs(timer_list) do 
		if v.running then timer_list[i].elapsed = timer_list[i].elapsed + delta end
	end

--============================Triggers
	for i,v in ipairs(trigger_list) do 
		trigger_list[i].current = trigger_list[i].current + delta
				
		if trigger_list[i].current >= trigger_list[i].target then
			trigger_list[i].link()
			if v.mode == "reset" then trigger_list[i].current = 0
			else table.remove(trigger_list,i) end
			
		end
	end

	for i,v in ipairs(hook_list) do	if v.target == "on_timing" then v.link(timing.current, delta) end end --Run our on_timing hooks
	
end

function check_trigger ()
	for i,v in ipairs(trigger_list) do 
		print("=====")
		print(v.name)
		if v.name == "quiz_hint" then
			print(i .. ": " .. v.name .. " " .. v.current)
		end
	end
end

timing.current = get_clock()
timing.last = timing.current
