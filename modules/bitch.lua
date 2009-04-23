chanfuck = ""
rape = ""

function rape_check(line)
	
	if mask_to_nick(source) == rape then kick(target, rape, 'lolrape') end
	
end

push_reaction("masslight",true,1,false,"dynamic","out = ''; for k,v in pairs(chandata[arglist[1]]) do if v.mode == 'op' then out = out .. k .. ' ' end end echo(out)")
push_reaction("rape",true,1,false,"dynamic","rape = arglist[1]; add_hook('parse_chat', 'rape', rape_check)")
push_reaction("derape",true,0,false,"dynamic","remove_hook('rape')")
push_reaction("defuck",true,0,false,"dynamic","for i,v in ipairs(hook_list) do if v.name == 'fucked' then table.remove(hook_list,i) end end")
push_reaction("chanfuck",true,1,false,"dynamic","chanfuck = arglist[1]; function fuckyou(line) push('PRIVMSG ' .. chanfuck .. ' ' .. line) end; add_hook('parse_chat', 'fucked', fuckyou)")