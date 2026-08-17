local Drawing=Drawing local function ValidateDrawingLibrary()if typeof(Drawing)
~='table'then return false end if typeof(Drawing.new)~='function'then return
false end local supported_types={'Line','Square','Text','Triangle','Circle'}for
_,object_type in ipairs(supported_types)do local ok,object=pcall(Drawing.new,
object_type)if not ok or typeof(object.Remove)~='function'or not object.
__OBJECT_EXISTS then return false end object:Remove()end pcall(function()if
typeof(Drawing.clear)=='function'then Drawing.clear()end end)return true end if
not ValidateDrawingLibrary()then return{}end local function GetService(name)
local service=game:GetService(name)return cloneref and cloneref(service)or
service end local function RandomName()local pool=
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]]local t=table.
create(16)for i=1,16 do local index=math.random(1,#pool)t[i]=pool:sub(index,
index)end return table.concat(t)end local RunService=GetService('RunService')
local Players=GetService('Players')local Workspace=GetService('Workspace')local
LocalPlayer=Players.LocalPlayer local camera=Workspace.CurrentCamera local
container=Instance.new('Folder')container.Name=RandomName()container.Parent=
GetService('CoreGui')local floor=math.floor local round=math.round local sin=
math.sin local cos=math.cos local clear=table.clear local find=table.find local
create=table.create local lerpColor=Color3.new().Lerp local function Vector2Min(
a,b)return Vector2.new(math.min(a.X,b.X),math.min(a.Y,b.Y))end local function
Vector2Max(a,b)return Vector2.new(math.max(a.X,b.X),math.max(a.Y,b.Y))end
local function Vector3Min(a,b)return Vector3.new(math.min(a.X,b.X),math.min(a.Y,
b.Y),math.min(a.Z,b.Z))end local function Vector3Max(a,b)return Vector3.new(math
.max(a.X,b.X),math.max(a.Y,b.Y),math.max(a.Z,b.Z))end local function Vector2Lerp
(a,b,t)return Vector2.new(a.X+(b.X-a.X)*t,a.Y+(b.Y-a.Y)*t)end local
kHealthBarOffset=Vector2.new(5,0)local kHealthTextOffset=Vector2.new(3,0)local
kNameOffset=Vector2.new(0,2)local kDistanceOffset=Vector2.new(0,2)local
kArrowMargin=25 local kCubeVertices={Vector3.new(-1,-1,-1),Vector3.new(-1,1,-1),
Vector3.new(-1,1,1),Vector3.new(-1,-1,1),Vector3.new(1,-1,-1),Vector3.new(1,1,-1
),Vector3.new(1,1,1),Vector3.new(1,-1,1)}local function IsBodyPart(name)return
name=='Head'or name:find('Torso')or name:find('Arm')or name:find('Leg')end
local function GetBoundingBox(parts)local min_point,max_point for i=1,#parts do
local part=parts[i]local size=part.Size local lower=(part.CFrame-size*0.5).
Position local upper=(part.CFrame+size*0.5).Position min_point=min_point and
Vector3Min(min_point,lower)or lower max_point=max_point and Vector3Max(max_point
,upper)or upper end if not min_point or not max_point then return nil end local
center=(min_point+max_point)*0.5 local front=Vector3.new(center.X,center.Y,
max_point.Z)return CFrame.new(center,front),max_point-min_point end
local function WorldToScreen(world_position)local screen_point,on_screen=camera:
WorldToViewportPoint(world_position)return Vector2.new(screen_point.X,
screen_point.Y),on_screen,screen_point.Z end local function CalculateCorners(
box_cframe,box_size)local projected=create(#kCubeVertices)for index=1,#
kCubeVertices do local point,visible=WorldToScreen((box_cframe+box_size*0.5*
kCubeVertices[index]).Position)if not visible then return nil end projected[
index]=point end local min_point=projected[1]local max_point=projected[1]for
index=2,#projected do min_point=Vector2Min(min_point,projected[index])max_point=
Vector2Max(max_point,projected[index])end return{corners=projected,topLeft=
Vector2.new(floor(min_point.X),floor(min_point.Y)),topRight=Vector2.new(floor(
max_point.X),floor(min_point.Y)),bottomLeft=Vector2.new(floor(min_point.X),
floor(max_point.Y)),bottomRight=Vector2.new(floor(max_point.X),floor(max_point.Y
))}end local function RotateVector(vector,radians)local c=cos(radians)local s=
sin(radians)return Vector2.new(vector.X*c-vector.Y*s,vector.X*s+vector.Y*c)end
local function CreateDrawing(class,properties)local drawing=Drawing.new(class)
for property,value in next,properties do drawing[property]=value end return
drawing end local function ParseColor(self,color,is_outline)if color==
'Team Color'or(self.interface.sharedSettings.useTeamColor and is_outline)then
return self.teamColor or self.interface.GetTeamColor(self.player)or Color3.new(1
,1,1)end return color end local function CreateLine(properties)return
CreateDrawing('Line',properties)end local function CreateSquare(properties)
return CreateDrawing('Square',properties)end local function CreateText(
properties)return CreateDrawing('Text',properties)end local function
CreateTriangle(properties)return CreateDrawing('Triangle',properties)end local
EspObject={}EspObject.__index=EspObject function EspObject.new(player,interface)
local self=setmetatable({},EspObject)self.player=assert(player,
'Missing argument #1 (Player expected)')self.interface=assert(interface,
'Missing argument #2 (table expected)')self:Construct()return self end function
EspObject:Construct()self.bin={}self.charCache={}self.childCount=0 self.
character=nil self.onScreen=false self.inRange=true self.enabled=false self.
distance=0 self.direction=nil self.corners={corners={},topLeft=Vector2.zero,
topRight=Vector2.zero,bottomLeft=Vector2.zero,bottomRight=Vector2.zero}self.
drawings={box=CreateSquare({Thickness=1,Visible=false}),boxInnerOutline=
CreateSquare({Thickness=1,Visible=false}),boxOutline=CreateSquare({Thickness=1,
Visible=false}),boxOuterOutline=CreateSquare({Thickness=1,Visible=false}),
boxFill=CreateSquare({Filled=true,Visible=false}),healthBar=CreateLine({
Thickness=2,Visible=false}),healthBarOutline=CreateLine({Thickness=1,Visible=
false}),healthText=CreateText({Center=true,Visible=false}),nameText=CreateText({
Center=true,Visible=false}),distanceText=CreateText({Center=true,Visible=false})
,weaponText=CreateText({Center=true,Visible=false}),tracer=CreateLine({Thickness
=1,Visible=false}),tracerOutline=CreateLine({Thickness=1,Visible=false}),
offScreenArrow=CreateTriangle({Filled=true,Visible=false}),offScreenArrowOutline
=CreateTriangle({Thickness=1,Visible=false})}self.skeletonLines={CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false}),CreateLine({
Thickness=1,Visible=false}),CreateLine({Thickness=1,Visible=false})}self.
bodyParts={}self.screenCache={}end function EspObject:Destruct()for _,drawing in
pairs(self.drawings)do pcall(function()drawing:Destroy()end)end for _,line in
ipairs(self.skeletonLines)do pcall(function()line:Destroy()end)end self.drawings
={}self.skeletonLines={}end function EspObject:GetOptions()return self.interface
.teamSettings[self.interface.GetTeamKey(self.interface,self.player)]end function
EspObject:CollectBodyParts(character)local children=character:GetChildren()if
self.character~=character or self.childCount~=#children then self.character=
character self.childCount=#children clear(self.charCache)clear(self.bodyParts)
for index=1,#children do local part=children[index]if part:IsA('BasePart')then
if IsBodyPart(part.Name)then self.charCache[#self.charCache+1]=part end self.
bodyParts[part.Name]=part end end end end function EspObject:
