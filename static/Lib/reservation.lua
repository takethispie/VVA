local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local utils = require("/static/Lib/utils")
local semaine = require("/static/Lib/semaine")

RESERVATION = Model:extend("RESA", {
  primary_key = {"NOHEB","DATEDEBSEM"}
})

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
function book(heb,dateDeb,dateFin)
    local price = getTarif(dateDeb,heb)
    if tarif == nil then
        print("error no season")
    else
        local resDate = getCurrentDate()
        --session.hebergement.NBPLACEHEB
        local arrhes = (price/100.0)*25
        print("arrhes: " + arrhes)
    end
end
