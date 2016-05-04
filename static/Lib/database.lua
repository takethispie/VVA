local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local utils = require("/static/Lib/utils")

COMPTE = Model:extend("COMPTE", {
  primary_key = "USER"
})

ETATRESERVATION = Model:extend("ETAT_RESA", {
  primary_key = "CODEETARESA"
})

HEBERGEMENT = Model:extend("HEBERGEMENT", {
    primary_key = "NOHEB"
})

RESERVATION = Model:extend("RESA", {
    primary_key = {"NOHEB","DATEDEBSEM"}
})

SAISON = Model:extend("SAISON", {
  primary_key = "CODESAISON"
})

SEMAINE = Model:extend("SEMAINE", {
  primary_key = "DATEDEBSEM"
})

TARIF = Model:extend("TARIF", {
  primary_key = {"NOHEB","CODESAISON"}
})

TYPEHEB = Model:extend("TYPE_HEB", {
  primary_key = "CODETYPEHEB"
})

VILLAGEOIS = Model:extend("VILLAGEOIS", {
  primary_key = "NOVILLAGEOIS"
})

--***************************************************************************************************************************************************-
--****************************** COMPTE ******************************--
-- used for login
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
function addHeb(session,param)
	local exists = HEBERGEMENT:find({NOMHEB = param.nomheb})
	if exists == nil then
        print("hebergement added")
        HEBERGEMENT:create({NOHEB=HEBERGEMENT:count(),CODETYPEHEB="0", NOMHEB = param.nomheb, NBPLACEHEB = param.numpers, SURFACEHEB = param.surface, INTERNET="1", ANNEEHEB = param.anneeheb, SECTEURHEB = param.sectheb, ORIENTATIONHEB = param.orientheb, ETATHEB = "Libre", DESCRIHEB = param.description, PHOTOHEB = param.hebimg or "static/images/nopicture.jpeg"})
        TARIF:create({NOHEB=HEBERGEMENT:count(),CODESAISON=1,PRIXHEB=param.prixete})
        TARIF:create({NOHEB=HEBERGEMENT:count(),CODESAISON=0,PRIXHEB=param.prixhiver})
	end
    print("Error: can't add hebergement")
end

-- book an hebergement
function resHeb(session,heb,dateDebut,dateFin,numpers)
    print("price resheb : "..session.price)
    local booked = isBooked(heb.NOHEB,dateDebut)
    -- check if hebergement isn't booked yet
    if booked == 1 then
        -- bresult might return "novill" or "noweek" in case of booking error or 1 if successful
        local bresult = book(session,heb,dateDebut,dateFin,numpers)
        print("book result : "..bresult)
        return bresult
    elseif booked == 2 then
        print("alrdy_bked")
        -- already booked this week
        return 0
    else
        -- error
        return 2
    end
end

function getHebCount()
	return HEBERGEMENT:count()
end

function getHebFind(index)
	return HEBERGEMENT:find(index)
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
    if session.price == nil then
        print("error no season")
    else
        local arrhes = (session.price/100.0)*25.0
		local vill = VILLAGEOIS:find({USER = session.user.USER},"NOVILLAGEOIS")
		if vill == nil then 
			return "novill"
		else
			--print(vill.NOMVILLAGEOIS)
			if getWeek(dateDeb) == nil then
				return "noweek"
            else
                RESERVATION:create({NOHEB=heb.NOHEB,DATEDEBSEM=dateDeb,NOVILLAGEOIS=vill.NOVILLAGEOIS,CODEETATRESA=0,PRIXRESA=session.price,MONTANTARRHES=arrhes,NBOCCUPANT=nbPers,DATERESA=getCurrentDate()})
			    return 1
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

-- 0 = hiver, 1 = été
function getTarifFind(noheb,code)
    local tarif = 0
    if code == 0 then
        local sais = SAISON:select("where YEAR(DATEDEBSAISON) BETWEEN "..os.date("*t").year.." AND "..(os.date("*t").year + 1).." AND NOMSAISON = ? ","hiver")
        print(TARIF:find(noheb,sais[1].CODESAISON).PRIXHEB)
        return TARIF:find(noheb,sais[1].CODESAISON)
    elseif code == 1 then
        local sais = SAISON:select("where YEAR(DATEDEBSAISON) BETWEEN "..os.date("*t").year.." AND "..(os.date("*t").year + 1).." AND NOMSAISON = ? ","ete")
        print(TARIF:find(noheb,sais[1].CODESAISON).PRIXHEB)
        return TARIF:find(noheb,sais[1].CODESAISON)
    end
    return nil
end

--********************************************************************--
--***************************************************************************************************************************************************-


--***************************************************************************************************************************************************-
--****************************** saison *******************************--
function getSaison(date)
    return SAISON:select("where DATEDEBSAISON <= '"..date.."' AND DATEFINSAISON >= '"..date.."'")
end
--********************************************************************--
--***************************************************************************************************************************************************-