function loadup(comd, argnum, passlft, exestring)
	local mhold = module_list.current
	module_list.current = "dynamic"
	push_reaction(comd, false, argnum, passlft, "dynamic", exestring)
	echo(ctcp_color(12) .. "== Command " .. comd .. " added.")
	module_list.current = mhold
end

function loadup_auth(comd, argnum, passlft, exestring)
	local mhold = module_list.current
	module_list.current = "dynamic"
	push_reaction(comd, true, argnum, passlft, "dynamic", exestring)
	echo(ctcp_color(12) .. "== Command " .. comd .. " added.")
	module_list.current = mhold
end

function wipe_cmd(comd)
	for i,v in ipairs(reaction) do 
		if v.command==arglist[1] then 
			table.remove(reaction,i) 
			echo(ctcp_color(12) .. "== " .. comd .. " erased from command table.")
		end 
	end
end


push_reaction("raw",true,0,true,"function",push,"!raw <command> - Pushes the given command line to the server unchanged.")
push_reaction("load",true,3,true,"function",loadup,"!load <#args> <Pass remainder 0|1> <Lua command set> - Dynamically loads a command.  Advanced users only.  For a priviledge restricted !load, see !load_secure.")
push_reaction("load_secure",true,3,true,"function",loadup_auth,"!load_secure - Loads a dynamic command with privileged usage only. (see !load for syntax)")
push_reaction("wipe",true,1,false,"function",wipe_cmd,"!wipe <command> - Erases given command.")
