local lapis = require("lapis")
local http = require("lapis.nginx.http")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local validate = require("lapis.validate")
local app_helpers = require("lapis.application")
local utils = require("/static/Lib/utils")
database = require("/static/Lib/database")
inspect = require("/static/Lib/inspect")

local capture_errors = app_helpers.capture_errors
local app = lapis.Application()

app:enable("etlua")
app.layout = false

-----------------------routes----------------------------

app:match("about","/about", function(self)
    self.session.activetab = "about"
	return {redirect_to = "/"}
end)

app:match("gallery","/gallery", function(self)
	self.session.numhebergement = getHebCount()
    self.session.activetab = "gallery"
	return { render = "index" }
end)

app:match("contact","/contact", function(self)
	self.session.activetab = "contact"
	return { render = "index" }
end)

app:match("Login","/Login", function(self)
    self.session.activetab = "login"
	return {render = true}
end)

app:match("Account","/Account", function(self)
	self.session.activetab = "account"
	return { render = "index" }
end)

app:match("adminPanel","/adminPanel", function(self)
    self.session.reservations =  db.query("select RESA.NOHEB, HEBERGEMENT.NOMHEB, VILLAGEOIS.USER,  ETAT_RESA.NOMETATRESA, RESA.DATEDEBSEM, RESA.NOVILLAGEOIS, RESA.CODEETATRESA, RESA.DATERESA, RESA.DATEACCUSERECEPT, RESA.DATEARRHES, RESA.MONTANTARRHES, RESA.NBOCCUPANT, RESA.PRIXRESA from RESA INNER JOIN HEBERGEMENT ON RESA.NOHEB = HEBERGEMENT.NOHEB INNER JOIN VILLAGEOIS ON RESA.NOVILLAGEOIS = VILLAGEOIS.NOVILLAGEOIS INNER JOIN ETAT_RESA ON RESA.CODEETATRESA = ETAT_RESA.CODEETATRESA")
    --debug print to see query result content
    --print("inspect"..inspect(self.session.reservations))
	self.session.activetab = "adminpanel"
	return { render = "index" }
end)

app:match("Disconnect","/Disconnect", function(self)
	disconnect(self.session)
	return { render = "index" }
end)

app:match("avvPanel","/avvPanel", function(self)
	self.session.activetab = "avv_panel"
	return { render = "index" }
end)

-----------------------------------------------------------


---------------------------POST----------------------------
app:post("loginExe","/loginExe", function(self)
    self.session.activetab = "acceuil"
	connect(self.session,self)
	return { render = "index" }
end)

app:post("registerExe","/registerExe", function(self)
	self.session.loggedIn = 1
	return {  render = "index" }
end)

app:post("Search","/Search", function(self)
	heb = getHebSelect("where NOMHEB like '%"..self.req.params_post.searchInput.."%'")
	print(heb.NOMHEB)
	return { render = "index" }
end)

app:post("contactExe","/contactExe",function(self)
	-- send mail
	return { render = "index" }
end)

app:post("addMember","/addMember", function(self)
	return { render = "index" }
end)

--check fields and dates to book an estate
app:post("reserver","/reserver", function(self)
    print("datepickerD: "..self.params.datepickerD)
    print("datepickerF: "..self.params.datepickerF)
    resHeb(self.session,self.session.hebergement,self.params.datepickerD,self.params.datepickerF,self.params.numPers)
    self.session.activetab = "acceuil"
	return { render = "index" }
end)

--check fields, add the hebergement or redirects if there's errors
app:post("addHebergementError","/addHebergement", capture_errors(function(self)
	validate.assert_valid(self.req.params_post,{
	{"nomHeb","erreur pas de nom", exists = true, min_length = 2, max_length = 40},
	{"nbplacesHeb","erreur aucun nombre de places specifié", exists = true, min_length = 1},
	{"surfaceHeb", "aucune surface specifié", exists = true, min_length = 2},
	{"anneeHeb","aucune année specifié", exists = true, min_length = 4},
	{"secteurHeb","pas de secteur spécifié", exists = true; min_length = 1}
})
	addHeb(session,self.req.params_post)
	return { render = "index" }
end))

app:match("hebinfo","/hebinfo",function(self)
    self.session.activetab = "hebinfo"
    self.session.breadTitle = "Description"
	self.session.hebergement = getHebFind(self.req.params_post.ID)
	return { render = "index" }
end)
-----------------------------------------------------------


-------------------------index-----------------------------
app:match("index","/index", function(self)
    self.session.activetab = "acceuil"
    self.session.breadTitle = "Acceuil"
	indexLoad(self.session)
	return { render = "index"}
end)

app:get("/", function(self)
    self.session.breadTitle = "Acceuil"
	indexLoad(self.session)
	return { render = "index"}
end)
-----------------------------------------------------------

return app
