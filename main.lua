--[[ Obfuscated by Gemini ]]

local S = {
 [1] = "Players", [2] = "RunService", [3] = "ReplicatedStorage", [4] = "Mobs", [5] = "Remotes",
 [6] = "DamageMob", [7] = "ScreenGui", [8] = "MobDamagerGui", [9] = "PlayerGui", [10] = "TextBox",
 [11] = "Mob name...", [12] = "HumanoidRootPart", [13] = "TextButton", [14] = " OFF", [15] = " ON",
 [16] = "Closest", [17] = "Typed", [18] = "Text", [19] = "MouseButton1Click", [20] = "BackgroundColor3",
 [21] = "Heartbeat", [22] = "Size", [23] = "Position", [24] = "PlaceholderText", [25] = "ClearTextOnFocus",
 [26] = "Parent"
};

local G_1, G_2, G_3, G_4, G_5, G_6, G_7 = game, workspace, Instance, UDim2, Color3, math, ipairs;

local V_1 = G_1:GetService(S[1]);
local V_2 = G_1:GetService(S[2]);
local V_3 = G_1:GetService(S[3]);

local V_4 = V_1.LocalPlayer;
local V_5 = G_2:WaitForChild(S[4]);
local V_6 = V_3:WaitForChild(S[5]):WaitForChild(S[6]);

local V_7 = G_3.new(S[7]);
V_7.Name = S[8];
V_7[S[26]] = V_4:WaitForChild(S[9]);

local V_8 = G_3.new(S[10]);
V_8[S[22]] = G_4.new(0, 150, 0, 30);
V_8[S[23]] = G_4.new(0, 10, 0, 60);
V_8[S[24]] = S[11];
V_8[S[18]] = "";
V_8[S[25]] = (1==0);
V_8[S[26]] = V_7;

local function F_1()
 local l_1 = V_4.Character and V_4.Character:FindFirstChild(S[12]);
 if not l_1 then return nil; end
 local l_2, l_3 = nil, G_6.huge;
 for _, l_4 in G_7(V_5:GetChildren()) do
  local l_5 = l_4:FindFirstChild(S[12]);
  if l_5 then
   local l_6 = (l_5[S[23]] - l_1[S[23]]).Magnitude;
   if l_6 < l_3 then
    l_3, l_2 = l_6, l_4;
   end
  end
 end
 return l_2;
end

local function F_2(p_1, p_2, p_3)
 local l_1 = G_3.new(S[13]);
 l_1[S[22]] = G_4.new(0, 120, 0, 40);
 l_1[S[23]] = G_4.new(0, 10, 0, p_2);
 l_1[S[18]] = p_1 .. S[14];
 l_1[S[20]] = G_5.fromRGB(255, 100, 100);
 l_1[S[26]] = V_7;

 local l_2, l_3 = nil, (1==0);
 local function l_4()
  local l_5 = p_3();
  if l_5 then
   V_6:InvokeServer(l_5);
  end
 end

 l_1[S[19]]:Connect(function()
  l_3 = not l_3;
  if l_3 then
   l_1[S[18]] = p_1 .. S[15];
   l_1[S[20]] = G_5.fromRGB(100, 255, 100);
   l_2 = V_2[S[21]]:Connect(l_4);
  else
   l_1[S[18]] = p_1 .. S[14];
   l_1[S[20]] = G_5.fromRGB(255, 100, 100);
   if l_2 then l_2:Disconnect(); l_2 = nil; end
  end
 end)
end

F_2(S[16], 10, F_1);
F_2(S[17], 100, function()
 local l_1 = V_8[S[18]];
 if l_1 ~= "" then
  return V_5:FindFirstChild(l_1);
 end
end)
