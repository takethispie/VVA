local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local COMPTE = Model:extend("COMPTE", {
  primary_key = "USER"
})

local ETATRESERVATION = Model:extend("ETAT_RESA", {
  primary_key = "CODEETARESA"
})

local HEBERGEMENT = Model:extend("HEBERGEMENT", {
  primary_key = "NOHEB"
})

local RESERVATION = Model:extend("RESA", {
  primary_key = {"NOHEB","DATEDEBSEM"}
})

local SAISON = Model:extend("SAISON", {
  primary_key = "CODESAISON"
})

local SEMAINE = Model:extend("SEMAINE", {
  primary_key = "DATEDEBSEM"
})

local TARIF = Model:extend("TARIF", {
  primary_key = "NOHEB"
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
	
		elseif session.user.TYPECOMPTE == "AVV" then
			session.isAVV = true
		else
			session.isVIL = true
		end
		session.loggedIn = 1
  else
    session.loggedIn = 0
	end
end

function addVillageois(user,nom,prenom,mdp,dateIns)
	createAccount(user,nom,prenom,mdp,dateIns,"VIL")
end

function createAccount(user,nom,prenom,mdp,dateIns,typeCompte)
	COMPTE:create({USER=user,NOMCOMPTE=nom,PRENOMCOMPTE=prenom,MDP=mdp,DATEINSCRIP=dateIns,DATESUPPRESSION="",TYPECOMPTE=typeCompte})
end

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--**************************** hebergement ****************************--

function addHeb(session,param)
	local exists = HEBERGEMENT:find({NOMHEB = param.nomHeb},"nomHeb")
	if exists == nil then
		-- ajout hebergement
	end
end

--retourne les hebergements qui ne sont pas reservé
function getAvailableHeb(session,param)

end

--retourne les hebergements dans la tranche de prix
function getHebInPriceRange(session,param)

end

-- reserve un hebergement
function resHeb(session,heb,dateDebut,dateFin)
    local booked = isBooked(heb,dateDebut,dateFin)
    -- verifier que heb ,n'est pas reservé
    if booked == 1 then
        print("rsv_saved")
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
function isBooked(heb,dateDeb,dateFin)
	local res = RESERVATION:find(heb.NOHEB,dateDeb)

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
                print("week exists")
                RESERVATION:create({NOHEB = heb.NOHEB,DATEDEBSEM=dateDeb,
                NOVILLAGEOIS=vill.NOVILLAGEOIS,CODEETATRESA=0,PRIXRESA=price,MONTANTARRHES=arrhes,NBOCCUPANT=nbPers})
			end
 		end
    end
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

--********************************************************************--
--***************************************************************************************************************************************************-



--***************************************************************************************************************************************************-
--****************************** tarif *******************************--
function getTarif(dateDeb,heb)
    local tarif = TARIF:find(heb.NOHEB,dateDeb)
    print(tarif.PRIXHEB)
    return tarif.PRIXHEB
end

--********************************************************************--
--***************************************************************************************************************************************************-