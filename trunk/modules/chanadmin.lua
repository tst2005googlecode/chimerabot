require_mod('usertable')

function add_op()

	if type(oplist[target]) == "nil" then oplist[target] = {} end
	table.insert(oplist[target],mask_to_end(source))
	echo(ctcp_color(12) .. "== " .. mask_to_end(source) .. " added to OP list.")

end

function force_op(nick)
	chan = target
	local v = find_user(nick,chan)
	if v then
		if type(oplist[chan]) == "nil" then oplist[chan] = {} end
		table.insert(oplist[chan],v.mask)
		echo(ctcp_color(12) .. "== " .. v.mask .. " added to OP list by " .. mask_to_nick(source) .. ".")
	end
end

function fuck_op(nick)
    if type(oplist[target]) == "table" then
		for i,v in ipairs(oplist[target]) do 
			if v == arglist[1] then 
				table.remove(oplist[target],i) 
				echo(ctcp_color(12) .. "== " .. nick .. " removed from OP list by " .. mask_to_nick(source) .. ".")
			end 
		end
	end
end

function kick(channel, targ, message)
	push('KICK ' .. channel .. ' ' .. targ .. ' ' .. message)
end

function chan_hook(chop)
	if chop.command == "JOIN" then
		if type(oplist[chop.text]) == "table" then
			for i,v in ipairs(oplist[chop.text]) do
				if v == mask_to_end(chop.source) or v == mask_to_nick(chop.source) then 
					push("MODE " .. chop.text .. " +o " .. mask_to_nick(chop.source))
				end
			end
		end
	end
end


push_reaction("aop",true,0,false,"function",add_op,"!aop - Adds the user giving the command to the auto-op list.")
push_reaction("fop",true,1,false,"function",force_op,"!fop <username> - Adds specified user to the auto-op list.")
push_reaction("rop",true,1,false,"function",fuck_op,"!rop <username> - Removes specified user from the auto-op list.")
push_reaction("kick",true,2,true,"dynamic","kick(arglist[1],arglist[2],arglist[3])","!kick <channel> <nick> [message] - Kickes user from specified channel.")
add_hook("parse_raw", "chanadmin", chan_hook)