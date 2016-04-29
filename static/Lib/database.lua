local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local utils = require("/static/Lib/utils")

local COMPTE = Model:extend("COMPTE", {
  primary_key = "USER"
})

local ETATRESERVATION = Model:extend("ETAT_RESA", {
  primary_key = "CODEETARESA"
})

local HEBERGEMENT = Model:extend("HEBERGEMENT", {
    primary_key = "NOHEB"
})

RESERVATION = Model:extend("RESA", {
    primary_key = {"NOHEB","DATEDEBSEM"}
})

local SAISON = Model:extend("SAISON", {
  primary_key = "CODESAISON"
})

local SEMAINE = Model:extend("SEMAINE", {
  primary_key = "DATEDEBSEM"
})

local TARIF = Model:extend("TARIF", {
  primary_key = {"NOHEB","CODESAISON"}
})

local TYPEHEB = Model:extend("TYPE_HEB", {
  primary_key = "CODETYPEHEB"
})

local VILLAGEOIS = Model:extend("VILLAGEOIS", {
  primary_key = "NOVILLAGEOIS"
})

--***************************************************************************************************************************************************-
--****************************** COMPTE ******************************--
--used for login
function connect(session,app)
	session.user = COMPTE:find({USER = app.req.params_post.login,MDP = app.req.params_post.password},"NOMCOMPTE")
	-- check if account exists
	if session.user ~= nil then
		if session.user.TYPECOMPTE == "ADM" then
			session.isAdmin = true
            session.loggedIn = 1
		elseif session.user.TYPECOMPTE == "AVV" then
			session.isAVV = true
            session.loggedIn = 1
		elseif session.user.TYPECOMPTE == "VIL" then
			session.isVIL = true
            session.loggedIn = 1
        else
            session.loggedIn = 0
            print("wrong password"..app.req.params_post.password)
		end		
    else
        session.loggedIn = 0
        print("wrong password")
	end
end

function addVillageois(user,nom,prenom,mdp,dateIns)
	createAccount(user,nom,prenom,mdp,dateIns,"VIL")
end

function createAccount(user,nom,prenom,mdp,dateIns,typeCompte)
	COMPTE:create({USER=user,NOMCOMPTE=nom,PRENOMCOMPTE=prenom,MDP=mdp,DATEINSCRIP=dateIns,DATESUPPRESSION="",TYPECOMPTE=typeCompte})
end

function findAccount(v)
    return COMPTE:find(v)
end

function countAccount()
    return COMPTE:count()
end

function getAccounts()
    return COMPTE:select("")
end

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--**************************** hebergement ****************************--

-- 
function addHeb(session,param)
	local exists = HEBERGEMENT:find({NOMHEB = param.nomheb})
	if exists == nil then
        print("hebergement added")
		HEBERGEMENT:create({NOHEB=HEBERGEMENT:count(),CODETYPEHEB="0", NOMHEB = param.nomheb, NBPLACEHEB = param.numpers, SURFACEHEB = param.surface, INTERNET="1", ANNEEHEB = param.anneeheb, SECTEURHEB = param.sectheb, ORIENTATIONHEB = param.orientheb, ETATHEB = "Libre", DESCRIHEB = param.description, PHOTOHEB = "static/images/nopicture.jpeg"})
        TARIF:create({NOHEB=HEBERGEMENT:count(),CODESAISON=1,PRIXHEB=param.prixete})
        TARIF:create({NOHEB=HEBERGEMENT:count(),CODESAISON=0,PRIXHEB=param.prixhiver})
	end
    print("Error: can't add hebergement")
end

-- reserve un hebergement
function resHeb(session,heb,dateDebut,dateFin)
    local booked = isBooked(heb.NOHEB,dateDebut)
    -- verifier que heb ,n'est pas reservé
    if booked == 1 then
        book(session,heb,dateDebut,dateFin)
        return 1

    elseif booked == 2 then
        print("alrdy_bked")
        -- déjà une réservation cette semaine
        return 0

    else
        -- erreur
        return 2
    end
end

function getHebCount()
	return HEBERGEMENT:count()
end

function getHebFind(index)
	return HEBERGEMENT:find(index)
end

function getHebSelect(request)
	return HEBERGEMENT:select(request)
end

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--**************************** reservation ****************************--

-- 0 = erreur, 1 = pas reservé, 2 = reservé
function isBooked(noheb,dateDeb)
	local res = RESERVATION:find(noheb,dateDeb)

	if res == nil then
		return 1
	elseif res.DATEDEBSEM == dateDeb then
		return 2
    else
        return 0
	end
end

--need to be finished
function book(session,heb,dateDeb,dateFin,nbPers)
    local price = tonumber(getTarif(dateDeb,heb))
	
    if price == nil then
        print("error no season")
    else
        local resDate = getCurrentDate()
        --session.hebergement.NBPLACEHEB
        local arrhes = (price/100.0)*25.0
        print("arrhes: "..arrhes)
		local vill = VILLAGEOIS:find({USER = session.user.USER},"NOVILLAGEOIS")
		
		--dateDeb is nil
		print("semaine: "..dateDeb)
		if vill == nil then 
			print("no vill")
		else
			print(vill.NOMVILLAGEOIS)
			if getWeek(dateDeb) == nil then
				print("week does not exists")
            else
                RESERVATION:create({NOHEB=heb.NOHEB,DATEDEBSEM=dateDeb,NOVILLAGEOIS=vill.NOVILLAGEOIS,CODEETATRESA=0,PRIXRESA=price,MONTANTARRHES=arrhes,NBOCCUPANT=nbPers,DATERESA=getCurrentDate()})
			end
 		end
    end
end

function getReservationCount()
    if tonumber(RESERVATION:count()) then
        return tonumber(RESERVATION:count())
    else
        return 0
    end
end

function getReservationFind(index)
   return RESERVATION:find(index) 
end

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--****************************** semaine *****************************--

function getWeek(dateDeb)
    local week = SEMAINE:find(dateDeb)
    if week == nil then
       return nil
    else
        return week.DATEFINSEM
    end
end

function getAllWeeks()
    return SEMAINE:select()
end

function getWeekCount()
    return SEMAINE:count()
end

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--****************************** tarif *******************************--
function getTarif(dateDeb,heb)
    local tarif = TARIF:find(heb.NOHEB)
    print(tarif.PRIXHEB)
    return tarif.PRIXHEB
end

-- 0 = hiver, 1 = été
function getTarifFind(noheb,code)
    local tarif = TARIF:find({NOHEB = noheb,CODESAISON = code})
    print(tarif.PRIXHEB)
    return tarif
end

--********************************************************************--
--***************************************************************************************************************************************************-