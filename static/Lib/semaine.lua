local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model 

SEMAINE = Model:extend("SEMAINE", {
  primary_key = "DATEDEBSEM"
})

function getWeek(dateDeb)
    local week = SEMAINE:find(dateDeb)
    return {dateDeb,week.DATEFINSEM}
end
