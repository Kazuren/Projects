--[[
	Given an "atlas" (a texture with multiple sprites), as well as a
	width and a height for the tiles therein, split the texture into
	all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
	local sheetWidth = atlas:getWidth() / tilewidth
	local sheetHeight = atlas:getHeight() / tileheight

	local sheetCounter = 1
	local spritesheet = {}

	for y = 0, sheetHeight - 1 do
		for x = 0, sheetWidth - 1 do
			spritesheet[sheetCounter] =
				love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
				tileheight, atlas:getDimensions())
			sheetCounter = sheetCounter + 1
		end
	end

	return spritesheet
end

--[[
	Recursive table printing function.
	https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
	t - Table
	max - max iterations
]]
function print_r (t,max)
	local print_r_cache={}
	local max = max or 1
	local function sub_print_r(t,indent,max)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") and max > 0 then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8), max - 1)
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ", max)
		print("}")
	else
		sub_print_r(t,"  ", max)
	end
	print()
end

function capitalize(str)
    return (str:gsub("^%l", string.upper))
end