local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

COMPTE = Model:extend("COMPTE", {
  primary_key = "USER"
})

--used for login
function connect(session,app)
	session.user = COMPTE:find({USER = app.req.params_post.login,MDP = app.req.params_post.password},"NOMCOMPTE")
	-- check if account exists
	if session.user ~= nil then
		if session.user.TYPECOMPTE == "ADM" then
			session.isAdmin = true
		end
		if session.user.TYPECOMPTE == "AVV" then
			session.isAVV = true
		end
		session.loggedIn = 1
  else
    session.loggedIn = 0
	end
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

  session.news = {"first news","second news"}
	session.activetab = "acceuil"
	session.numhebergement = 0
	session.hebID = 0
	session.hebInfo = {}
	session.hebergement = {}
end


function disconnect(session)
	session.loggedIn = 0
	session.isAdmin = false
	session.isAVV = false
	session.user = nil
end

function addVillageois(user,nom,prenom,mdp,dateIns)
	createAccount(user,nom,prenom,mdp,dateIns,"VIL")
end

function createAccount(user,nom,prenom,mdp,dateIns,typeCompte)
	COMPTE:create({USER=user,NOMCOMPTE=nom,PRENOMCOMPTE=prenom,MDP=mdp,DATEINSCRIP=dateIns,DATESUPPRESSION="",TYPECOMPTE=typeCompte})
end
