local lapis = require("lapis")
local http = require("lapis.nginx.http")
local validate = require("lapis.validate")
local app_helpers = require("lapis.application")
local utils = require("/static/Lib/utils")
local database = require("/static/Lib/database")
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
	return {redirect_to = "/"}
end)

app:match("contact","/contact", function(self)
	self.session.activetab = "contact"
	return {redirect_to = "/"}
end)

app:match("Login","/Login", function(self)
    self.session.activetab = "login"
	return {render = true}
end)

app:match("Account","/Account", function(self)
	self.session.activetab = "account"
	return {redirect_to = "/"}
end)

app:match("adminPanel","/adminPanel", function(self)
	self.session.activetab = "adminpanel"
	return {redirect_to = "/"}
end)

app:match("Disconnect","/Disconnect", function(self)
	disconnect(self.session)
	return {redirect_to = "/"}
end)

app:match("adminAddMember","/adminAddMember", function(self)
	--addVillageois("villageois","dean","dan","admin","2015-11-20")
	return {redirect_to = "/"}
end)

app:match("avvPanel","/avvPanel", function(self)
	self.session.activetab = "avv_panel"
	return {redirect_to = "/"}
end)

-----------------------------------------------------------


---------------------------POST----------------------------
app:post("loginExe","/loginExe", function(self)
    self.session.activetab = "acceuil"
	connect(self.session,self)
	return { redirect_to = "/"}
end)

app:post("registerExe","/registerExe", function(self)
	self.session.loggedIn = 1
	return { redirect_to = "/"}
end)

app:post("Search","/Search", function(self)
	heb = getHebSelect("where NOMHEB like '%"..self.req.params_post.searchInput.."%'")
	print(heb.NOMHEB)
	return { redirect_to = "/"}
end)

app:post("contactExe","/contactExe",function(self)
	-- send mail
	return { redirect_to = "/"}
end)

app:post("addMember","/addMember", function(self)
	return { redirect_to = "/"}
end)

--check fields and dates to book an estate
app:post("reserver","/reserver", function(self)
    print("datepickerD: "..self.params.datepickerD)
    print("datepickerF: "..self.params.datepickerF)
    resHeb(self.session,self.session.hebergement,self.params.datepickerD,self.params.datepickerF,self.params.numPers)
    self.session.activetab = "acceuil"
	return { redirect_to = "/"}
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
	return { redirect_to = "/"}
end))

app:match("hebinfo","/hebinfo",function(self)
    self.session.activetab = "hebinfo"
    self.session.breadTitle = "Description"
	self.session.hebergement = getHebFind(self.req.params_post.ID)
	return { redirect_to = "/" }
end)
-----------------------------------------------------------


-------------------------index-----------------------------
app:match("index","/index", function(self)
    self.session.activetab = "acceuil"
    self.session.breadTitle = "Acceuil"
	indexLoad(self.session)
	return { redirect_to = "/" }
end)

app:get("/", function(self)
    self.session.breadTitle = "Acceuil"
	indexLoad(self.session)
	return { render = "index"}
end)
-----------------------------------------------------------

return app
