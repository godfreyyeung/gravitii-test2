application = {
	content = {
		width = 320, -- utb 320
		height = 480, -- utb 480 
		scale = "letterBox",
		fps = 30,
		
		--[[
        imageSuffix = {
		    ["@2x"] = 2,
		}
		--]]
	},

    --[[

    CREATE A BUILD SETTINGS FILE LATER

    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }


    -- licensing
    -- you must still "require" the licensing library in core project file
    -- refer to licensing docs
        application =
    {
        license =
        {
            google =
            {
                key = "Your key here",
                policy = "this is optional",
            },
        },
    }    


    --]]    
}
