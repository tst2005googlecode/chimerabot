responses = {
   "As I see it, yes",
   "It is certain",
   "It is decidedly so",
   "Most likely",
   "Outlook good",
   "Signs point to yes",
   "Without a doubt",
   "Yes",
   "Yes - definitely",
   "You may rely on it",
   "Reply hazy, try again",
   "Ask again later",
   "Better not tell you now",
   "Cannot predict now",
   "Concentrate and ask again",
   "Don't count on it",
   "My reply is no",
   "My sources say no",
   "Outlook not so good",
   "Very doubtful",
}

function eight_ball() 
	echo( responses[math.random(20)] )
end

push_reaction("8ball",false,0,false,"function",eight_ball,"!8ball - Answers a users question.")