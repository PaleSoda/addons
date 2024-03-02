bKeypads.KeypadLinking = {}
bKeypads.KeypadLinking.Links = {}

if SERVER then
	for _, keypad in ipairs(ents.GetAll()) do
		if keypad.bKeypad then
			keypad:SetParentKeypad(NULL)
		end
	end

	local function undoLink(undoTbl, selectedKeypad, targetKeypad)
		if IsValid(targetKeypad) and targetKeypad:GetParentKeypad() == selectedKeypad then
			targetKeypad:SetParentKeypad(NULL)
			return true
		end
		return false
	end
	function bKeypads.KeypadLinking:Link(selectedKeypad, targetKeypad, ply)
		targetKeypad:SetParentKeypad(selectedKeypad)

		local persisting = false
		if bKeypads.Persistence:IsPersisting(targetKeypad) then
			persisting = true
			bKeypads.Persistence:CommitKeypad(targetKeypad)
		end
		if bKeypads.Persistence:IsPersisting(selectedKeypad) then
			persisting = true
			bKeypads.Persistence:CommitKeypad(selectedKeypad)
		end

		if IsValid(ply) then
			if not persisting then
				undo.Create("bKeypads_Keypad_Link")
					undo.AddFunction(undoLink, selectedKeypad, targetKeypad)
					undo.SetPlayer(ply)
				undo.Finish()
			end
			hook.Run("bKeypads.Link.Keypad", ply, selectedKeypad, targetKeypad)
		end
	end

	function bKeypads.KeypadLinking:Unlink(selectedKeypad, targetKeypad, ply)
		local canLink, source, target = bKeypads.KeypadLinking:TranslatePair(selectedKeypad, targetKeypad)
		if canLink then
			if IsValid(ply) then
				hook.Run("bKeypads.Unlink.Keypad", ply, source, target)
			end
			target:SetParentKeypad(NULL)

			if bKeypads.Persistence:IsPersisting(target) then
				bKeypads.Persistence:CommitKeypad(target)
			end
			if bKeypads.Persistence:IsPersisting(source) then
				bKeypads.Persistence:CommitKeypad(source)
			end
		end
	end
end

function bKeypads.KeypadLinking:TranslatePair(selectedKeypad, targetKeypad)
	if selectedKeypad == targetKeypad then return false end

	local selectedKeypadProxy = selectedKeypad:LinkProxy()
	local targetKeypadProxy = targetKeypad:LinkProxy()

	if selectedKeypadProxy == targetKeypadProxy then
		if selectedKeypad:IsParentKeypad() then
			return true, selectedKeypad, targetKeypad
		elseif targetKeypad:IsParentKeypad() then
			return true, targetKeypad, selectedKeypad
		else
			return true, selectedKeypadProxy, selectedKeypad
		end
	elseif selectedKeypadProxy:IsParentKeypad() and targetKeypadProxy:IsParentKeypad() then
		return false
	elseif targetKeypadProxy:IsParentKeypad() then
		return true, targetKeypadProxy, selectedKeypadProxy
	else
		return true, selectedKeypadProxy, targetKeypadProxy
	end
end

if SERVER then
	hook.Add("EntityRemoved", "bKeypads.Linking.EntityRemoved", function(keypad)
		if not keypad.bKeypad then return end
		if IsValid(keypad) and IsValid(bKeypads.KeypadLinking.Links[keypad]) then
			bKeypads.KeypadLinking:Unlink(bKeypads.KeypadLinking.Links[keypad], keypad)
		end
		bKeypads.KeypadLinking.Links[keypad] = nil
	end)
end