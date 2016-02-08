local os = require("os")

function getCurrentDate()
	local date = os.date("*t")
	return table.concat(date)
end

function getIntDate(date)
    return date:gsub("-","")
end
