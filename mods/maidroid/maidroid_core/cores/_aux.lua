------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_core._aux = {}

function maidroid_core._aux.search_surrounding(pos, pred, searching_range)
	pos = vector.round(pos)
	local max_xz = math.max(searching_range.x, searching_range.z)

	for j = -searching_range.y, searching_range.y do
		local p = vector.add({x = 0, y = j, z = 0}, pos)
		if pred(p) then
			return p
		end
	end

	for i = 0, max_xz do
		for j = -searching_range.y, searching_range.y do
			for k = -i, i do
				if searching_range.x >= k and searching_range.z >= i then
					local p = vector.add({x = k, y = j, z = i}, pos)
					if pred(p) then
						return p
					end

					p = vector.add({x = k, y = j, z = -i}, pos)
					if pred(p) then
						return p
					end
				end

				if searching_range.z >= i and searching_range.z >= k then
					if i ~= k then
						local p = vector.add({x = i, y = j, z = k}, pos)
						if pred(p) then
							return p
						end
					end

					if -i ~= k then
						local p = vector.add({x = -i, y = j, z = k}, pos)
						if pred(p) then
							return p
						end
					end
				end
			end
		end
	end
	return nil
end
