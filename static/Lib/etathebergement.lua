local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

ETATRESERVATION = Model:extend("ETAT_RESA", {
  primary_key = "CODEETARESA"
})
