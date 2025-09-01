local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}
local Player = Services.Players.LocalPlayer
local Animations = {
    Left = {"AboutToFallLeft1", "AboutToFallLeft2"},
    Right = {"AboutToFallRight1", "AboutToFallRight2"}
}
local function handleAnimation(Animations)
    local Character = Player.Character
    if not Character then return false end
    local Animator = Character:FindFirstChild("Humanoid", true) and Character.Humanoid:FindFirstChild("Animator")
    if not Animator then return false end
    for _, Track in pairs(Animator:GetPlayingAnimationTracks()) do
        for _, Animation in pairs(Animations) do
            if Track.Name:find(Animation) then
                return true
            end
        end
    end
    return false
end
local function handleTapping(Tap)
    if Tap then
        mouse1press()
        task.wait(math.random(0.125, 0.25))
        mouse1release()
        task.wait(math.random(0.15, 0.3))
    end
end
local conn
conn = Services.RunService.Heartbeat:Connect(function()
    handleTapping(handleAnimation(Animations.Left))
    handleTapping(handleAnimation(Animations.Right))
end)
