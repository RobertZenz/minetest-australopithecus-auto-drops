--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- Autodrops is a system which enables that drops from nodes become items
-- which are dropped on the ground, instead of being send directly to
-- the player inventory.
autodrops = {
	--- The split method that is used. Possible values are "stack", "random"
	-- and "single", defaults to "single". "stack" means that the full stack
	-- as provided is dropped, "random" splits the provided stack randomly and
	-- "single" splits the provided stack into individual items.
	split = settings.get_string("autodrops_split", "single")
}


-- Activates the autodrops system.
function autodrops.activate()
	if settings.get_bool("autodrops_active", true) then
		minetestex.register_on_nodedrops(autodrops.node_drops_handler)
	end
end

--- Drops the given ItemStacks at the given position, based on the settings.
--
-- @param position The position at which to drop the items.
-- @param stacks The array of ItemStacks to drop.
function autodrops.drop(position, stacks)
	for index, stack in ipairs(stacks) do
		if autodrops.split == "random" then
			autodrops.drop_random(position, stack)
		elseif autodrops.split == "single" then
			autodrops.drop_single(position, stack)
		elseif autodrops.split == "stack" then
			autodrops.drop_stack(position, stack)
		end
	end
end

--- Drops the given stack from the given position by splitting it into random
-- amounts.
--
-- @param position The position at which the items should spawn.
-- @param stack The ItemStack to drop.
function autodrops.drop_random(position, stack)
	local name = stack:get_name()
	local remaining = stack:get_count()
	
	while remaining > 0 do
		local count = random.next_int(1, remaining + 1)
		local item_string = name .. " " .. tostring(count)
		
		itemutil.blop(position, item_string)
		
		remaining = remaining - count;
	end
end

--- Drops the given stack from the given position by splitting it into single
-- items.
--
-- @param position The position at which the items should spawn.
-- @param stack The ItemStack to drop.
function autodrops.drop_single(position, stack)
	local name = stack:get_name()
	
	for counter = 1, stack:get_count(), 1 do
		itemutil.blop(position, name, 4, 3, 4)
	end
end

--- Drops the given stack from the given position.
--
-- @param position The position at which the items should spawn.
-- @param stack The ItemStack to drop.
function autodrops.drop_stack(position, stack)
	itemutil.blop(position, stack:to_string())
end

--- The handler which is registered for handling the node drops.
--
-- @param position The position at which the drop occured.
-- @param drops The array of ItemStacks which are dropped.
-- @param player The player which originated the event.
-- @param handled If the event has already been handled or not.
-- @return true, because the event has been handled by this function.
function autodrops.node_drops_handler(position, drops, player, handled)
	autodrops.drop(position, drops)
	return true
end

