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
	--- If the system should be automatically activated.
	activate_automatically = settings.get_bool("autodrops_activate", true),
	
	--- If the system is currently active/has been activated.
	active = false,
	
	--- The split method that is used. Possible values are "stack", "random"
	-- and "single", defaults to "single". "stack" means that the full stack
	-- as provided is dropped, "random" splits the provided stack randomly and
	-- "single" splits the provided stack into individual items.
	split = settings.get_string("autodrops_split", "single"),
	
	--- The maximum velocity for new spawned items, defaults to 2, 4, 2.
	velocity = settings.get_pos3d("autodrops_velocity", { x = 2, y = 4, z = 2 })
}


--- Activates the autodrops system, if it has not been disabled in
-- configuration by setting "autodrops_activate" to false.
function autodrops.activate()
	if autodrops.activate_automatically then
		autodrops.activate_internal()
	end
end

--- Activates the autodrops system without checking the configuration. Does
-- nothing on multiple calls.
function autodrops.activate_internal()
	if not autodrops.active then
		minetestex.register_on_nodedrops(autodrops.node_drops_handler)
		
		autodrops.active = true
	end
end

--- Drops the given ItemStacks at the given position, based on the settings.
--
-- @param position The position at which to drop the items.
-- @param stacks The List of ItemStacks to drop.
function autodrops.drop(position, stacks)
	itemutil.blop(
		position,
		stacks:to_table(),
		autodrops.velocity.x,
		autodrops.velocity.y,
		autodrops.velocity.z,
		autodrops.split)
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

