--!strict
local Players = game:GetService("Players")
local RE = Instance.new("RemoteEvent")
RE.Name = "RequestMeleeHit"
RE.Parent = game.ReplicatedStorage

local COOLDOWN = 0.35
local MAX_RANGE = 10 -- studs, enforce on server
local DAMAGE = 18

local lastHit = {} :: {[Player]: number}

local function getCharacterRoot(model: Model)
	local hrp = model:FindFirstChild("HumanoidRootPart")
	return hrp and hrp:IsA("BasePart") and hrp or nil
end

local function getValidTargets(attackerChar: Model, origin: Vector3, range: number)
	local targets = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character ~= attackerChar then
			local root = getCharacterRoot(plr.Character)
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				if (root.Position - origin).Magnitude <= range then
					table.insert(targets, plr.Character)
				end
			end
		end
	end
	return targets
end

RE.OnServerEvent:Connect(function(plr: Player, swingOrigin: Vector3, facing: Vector3)
	-- basic anti-spam
	local now = time()
	if (lastHit[plr] or 0) > now - COOLDOWN then return end

	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and getCharacterRoot(char)
	if not (hum and root and hum.Health > 0) then return end

	-- Server enforces range and performs targeting
	local targets = getValidTargets(char, root.Position, MAX_RANGE)
	if #targets == 0 then
		lastHit[plr] = now
		return
	end

	-- Optionally weight by angle to the player's facing
	local best, bestScore = nil, math.huge
	for _, target in ipairs(targets) do
		local tRoot = getCharacterRoot(target)
		if tRoot then
			local dir = (tRoot.Position - root.Position).Unit
			local angle = math.acos(math.clamp(dir:Dot(facing.Unit), -1, 1))
			local dist = (tRoot.Position - root.Position).Magnitude
			local score = angle * 2 + dist / MAX_RANGE
			if score < bestScore then
				best, bestScore = target, score
			end
		end
	end

	if best then
		local tHum = best:FindFirstChildOfClass("Humanoid")
		if tHum and tHum.Health > 0 then
			tHum:TakeDamage(DAMAGE)
			lastHit[plr] = now
		end
	end
end)
