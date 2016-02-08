local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

TARIF = Model:extend("TARIF", {
  primary_key = "NOHEB"
})

--arrhes = 25%

function getTarif(dateDeb,heb)
  local tarif = TARIF:find(heb.NOHEB,dateDeb)
  print(tarif.PRIXHEB)
end
