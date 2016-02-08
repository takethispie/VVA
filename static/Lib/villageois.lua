local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model 

VILLAGEOIS = Model:extend("VILLAGEOIS", {
  primary_key = "NOVILLAGEOIS"
})


