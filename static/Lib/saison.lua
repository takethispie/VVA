local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model 

SAISON = Model:extend("SAISON", {
  primary_key = "CODESAISON"
})

