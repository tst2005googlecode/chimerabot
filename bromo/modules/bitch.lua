chanfuck = ""
rape = ""

function rape_check(line)
	
	if mask_to_nick(source) == rape then kick(target, rape, 'lolrape') end
	
end

function goatse(chan)
echo("* g o a t s e x * g o a t s e x * g o a t s e x *",chan)
echo("g                                               g",chan)
echo("o /     \             \            /    \       o",chan)
echo("a|       |             \          |      |      a",chan)
echo("t|       `.             |         |       :     t",chan)
echo("s`        |             |        \|       |     s",chan)
echo("e \       | /       /  \\\   --__ \\       :    e",chan)
echo("x  \      \/   _--~~          ~--__| \     |    x",chan)
echo("*   \      \_-~                    ~-_\    |    *",chan)
echo("g    \_     \        _.--------.______\|   |    g",chan)
echo("o      \     \______// _ ___ _ (_(__>  \   |    o",chan)
echo("a       \   .  C ___)  ______ (_(____>  |  /    a",chan)
echo("t       /\ |   C ____)/      \ (_____>  |_/     t",chan)
echo("s      / /\|   C_____)       |  (___>   /  \    s",chan)
echo("e     |   (   _C_____)\______/  // _/ /     \   e",chan)
echo("x     |    \  |__   \\_________// (__/       |  x",chan)
echo("*    | \    \____)   `----   --'             |  *",chan)
echo("g    |  \_          ___\       /_          _/ | g",chan)
echo("o   |              /    |     |  \            | o",chan)
echo("a   |             |    /       \  \           | a",chan)
echo("t   |          / /    |         |  \           |t",chan)
echo("s   |         / /      \__/\___/    |          |s",chan)
echo("e  |           /        |    |       |         |e",chan)
echo("x  |          |         |    |       |         |x",chan)
echo("* g o a t s e x * g o a t s e x * g o a t s e x *",chan)
end

push_reaction("goatse",true,1,false,"function",goatse,"lolwat")

push_reaction("masslight",true,1,false,"dynamic","out = ''; for k,v in pairs(chandata[arglist[1]]) do if v.mode == 'op' then out = out .. k .. ' ' end end echo(out)")
push_reaction("rape",true,1,false,"dynamic","rape = arglist[1]; add_hook('parse_chat', 'rape', rape_check)")
push_reaction("derape",true,0,false,"dynamic","remove_hook('rape')")
push_reaction("defuck",true,0,false,"dynamic","for i,v in ipairs(hook_list) do if v.name == 'fucked' then table.remove(hook_list,i) end end")
push_reaction("chanfuck",true,1,false,"dynamic","chanfuck = arglist[1]; function fuckyou(line) push('PRIVMSG ' .. chanfuck .. ' ' .. line) end; add_hook('parse_chat', 'fucked', fuckyou)")