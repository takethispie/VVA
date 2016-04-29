local lapis = require("lapis")
local http = require("lapis.nginx.http")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local validate = require("lapis.validate")
local app_helpers = require("lapis.application")
local util = require("lapis.util")
local utils = require("/static/Lib/utils")
database = require("/static/Lib/database")
inspect = require("/static/Lib/inspect")

local capture_errors = app_helpers.capture_errors
local app = lapis.Application()

app:enable("etlua")
app.layout = false

-----------------------routes----------------------------

app:match("gallery","/gallery", function(self)
	self.session.numhebergement = getHebCount()
    self.session.activetab = "gallery"
    self.session.breadTitle = "Liste des hébergements"
	return { render = "index" }
end)

app:match("contact","/contact", function(self)
	self.session.activetab = "contact"
    self.session.breadTitle = "Contact"
	return { render = "index" }
end)

app:match("Login","/Login", function(self)
    self.session.activetab = "login"
	return {render = "index"}
end)

app:match("Account","/Account", function(self)
    if self.session.user ~= nil then
        self.session.activetab = "account"
        self.session.breadTitle = "Account"
    else
        self.session.activetab = "acceuil"
        self.session.breadTitle = "Acceuil"
    end
	return { render = "index" }
end)

app:match("gestResaList","/gestResaList", function(self)
    self.session.reservations =  db.query("select * from `RESA_FULL_INFO`")
	self.session.activetab = "gestResaList"
	return { render = "index" }
end)

app:match("gestUserList","/gestUserList", function(self)
	self.session.activetab = "gestUserList"
	return { render = "index" }
end)

app:match("Disconnect","/Disconnect", function(self)
    self.session.activetab = "acceuil"
	disconnect(self.session)
	return { render = "index" }
end)

-----------------------------------------------------------


---------------------------POST----------------------------

app:post("change-resa-state","/change-resa-state", function(self)
    --debug print(self.req.params_post.date)
	return self.req.params_post.newState
end)

app:post("get-heb-availability","/get-heb-availability", function(self)
    print(self.req.params_post.date)
    print(self.req.params_post.noheb)
    print(isBooked(self.req.params_post.noheb,self.req.params_post.date))
end)

app:post("loginExe","/loginExe", function(self)
    self.session.activetab = "acceuil"
	connect(self.session,self)
    if self.session.loggedIn == 0 then
        self.session.activetab = "login"
    end
    return { render = "index" }
end)

app:post("registerExe","/registerExe", function(self)
	self.session.loggedIn = 1
	return {  render = "index" }
end)

app:post("modifHeb","/modifHeb", function(self)
    self.session.hebergement = getHebFind(self.req.params_post.ID)
	self.session.activetab = "modifHeb"
    self.session.breadTitle = "Modifier Hébergement"
	return {  render = "index" }
end)

app:post("modifHebExe","/modifHebExe", function(self)
    --print("ID "..self.req.params_post.ID)
    local heb = getHebFind(self.req.params_post.ID)
    local prixhiver = getTarifFind(heb.NOHEB,0)
    local prixete = getTarifFind(heb.NOHEB,1)
    
    if heb ~= nil and prixhiver ~= nil and prixete ~= nil then
        --print(inspect(heb))
        heb.ANNEEHEB = self.req.params_post.anneeheb
        heb.DESCRIHEB = self.req.params_post.description
        heb.ETATHEB = self.req.params_post.etatheb
        heb.INTERNET = self.req.params_post.internet
        heb.NBPLACEHEB = self.req.params_post.numpers
        heb.NOMHEB = self.req.params_post.nomheb
        heb.ORIENTATIONHEB = self.req.params_post.orientheb
        heb.SURFACEHEB = self.req.params_post.surface
        heb.SECTEURHEB = self.req.params_post.sectheb
        prixete.PRIXHEB = self.req.params_post.prixete
        prixhiver.PRIXHEB = self.req.params_post.prixhiver
        
        heb:update("ANNEEHEB","DESCRIHEB","ETATHEB","INTERNET","NBPLACEHEB","NOMHEB","ORIENTATIONHEB","SURFACEHEB","SECTEURHEB")
        prixete:update("PRIXHEB")
        prixhiver:update("PRIXHEB")
        print("hebergement updated")
    else
        -- will need to check that in the view
        print("error updating")
        self.res.hasError = true
    end
	return {  render = "index" }
end)

--check fields and dates to book an estate
app:post("reserver","/reserver", function(self)
    resHeb(self.session,self.session.hebergement,self.params.datepickerD,self.params.datepickerF,self.params.numPers)
    self.session.activetab = "acceuil"
	return { render = "index" }
end)

--check fields, add the hebergement or redirects if there's errors
app:post("/addHeb", capture_errors(function(self)
	validate.assert_valid(self.req.params_post,{
	{"nomheb","erreur pas de nom", exists = true, min_length = 2, max_length = 40}
	--need to add some validation
})
	addHeb(session,self.req.params_post)
    self.session.activetab = "acceuil"
	return { render = "index" }
end))

app:match("hebinfo","/hebinfo",function(self)
    self.session.activetab = "hebinfo"
    self.session.breadTitle = "Description"
	self.session.hebergement = getHebFind(self.req.params_post.ID)
	return { render = "index" }
end)

app:post("edit-resa","/edit-resa", function(self)
	self.session.activetab = "edit-resa"
    self.session.breadTitle = "Modifier réservation"
	return {  render = "index" }
end)
-----------------------------------------------------------


-------------------------index-----------------------------
--duplicate the latter will need to be removed
app:match("index","/index", function(self)
    self.session.activetab = "acceuil"
    self.session.breadTitle = "Acceuil"
	indexLoad(self.session)
	return { render = "index"}
end)

app:get("/", function(self)
    self.session.activetab = "acceuil"
    self.session.breadTitle = "Acceuil"
    indexLoad(self.session)
	return { render = "index"}
end)
-----------------------------------------------------------

return app
