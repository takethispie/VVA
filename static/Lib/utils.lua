function getCurrentDate()
	return os.date("%F")
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
end

function disconnect(session)
	session.loggedIn = 0
	session.isAdmin = false
	session.isAVV = false
	session.user = nil
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
