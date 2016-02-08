local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local reservation = require("/static/Lib/reservation")
local tarif = require("/static/Lib/tarif")
local utils = require("/static/Lib/utils")

HEBERGEMENT = Model:extend("HEBERGEMENT", {
  primary_key = "NOHEB"
})

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
function resHeb(heb,dateDebut,dateFin)
    local booked = isBooked(heb,dateDebut,dateFin)
    -- verifier que heb ,n'est pas reservé
    if booked == 1 then
        print("rsv_saved")
        book(heb,dateDeb,dateFin)
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
