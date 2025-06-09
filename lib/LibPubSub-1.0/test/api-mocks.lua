strmatch = string.match

handledErrors = 0

function geterrorhandler()
	local errorhandler = function()
		handledErrors = handledErrors + 1
	end

	return errorhandler
end
