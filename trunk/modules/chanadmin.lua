require_mod('timing')
require_mod('usertable')

banlist = {}


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

function ban(tchan, tuser, ttime)

	touser = tuser 
	udata = find_user(tuser)
	if udata then touser = '*!*@' .. udata.mask end
	
	topush = {channel = tchan, user = touser, unbantime = ttime}
	table.insert(banlist, topush)
	
	push('MODE ' .. tchan .. ' +b ' .. touser)
	if find_user(udata.nick,tchan) then kick(tchan, udata.nick, "Come back later. Or not. Actually, please don't.") end
	
	
	
end

function do_ban(tchan, tuser, days, hours, mins, secs)

	ttime = os.date("*t")
	
	ttime.sec = ttime.sec + secs
	if ttime.sec >= 60 then ttime.sec = ttime.sec - 60; ttime.min = ttime.min + 1; end
	ttime.min = ttime.min + mins 
	if ttime.min >= 60 then ttime.min = ttime.min - 60; ttime.hour = ttime.hour + 1; end
	ttime.hour = ttime.hour + hours
	if ttime.hour >= 24 then ttime.hour = ttime.hour - 24; ttime.day = ttime.day + 1; end
	ttime.day = ttime.day + days
	
	dotime = os.time(ttime)
	print("== Banning " .. tuser .. " for [" .. days .. ":" .. hours .. ":" .. mins .. ":" .. secs .. "]")
	ban(tchan,tuser,dotime)
	
end

function ban_check(ontime)
	--Checks for and removes bans that have expired.
	for i,v in ipairs(banlist) do
		if os.difftime(v.unbantime,ontime) <= 0 then
			print("== Unbanning " .. v.user .. " from " .. v.channel)
			push('MODE ' .. v.channel .. ' -b ' .. v.user)
			table.remove(banlist,i)

		end
	end

end




push_reaction("aop",true,0,false,"function",add_op,"!aop - Adds the user giving the command to the auto-op list.")
push_reaction("fop",true,1,false,"function",force_op,"!fop <username> - Adds specified user to the auto-op list.")
push_reaction("rop",true,1,false,"function",fuck_op,"!rop <username> - Removes specified user from the auto-op list.")
push_reaction("kick",true,2,true,"dynamic","kick(arglist[1],arglist[2],arglist[3])","!kick <channel> <nick> [message] - Kicks user from specified channel.")
push_reaction("ban",true,6,false,"function",do_ban,"!ban <channel> <nick> <days> <hours> <mins> <secs> - Bans user for this long.")

add_hook("parse_raw", "chanadmin", chan_hook)
add_hook("on_timing", "ban_check", ban_check)