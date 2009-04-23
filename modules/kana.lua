
function nibble(instr)
	poop = ""
	if #instr > 0 then poop = string.sub(instr,1,1) else poop = "" end
	if #instr > 1 then instr = string.sub(instr,2) else instr = "" end
	return poop, instr
end

function kseek(letter)
	for i,v in ipairs(klist) do
		if v.char == letter then return i end
	end
	return 0
end

function press_kana(index)
	outline = ""
	if index ~= 0 then 
		outline = outline .. string.char(klist[index].low) .. string.char(klist[index].mid) .. string.char(klist[index].hi)
	else
		outline = outline .. "?"
	end
	return outline
end

function kana(inline)
	inline = string.lower(inline)
	outline = ""
	chunk = ""
	chunktmp = ""
	chunktmp2 = ""
	adder = 0
	while(#inline > 0) do
		chunk, inline = nibble(inline)
		found = false
		if chunk ~= " " then
		if chunk == "a" or chunk == "e" or chunk == "i" or chunk == "o" or chunk == "u" then
			outline = outline .. press_kana(kseek(chunk))
		else
			chunktmp, inline = nibble(inline)
			if chunktmp == "a" or chunktmp == "e" or chunktmp == "i" or chunktmp == "o" or chunktmp == "u" then
				chunk = chunk .. chunktmp
				outline = outline .. press_kana(kseek(chunk))
			else
				if chunk == "n" and chunktmp ~= "y" then
					inline = chunktmp .. inline
					chunktmp = ""
					outline = outline .. press_kana(kseek("n"))
					found = true
				end
				if chunk == chunktmp and chunk ~= "n" then
					inline = chunktmp .. inline
					outline = outline .. press_kana(kseek("stsu"))
				else
					if chunk == "t" and chunktmp == "s" then
						bucket, inline = nibble(inline)
						found = true
						outline = outline .. press_kana(kseek("tsu"))
					elseif chunk == "c" and chunktmp == "h" then
						chunktmp2, inline = nibble(inline)
						if chunktmp2 == "i" then 
							found = true
							outline = outline .. press_kana(kseek("chi"))
						else
							inline = chunktmp2 .. inline
						end
					elseif chunk == "s" and chunktmp == "h" then
						chunktmp2, inline = nibble(inline)
						if chunktmp2 == "i" then 
							found = true
							outline = outline .. press_kana(kseek("shi"))
						else
							inline = chunktmp2 .. inline
						end
					end
					if found ~= true then
						chunk = chunk .. "i"
						if chunk == "ci" then chunk = "chi" end
						chunktmp2, inline = nibble(inline)
						chunktmp = "s" .. chunktmp .. chunktmp2
						outline = outline .. press_kana(kseek(chunk))
						outline = outline .. press_kana(kseek(chunktmp))
					end
				end
			end
		end
		end
	end
	-- fix sha sho shu cha cho chu cha
	echo(outline)
end






klist = {}
klist[1] = {low = 227, mid = 129, hi = 130, char = "a"}
klist[2] = {low = 227, mid = 129, hi = 132, char = "i"}
klist[3] = {low = 227, mid = 129, hi = 134, char = "u"}
klist[4] = {low = 227, mid = 129, hi = 136, char = "e"}
klist[5] = {low = 227, mid = 129, hi = 138, char = "o"}
klist[6] = {low = 227, mid = 130, hi = 147, char = "n"}
klist[7] = {low = 227, mid = 129, hi = 139, char = "ka"}
klist[8] = {low = 227, mid = 129, hi = 140, char = "ga"}
klist[9] = {low = 227, mid = 129, hi = 141, char = "ki"}
klist[10] = {low = 227, mid = 129, hi = 142, char = "gi"}
klist[11] = {low = 227, mid = 129, hi = 143, char = "ku"}
klist[12] = {low = 227, mid = 129, hi = 144, char = "gu"}
klist[13] = {low = 227, mid = 129, hi = 145, char = "ke"}
klist[14] = {low = 227, mid = 129, hi = 146, char = "ge"}
klist[15] = {low = 227, mid = 129, hi = 147, char = "ko"}
klist[16] = {low = 227, mid = 129, hi = 148, char = "go"}
klist[17] = {low = 227, mid = 129, hi = 149, char = "sa"}
klist[18] = {low = 227, mid = 129, hi = 150, char = "za"}
klist[19] = {low = 227, mid = 129, hi = 151, char = "shi"}
klist[20] = {low = 227, mid = 129, hi = 152, char = "ji"}
klist[21] = {low = 227, mid = 129, hi = 153, char = "su"}
klist[22] = {low = 227, mid = 129, hi = 154, char = "zu"}
klist[23] = {low = 227, mid = 129, hi = 155, char = "se"}
klist[24] = {low = 227, mid = 129, hi = 156, char = "ze"}
klist[25] = {low = 227, mid = 129, hi = 157, char = "so"}
klist[26] = {low = 227, mid = 129, hi = 158, char = "zo"}
klist[27] = {low = 227, mid = 129, hi = 159, char = "ta"}
klist[28] = {low = 227, mid = 129, hi = 160, char = "da"}
klist[29] = {low = 227, mid = 129, hi = 161, char = "chi"}
klist[30] = {low = 227, mid = 129, hi = 164, char = "tsu"}
klist[31] = {low = 227, mid = 129, hi = 166, char = "te"}
klist[32] = {low = 227, mid = 129, hi = 167, char = "de"}
klist[33] = {low = 227, mid = 129, hi = 168, char = "to"}
klist[34] = {low = 227, mid = 129, hi = 169, char = "do"}
klist[35] = {low = 227, mid = 129, hi = 170, char = "na"}
klist[36] = {low = 227, mid = 129, hi = 171, char = "ni"}
klist[37] = {low = 227, mid = 129, hi = 172, char = "nu"}
klist[38] = {low = 227, mid = 129, hi = 173, char = "ne"}
klist[39] = {low = 227, mid = 129, hi = 174, char = "no"}
klist[40] = {low = 227, mid = 129, hi = 175, char = "ha"}
klist[41] = {low = 227, mid = 129, hi = 176, char = "ba"}
klist[42] = {low = 227, mid = 129, hi = 177, char = "pa"}
klist[43] = {low = 227, mid = 129, hi = 178, char = "hi"}
klist[44] = {low = 227, mid = 129, hi = 179, char = "bi"}
klist[45] = {low = 227, mid = 129, hi = 180, char = "pi"}
klist[46] = {low = 227, mid = 129, hi = 181, char = "fu"}
klist[47] = {low = 227, mid = 129, hi = 182, char = "bu"}
klist[48] = {low = 227, mid = 129, hi = 183, char = "pu"}
klist[49] = {low = 227, mid = 129, hi = 184, char = "he"}
klist[50] = {low = 227, mid = 129, hi = 185, char = "be"}
klist[51] = {low = 227, mid = 129, hi = 186, char = "pe"}
klist[52] = {low = 227, mid = 129, hi = 187, char = "ho"}
klist[53] = {low = 227, mid = 129, hi = 188, char = "bo"}
klist[54] = {low = 227, mid = 129, hi = 189, char = "po"}
klist[55] = {low = 227, mid = 129, hi = 190, char = "ma"}
klist[56] = {low = 227, mid = 129, hi = 191, char = "mi"}
klist[57] = {low = 227, mid = 130, hi = 128, char = "mu"}
klist[58] = {low = 227, mid = 130, hi = 129, char = "me"}
klist[59] = {low = 227, mid = 130, hi = 130, char = "mo"}
klist[60] = {low = 227, mid = 130, hi = 132, char = "ya"}
klist[61] = {low = 227, mid = 130, hi = 134, char = "yu"}
klist[62] = {low = 227, mid = 130, hi = 136, char = "yo"}
klist[63] = {low = 227, mid = 130, hi = 137, char = "ra"}
klist[64] = {low = 227, mid = 130, hi = 138, char = "ri"}
klist[65] = {low = 227, mid = 130, hi = 139, char = "ru"}
klist[66] = {low = 227, mid = 130, hi = 140, char = "re"}
klist[67] = {low = 227, mid = 130, hi = 141, char = "ro"}
klist[68] = {low = 227, mid = 130, hi = 143, char = "wa"}
klist[69] = {low = 227, mid = 130, hi = 146, char = "wo"}
klist[70] = {low = 227, mid = 129, hi = 162, char = "ji"}
klist[71] = {low = 227, mid = 129, hi = 163, char = "stsu"} --SMALL TSU
klist[72] = {low = 227, mid = 129, hi = 165, char = "zu"}
klist[73] = {low = 227, mid = 130, hi = 131, char = "sya"} --small ya
klist[74] = {low = 227, mid = 130, hi = 133, char = "syu"}
klist[75] = {low = 227, mid = 130, hi = 135, char = "syo"}

push_reaction("tokana",false,0,true,"function",kana)