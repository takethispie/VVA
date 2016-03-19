local os = require("os")

function getCurrentDate()
	local date = os.date("*t")
	return date.year.."-"..date.month.."-"..date.day
end

function getIntDate(date)
    return date:gsub("-","")
end

function indexLoad(session)
	if not session.isAdmin then
			session.isAdmin = false
	end
	if not session.loggedIn then
		session.loggedIn = 0
	end
	if not session.isAVV then
		session.isAVV = false
	end
    if not session.user then
			session.user = ""
	end

    if not session.activetab then
			session.activetab = "acceuil"
	end
    --session.numhebergement = 0
    --session.hebID = 0
    --session.hebInfo = {}
    --session.hebergement = {}
end


function disconnect(session)
	session.loggedIn = 0
	session.isAdmin = false
	session.isAVV = false
	session.user = nil
end
