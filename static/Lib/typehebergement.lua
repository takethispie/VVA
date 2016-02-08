local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

TYPEHEB = Model:extend("TYPE_HEB", {
  primary_key = "CODETYPEHEB"
})
