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
CalculateBoundingCorners()local boxCFrame,boxSize=GetBoundingBox(self.charCache)
if not boxCFrame then return false end local corners=CalculateCorners(boxCFrame,
boxSize)if not corners then return false end self.corners=corners return true
end function EspObject:ProjectPart(part)if not part then return nil,false end
local cache=self.screenCache local entry=cache[part]if entry then return entry[1
],entry[2]end local pos,onScreen=WorldToScreen(part.Position)cache[part]={pos,
onScreen}return pos,onScreen end function EspObject:Update()local options=self:
GetOptions()local character=self.interface.GetCharacter(self.player)self.health,
self.maxHealth=self.interface.GetHealth(self.player)self.weapon=self.interface.
GetWeapon(self.player)self.teamColor=self.interface.GetTeamColor(self.player)
self.enabled=options.enabled and character and not(#self.interface.whitelist>0
and not find(self.interface.whitelist,self.player.UserId))self.inRange=false
self.screenCache={}if not self.enabled then self.onScreen=false return end local
head=character and character:FindFirstChild('Head')if not head then self.
onScreen=false return end local viewportCenter=camera.ViewportSize*0.5 local
headPos=select(1,WorldToScreen(head.Position))local distance=(camera.CFrame.
Position-head.Position).Magnitude self.distance=distance local delta=headPos-
viewportCenter self.direction=delta.Magnitude>0 and delta.Unit or Vector2.new(0,
-1)if self.interface.sharedSettings.limitDistance and distance>self.interface.
sharedSettings.maxDistance then self.onScreen=false self.inRange=false return
end self.inRange=true self:CollectBodyParts(character)self.onScreen=self:
CalculateBoundingCorners()end function EspObject:SetDrawingVisible(drawing,
visible)if drawing.Visible~=visible then drawing.Visible=visible end end
function EspObject:RenderBox(options)local box=self.drawings.box local
inner_outline=self.drawings.boxInnerOutline local outline=self.drawings.
boxOutline local outer_outline=self.drawings.boxOuterOutline local fill=self.
drawings.boxFill local size=self.corners.bottomRight-self.corners.topLeft local
is_target=options.targetHighlight and self.interface._target==self.player local
box_color=is_target and options.targetHighlightColor[1]or options.boxColor[1]
local outline_color=is_target and options.targetHighlightColor[1]or options.
boxOutlineColor[1]local fill_color=is_target and options.targetHighlightColor[1]
or options.boxFillColor[1]box.Position=self.corners.topLeft box.Size=size box.
Color=ParseColor(self,box_color)box.Transparency=options.boxColor[2]
inner_outline.Position=self.corners.topLeft+Vector2.new(1,1)inner_outline.Size=
size-Vector2.new(2,2)inner_outline.Color=ParseColor(self,Color3.fromRGB(20,20,22
),true)inner_outline.Transparency=options.boxOutlineColor[2]outline.Position=
self.corners.topLeft outline.Size=size outline.Color=ParseColor(self,
outline_color,true)outline.Transparency=options.boxOutlineColor[2]outer_outline.
Position=self.corners.topLeft-Vector2.new(2,2)outer_outline.Size=size+Vector2.
new(4,4)outer_outline.Color=ParseColor(self,Color3.fromRGB(20,20,22),true)
outer_outline.Transparency=options.boxOutlineColor[2]fill.Position=self.corners.
topLeft fill.Size=size fill.Color=ParseColor(self,fill_color)fill.Transparency=
options.boxFillColor[2]end function EspObject:RenderHealth(options)local ratio=
self.maxHealth>0 and math.clamp(self.health/self.maxHealth,0,1)or 0 local
health_line=self.drawings.healthBar local health_outline=self.drawings.
healthBarOutline local from=self.corners.topLeft-kHealthBarOffset local to=self.
corners.bottomLeft-kHealthBarOffset health_line.From=Vector2Lerp(to,from,ratio)
health_line.To=to health_line.Color=lerpColor(options.dyingColor,options.
healthyColor,ratio)health_line.Transparency=1 health_outline.From=from-Vector2.
new(0,1)health_outline.To=to+Vector2.new(0,1)health_outline.Color=ParseColor(
self,options.healthBarOutlineColor[1],true)health_outline.Transparency=options.
healthBarOutlineColor[2]end function EspObject:RenderLabel(drawing,text,color,
outline_color,outline,position)if drawing.Text~=text then drawing.Text=text end
if drawing.Size~=self.interface.sharedSettings.textSize then drawing.Size=self.
interface.sharedSettings.textSize end if drawing.Font~=self.interface.
sharedSettings.textFont then drawing.Font=self.interface.sharedSettings.textFont
end local parsedColor=ParseColor(self,color[1])if drawing.Color~=parsedColor
then drawing.Color=parsedColor end if drawing.Transparency~=color[2]then drawing
.Transparency=color[2]end if drawing.Outline~=outline then drawing.Outline=
outline end local outlineColorParsed=ParseColor(self,outline_color[1],true)if
drawing.OutlineColor~=outlineColorParsed then drawing.OutlineColor=
outlineColorParsed end if drawing.Position~=position then drawing.Position=
position end end function EspObject:RenderTracer(options)local center=(self.
corners.bottomLeft+self.corners.bottomRight)*0.5 local origin=options.
tracerOrigin=='Middle'and camera.ViewportSize*0.5 or options.tracerOrigin=='Top'
and camera.ViewportSize*Vector2.new(0.5,0)or camera.ViewportSize*Vector2.new(0.5
,1)local tracer=self.drawings.tracer local tracer_outline=self.drawings.
tracerOutline local is_target=options.targetHighlight and self.interface._target
==self.player local tracer_color=is_target and options.targetHighlightColor[1]or
options.tracerColor[1]tracer.From=origin tracer.To=center tracer.Color=
ParseColor(self,tracer_color)tracer.Transparency=options.tracerColor[2]
tracer_outline.From=origin tracer_outline.To=center tracer_outline.Color=
ParseColor(self,options.tracerOutlineColor[1],true)tracer_outline.Transparency=
options.tracerOutlineColor[2]end local function DrawBone(self,line,fromPart,
toPart,color,transparency)if not fromPart or not toPart or fromPart==toPart then
line.Visible=false return end local fromPos,fromOnScreen=self:ProjectPart(
fromPart)local toPos,toOnScreen=self:ProjectPart(toPart)if fromOnScreen and
toOnScreen then line.From=fromPos line.To=toPos line.Color=color line.
Transparency=transparency line.Visible=true else line.Visible=false end end
function EspObject:RenderSkeleton(options)local character=self.character if not
character then return end local head=self.bodyParts['Head']if not head then
return end local is_r15=self.bodyParts['UpperTorso']~=nil local is_target=
options.targetHighlight and self.interface._target==self.player local box_color=
is_target and options.targetHighlightColor[1]or options.boxColor[1]local color=
ParseColor(self,box_color,true)local transparency=options.boxColor[2]local
lineIndex=1 if is_r15 then local upperTorso=self.bodyParts['UpperTorso']local
lowerTorso=self.bodyParts['LowerTorso']if lineIndex<=#self.skeletonLines then
DrawBone(self,self.skeletonLines[lineIndex],head,upperTorso,color,transparency)
lineIndex=lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,
self.skeletonLines[lineIndex],upperTorso,lowerTorso,color,transparency)lineIndex
=lineIndex+1 end local leftUpperArm=self.bodyParts['LeftUpperArm']local
leftLowerArm=self.bodyParts['LeftLowerArm']local leftHand=self.bodyParts[
'LeftHand']if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],upperTorso,leftUpperArm,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],leftUpperArm,leftLowerArm,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],leftLowerArm,leftHand,color,transparency)lineIndex=
lineIndex+1 end local rightUpperArm=self.bodyParts['RightUpperArm']local
rightLowerArm=self.bodyParts['RightLowerArm']local rightHand=self.bodyParts[
'RightHand']if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],upperTorso,rightUpperArm,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],rightUpperArm,rightLowerArm,color,transparency)
lineIndex=lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,
self.skeletonLines[lineIndex],rightLowerArm,rightHand,color,transparency)
lineIndex=lineIndex+1 end local leftUpperLeg=self.bodyParts['LeftUpperLeg']local
leftLowerLeg=self.bodyParts['LeftLowerLeg']local leftFoot=self.bodyParts[
'LeftFoot']if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],lowerTorso,leftUpperLeg,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],leftUpperLeg,leftLowerLeg,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],leftLowerLeg,leftFoot,color,transparency)lineIndex=
lineIndex+1 end local rightUpperLeg=self.bodyParts['RightUpperLeg']local
rightLowerLeg=self.bodyParts['RightLowerLeg']local rightFoot=self.bodyParts[
'RightFoot']if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],lowerTorso,rightUpperLeg,color,transparency)lineIndex=
lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],rightUpperLeg,rightLowerLeg,color,transparency)
lineIndex=lineIndex+1 end if lineIndex<=#self.skeletonLines then DrawBone(self,
self.skeletonLines[lineIndex],rightLowerLeg,rightFoot,color,transparency)
lineIndex=lineIndex+1 end else local torso=self.bodyParts['Torso']if lineIndex<=
#self.skeletonLines then DrawBone(self,self.skeletonLines[lineIndex],head,torso,
color,transparency)lineIndex=lineIndex+1 end local leftArm=self.bodyParts[
'Left Arm']if lineIndex<=#self.skeletonLines then DrawBone(self,self.
skeletonLines[lineIndex],torso,leftArm,color,transparency)lineIndex=lineIndex+1
end local rightArm=self.bodyParts['Right Arm']if lineIndex<=#self.skeletonLines
then DrawBone(self,self.skeletonLines[lineIndex],torso,rightArm,color,
transparency)lineIndex=lineIndex+1 end local leftLeg=self.bodyParts['Left Leg']
if lineIndex<=#self.skeletonLines then DrawBone(self,self.skeletonLines[
lineIndex],torso,leftLeg,color,transparency)lineIndex=lineIndex+1 end local
rightLeg=self.bodyParts['Right Leg']if lineIndex<=#self.skeletonLines then
DrawBone(self,self.skeletonLines[lineIndex],torso,rightLeg,color,transparency)
lineIndex=lineIndex+1 end end for i=lineIndex,#self.skeletonLines do self.
skeletonLines[i].Visible=false end end function EspObject:RenderOffscreenArrow(
options)local arrow=self.drawings.offScreenArrow local outline=self.drawings.
offScreenArrowOutline local center=camera.ViewportSize*0.5 local target_position
=center+self.direction*options.offScreenArrowRadius local clamped=Vector2.new(
math.clamp(target_position.X,kArrowMargin,camera.ViewportSize.X-kArrowMargin),
math.clamp(target_position.Y,kArrowMargin,camera.ViewportSize.Y-kArrowMargin))
local left=RotateVector(self.direction,0.45)*options.offScreenArrowSize local
right=RotateVector(self.direction,-0.45)*options.offScreenArrowSize local
is_target=options.targetHighlight and self.interface._target==self.player local
offscreen_arrow_color=is_target and options.targetHighlightColor[1]or options.
offScreenArrowColor[1]arrow.PointA=clamped arrow.PointB=clamped-left arrow.
PointC=clamped-right arrow.Color=ParseColor(self,offscreen_arrow_color)arrow.
Transparency=options.offScreenArrowColor[2]outline.PointA=clamped outline.PointB
=clamped-left outline.PointC=clamped-right outline.Color=ParseColor(self,options
.offScreenArrowOutlineColor[1],true)outline.Transparency=options.
offScreenArrowOutlineColor[2]end function EspObject:HideAll()for _,drawing in
pairs(self.drawings)do if drawing and drawing.__OBJECT_EXISTS and drawing.
Visible~=nil then drawing.Visible=false end end for _,line in ipairs(self.
skeletonLines)do line.Visible=false end end function EspObject:Render()local
options=self:GetOptions()if not self.enabled or not self.inRange then self:
HideAll()return end if not self.onScreen then self:HideAll()if options.
offScreenArrow and self.direction then self:RenderOffscreenArrow(options)self:
SetDrawingVisible(self.drawings.offScreenArrow,true)self:SetDrawingVisible(self.
drawings.offScreenArrowOutline,options.offScreenArrowOutline)end return end if
options.box then self:RenderBox(options)self:SetDrawingVisible(self.drawings.box
,true)self:SetDrawingVisible(self.drawings.boxOutline,options.boxOutline)self:
SetDrawingVisible(self.drawings.boxInnerOutline,true)self:SetDrawingVisible(self
.drawings.boxOuterOutline,true)else self:SetDrawingVisible(self.drawings.box,
false)self:SetDrawingVisible(self.drawings.boxOutline,false)self:
SetDrawingVisible(self.drawings.boxInnerOutline,false)self:SetDrawingVisible(
self.drawings.boxOuterOutline,false)end if options.boxFill then self:
SetDrawingVisible(self.drawings.boxFill,true)else self:SetDrawingVisible(self.
drawings.boxFill,false)end if options.healthBar then self:RenderHealth(options)
self:SetDrawingVisible(self.drawings.healthBar,true)self:SetDrawingVisible(self.
drawings.healthBarOutline,options.healthBarOutline)else self:SetDrawingVisible(
self.drawings.healthBar,false)self:SetDrawingVisible(self.drawings.
healthBarOutline,false)end if options.healthText then local text=tostring(round(
self.health))..'hp'self:RenderLabel(self.drawings.healthText,text,options.
healthTextColor,options.healthTextOutlineColor,options.healthTextOutline,Vector2
.zero)self.drawings.healthText.Position=(self.corners.topLeft+self.corners.
topRight)*0.5-Vector2.new(0,self.drawings.healthText.TextBounds.Y)-
kHealthTextOffset self:SetDrawingVisible(self.drawings.healthText,true)else self
:SetDrawingVisible(self.drawings.healthText,false)end if options.name then self:
RenderLabel(self.drawings.nameText,self.player.DisplayName,options.nameColor,
options.nameOutlineColor,options.nameOutline,Vector2.zero)self.drawings.nameText
.Position=(self.corners.topLeft+self.corners.topRight)*0.5-Vector2.new(0,self.
drawings.nameText.TextBounds.Y)-kNameOffset self:SetDrawingVisible(self.drawings
.nameText,true)else self:SetDrawingVisible(self.drawings.nameText,false)end if
options.distance then local position=(self.corners.bottomLeft+self.corners.
bottomRight)*0.5+kDistanceOffset self:RenderLabel(self.drawings.distanceText,
tostring(round(self.distance))..' studs',options.distanceColor,options.
distanceOutlineColor,options.distanceOutline,position)self:SetDrawingVisible(
self.drawings.distanceText,true)else self:SetDrawingVisible(self.drawings.
distanceText,false)end if options.weapon then local offset=self.drawings.
distanceText.Visible and kDistanceOffset+Vector2.new(0,self.drawings.
distanceText.TextBounds.Y)or Vector2.zero local position=(self.corners.
bottomLeft+self.corners.bottomRight)*0.5+offset self:RenderLabel(self.drawings.
weaponText,self.weapon or'Unknown',options.weaponColor,options.
weaponOutlineColor,options.weaponOutline,position)self:SetDrawingVisible(self.
drawings.weaponText,true)else self:SetDrawingVisible(self.drawings.weaponText,
false)end if options.tracer then self:RenderTracer(options)self:
SetDrawingVisible(self.drawings.tracer,true)self:SetDrawingVisible(self.drawings
.tracerOutline,options.tracerOutline)else self:SetDrawingVisible(self.drawings.
tracer,false)self:SetDrawingVisible(self.drawings.tracerOutline,false)end if
options.skeletons then self:RenderSkeleton(options)else for _,line in ipairs(
self.skeletonLines)do line.Visible=false end end if not self.onScreen and
options.offScreenArrow and self.direction then self:RenderOffscreenArrow(options
)self:SetDrawingVisible(self.drawings.offScreenArrow,true)self:
SetDrawingVisible(self.drawings.offScreenArrowOutline,options.
offScreenArrowOutline)else self:SetDrawingVisible(self.drawings.offScreenArrow,
false)self:SetDrawingVisible(self.drawings.offScreenArrowOutline,false)end end
local ChamObject={}ChamObject.__index=ChamObject local chamGui=container:
FindFirstChild('ChamGui')or(function()local gui=Instance.new('ScreenGui')gui.
Name='ChamGui'gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.ZIndexBehavior=
Enum.ZIndexBehavior.Sibling gui.Parent=container return gui end)()local
GlobalChamRenderer={Viewport=Instance.new('ViewportFrame'),Camera=Instance.new(
'Camera'),Chams={}}GlobalChamRenderer.Viewport=Instance.new('ViewportFrame')
GlobalChamRenderer.Viewport.Size=UDim2.fromScale(1,1)GlobalChamRenderer.Viewport
.Position=UDim2.fromScale(0,0)GlobalChamRenderer.Viewport.BackgroundTransparency
=1 GlobalChamRenderer.Viewport.Ambient=Color3.new(1,1,1)GlobalChamRenderer.
Viewport.LightColor=Color3.new(1,1,1)GlobalChamRenderer.Viewport.Parent=chamGui
GlobalChamRenderer.Camera=Instance.new('Camera')GlobalChamRenderer.Camera.Parent
=GlobalChamRenderer.Viewport GlobalChamRenderer.Viewport.CurrentCamera=
GlobalChamRenderer.Camera RunService.RenderStepped:Connect(function()
GlobalChamRenderer.Camera.CFrame=camera.CFrame GlobalChamRenderer.Camera.
FieldOfView=camera.FieldOfView end)function ChamObject.new(player,interface)
local self=setmetatable({},ChamObject)self.player=player self.interface=
interface self.currentCharacter=nil self.glowParts={}self.updateConnections={}
table.insert(self.updateConnections,RunService.RenderStepped:Connect(function()
self:Update()end))return self end function ChamObject:Destruct()for _,entry in
ipairs(self.glowParts)do if entry.glow then entry.glow:Destroy()end end table.
clear(self.glowParts)for _,conn in ipairs(self.updateConnections)do conn:
Disconnect()end end function ChamObject:_createGlow(character)self.glowParts={}
local bodyParts={'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm',
'LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg',
'LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot','Head',
'Torso','Left Arm','Right Arm','Left Leg','Right Leg'}local function AddPart(
partName)local part=character:FindFirstChild(partName)if not part or not part:
IsA('BasePart')or not table.find(bodyParts,partName)then return end local glow=
part:Clone()for _,child in ipairs(glow:GetDescendants())do if child:IsA('Script'
)or child:IsA('LocalScript')or child:IsA('Animator')or child:IsA('Motor6D')or
child:IsA('Weld')or child:IsA('Attachment')then child:Destroy()end end if glow:
IsA('MeshPart')then glow.TextureID=''end if glow:FindFirstChildOfClass(
'SpecialMesh')then glow:FindFirstChildOfClass('SpecialMesh').TextureId=''end
glow.Name='ChamGlow'glow.Anchored=true glow.CanCollide=false glow.CanQuery=false
glow.CanTouch=false glow.Material=self.interface.sharedSettings.chamMaterial
glow.Size=part.Size glow.CFrame=part.CFrame glow.Parent=GlobalChamRenderer.
Viewport if self.interface.sharedSettings.chamTextureId and self.interface.
sharedSettings.chamTextureId~=0 then if glow:IsA('MeshPart')then glow.TextureID=
'rbxassetid://'..tostring(self.interface.sharedSettings.chamTextureId)elseif
glow:FindFirstChildOfClass('SpecialMesh')then glow:FindFirstChildOfClass(
'SpecialMesh').TextureId='rbxassetid://'..tostring(self.interface.sharedSettings
.chamTextureId)end end table.insert(self.glowParts,{glow=glow,source=part,
lastCFrame=nil})end for _,partName in ipairs(bodyParts)do AddPart(partName)end
character.ChildAdded:Connect(function(desc)AddPart(desc.Name)end)end function
ChamObject:_applySettings(options)local isTarget=self.interface._target==self.
player local color=isTarget and ParseColor(self,options.targetHighlightColor[1])
or ParseColor(self,options.chamsFillColor[1])self.lastColor=color self.
lastTransparency=options.chamsFillColor[2]local chamMaterial=self.interface.
sharedSettings.chamMaterial local chamTextureId=self.interface.sharedSettings.
chamTextureId for _,entry in ipairs(self.glowParts)do local glow=entry.glow glow
.Color=color if self.visible~=false then glow.Transparency=options.
chamsFillColor[2]end if glow.Material~=chamMaterial then glow.Material=
chamMaterial end if chamTextureId and chamTextureId~=0 then local textureString=
'rbxassetid://'..tostring(chamTextureId)if glow.ClassName=='MeshPart'then if
glow.TextureID~=textureString then glow.TextureID=textureString end elseif glow:
FindFirstChildOfClass('SpecialMesh')then local specialMesh=glow:
FindFirstChildOfClass('SpecialMesh')if specialMesh.TextureId~=textureString then
specialMesh.TextureId=textureString end end else if glow.ClassName=='MeshPart'
then if glow.TextureID~=''then glow.TextureID=''end elseif glow:
FindFirstChildOfClass('SpecialMesh')then local specialMesh=glow:
FindFirstChildOfClass('SpecialMesh')if specialMesh.TextureId~=''then specialMesh
.TextureId=''end end end end end function ChamObject:_getContext()local options=
self.interface.teamSettings[self.interface.GetTeamKey(self.interface,self.player
)]local character=self.interface.GetCharacter(self.player)return options,
character end function ChamObject:_shouldRender(options,character)if not(options
.enabled and options.chams and character)then return false end if#self.interface
.whitelist>0 and not table.find(self.interface.whitelist,self.player.UserId)then
return false end local head=character:FindFirstChild('Head')if not head or not
head:IsDescendantOf(workspace)then return false end local distance=(camera.
CFrame.Position-head.Position).Magnitude if self.interface.sharedSettings.
limitDistance and distance>self.interface.sharedSettings.maxDistance then return
false end return true end function ChamObject:_updateCharacter(character)if
character==self.currentCharacter then return end self.currentCharacter=character
for _,entry in ipairs(self.glowParts)do if entry.glow then entry.glow:Destroy()
end end table.clear(self.glowParts)self.lastColor=nil self.lastTransparency=nil
if character and character.Parent then self:_createGlow(character)end end
function ChamObject:_updateParts()local character=self.currentCharacter if not
character then return end local validParts=0 for _,entry in ipairs(self.
glowParts)do local source=entry.source if source and source.Parent then
validParts+=1 end end if validParts~=#self.glowParts then self:_updateCharacter(
character)return end for _,entry in ipairs(self.glowParts)do local source=entry.
source local glow=entry.glow if source and source.Parent and glow then if entry.
lastCFrame~=source.CFrame then glow.CFrame=source.CFrame glow.Size=source.Size
entry.lastCFrame=source.CFrame end end end end function ChamObject:
_updateAppearance(options)self:_applySettings(options)end function ChamObject:
_setVisible(state)if self.visible==state then return end self.visible=state for
_,entry in ipairs(self.glowParts)do local glow=entry.glow if glow and glow.
Parent then glow.LocalTransparencyModifier=state and 0 or 1 end end end function
ChamObject:_updateVisibility()local options,character=self:_getContext()local
visible=self:_shouldRender(options,character)self:_setVisible(visible)end
function ChamObject:Update()local options,character=self:_getContext()local
shouldRender=self:_shouldRender(options,character)self:_setVisible(shouldRender)
if not shouldRender then return end if character~=self.currentCharacter then
self:_updateCharacter(character)end self:_updateParts()self:_updateAppearance(
options)end local InstanceObject={}InstanceObject.__index=InstanceObject
function InstanceObject.new(instance,options)local self=setmetatable({},
InstanceObject)self.instance=assert(instance,
'Missing argument #1 (Instance expected)')self.options=assert(options,
'Missing argument #2 (table expected)')self:Construct()return self end function
InstanceObject:Construct()local options=self.options options.enabled=options.
enabled~=false options.text=options.text or'{name}'options.textColor=options.
textColor or{Color3.new(1,1,1),1}options.textOutline=options.textOutline~=false
options.textOutlineColor=options.textOutlineColor or Color3.new()options.
textSize=options.textSize or 13 options.textFont=options.textFont or 2 options.
limitDistance=options.limitDistance or false options.maxDistance=options.
maxDistance or 150 self.text=CreateText({Center=true,Visible=false})self.
updateConnection=RunService.RenderStepped:Connect(function()self:Render()end)end
function InstanceObject:Destruct()if self.updateConnection then self.
updateConnection:Disconnect()end if self.text then self.text:Remove()end end
function InstanceObject:Render()local instance=self.instance if not instance or
not instance.Parent then return self:Destruct()end local options=self.options if
not options.enabled then self.text.Visible=false return end local world=
Workspace:GetPivot(instance).Position local position,visible=WorldToScreen(world
)local distance=(camera.CFrame.Position-world).Magnitude if options.
limitDistance and distance>options.maxDistance then visible=false end self.text.
Visible=visible if not visible then return end self.text.Position=position self.
text.Color=options.textColor[1]self.text.Transparency=options.textColor[2]self.
text.Outline=options.textOutline self.text.OutlineColor=options.textOutlineColor
self.text.Size=options.textSize self.text.Font=options.textFont self.text.Text=
options.text:gsub('{name}',instance.Name):gsub('{distance}',tostring(round(
distance))):gsub('{position}',tostring(world))return end local EspInterface={
_hasLoaded=false,_objectCache={},_container=container,whitelist={},_target=nil,
sharedSettings={textSize=13,textFont=2,limitDistance=true,maxDistance=150,
useTeamColor=false,chamMaterial=Enum.Material.ForceField,chamTextureId=0},
teamSettings={enemy={enabled=false,box=false,boxColor={Color3.fromRGB(106,13,173
),1},boxOutline=true,boxOutlineColor={Color3.fromRGB(181,126,220),1},boxFill=
false,boxFillColor={Color3.fromRGB(106,13,173),0.18},skeletons=false,healthBar=
false,healthyColor=Color3.fromRGB(60,200,100),dyingColor=Color3.fromRGB(214,60,
60),healthBarOutline=true,healthBarOutlineColor={Color3.fromRGB(20,20,22),0.8},
healthText=false,healthTextColor={Color3.fromRGB(240,240,240),1},
healthTextOutline=true,healthTextOutlineColor={Color3.fromRGB(20,20,22),1},name=
false,nameColor={Color3.fromRGB(240,240,240),1},nameOutline=true,
nameOutlineColor={Color3.fromRGB(20,20,22),1},weapon=false,weaponColor={Color3.
fromRGB(178,178,178),1},weaponOutline=true,weaponOutlineColor={Color3.fromRGB(20
,20,22),1},distance=false,distanceColor={Color3.fromRGB(178,178,178),1},
distanceOutline=true,distanceOutlineColor={Color3.fromRGB(20,20,22),1},tracer=
false,tracerOrigin='Bottom',tracerColor={Color3.fromRGB(131,38,198),1},
tracerOutline=true,tracerOutlineColor={Color3.fromRGB(20,20,22),1},
offScreenArrow=false,offScreenArrowColor={Color3.fromRGB(181,126,220),1},
offScreenArrowSize=15,offScreenArrowRadius=150,offScreenArrowOutline=true,
offScreenArrowOutlineColor={Color3.fromRGB(20,20,22),1},targetHighlight=false,
targetHighlightColor={Color3.fromRGB(255,255,255),0.8},chams=false,
chamsVisibleOnly=false,chamsFillColor={Color3.fromRGB(106,13,173),0}},friendly={
enabled=false,box=false,boxColor={Color3.fromRGB(50,138,220),1},boxOutline=true,
boxOutlineColor={Color3.fromRGB(120,180,255),1},boxFill=false,boxFillColor={
Color3.fromRGB(50,138,220),0.16},skeletons=false,healthBar=false,healthyColor=
Color3.fromRGB(60,200,100),dyingColor=Color3.fromRGB(214,60,60),healthBarOutline
=true,healthBarOutlineColor={Color3.fromRGB(20,20,22),0.8},healthText=false,
healthTextColor={Color3.fromRGB(240,240,240),1},healthTextOutline=true,
healthTextOutlineColor={Color3.fromRGB(20,20,22),1},name=false,nameColor={Color3
.fromRGB(240,240,240),1},nameOutline=true,nameOutlineColor={Color3.fromRGB(20,20
,22),1},weapon=false,weaponColor={Color3.fromRGB(178,178,178),1},weaponOutline=
true,weaponOutlineColor={Color3.fromRGB(20,20,22),1},distance=false,
distanceColor={Color3.fromRGB(178,178,178),1},distanceOutline=true,
distanceOutlineColor={Color3.fromRGB(20,20,22),1},tracer=false,tracerOrigin=
'Bottom',tracerColor={Color3.fromRGB(50,138,220),1},tracerOutline=true,
tracerOutlineColor={Color3.fromRGB(20,20,22),1},offScreenArrow=false,
offScreenArrowColor={Color3.fromRGB(120,180,255),1},offScreenArrowSize=15,
offScreenArrowRadius=150,offScreenArrowOutline=true,offScreenArrowOutlineColor={
Color3.fromRGB(20,20,22),1},targetHighlight=false,targetHighlightColor={Color3.
fromRGB(255,255,255),0.8},chams=false,chamsVisibleOnly=false,chamsFillColor={
Color3.fromRGB(50,138,220),0}},murderer={enabled=false,box=false,boxColor={
Color3.fromRGB(220,40,40),1},boxOutline=true,boxOutlineColor={Color3.fromRGB(255
,120,120),1},boxFill=false,boxFillColor={Color3.fromRGB(220,40,40),0.18},
skeletons=false,healthBar=false,healthyColor=Color3.fromRGB(60,200,100),
dyingColor=Color3.fromRGB(214,60,60),healthBarOutline=true,healthBarOutlineColor
={Color3.fromRGB(20,20,22),0.8},healthText=false,healthTextColor={Color3.
fromRGB(240,240,240),1},healthTextOutline=true,healthTextOutlineColor={Color3.
fromRGB(20,20,22),1},name=false,nameColor={Color3.fromRGB(240,240,240),1},
nameOutline=true,nameOutlineColor={Color3.fromRGB(20,20,22),1},weapon=false,
weaponColor={Color3.fromRGB(178,178,178),1},weaponOutline=true,
weaponOutlineColor={Color3.fromRGB(20,20,22),1},distance=false,distanceColor={
Color3.fromRGB(178,178,178),1},distanceOutline=true,distanceOutlineColor={Color3
.fromRGB(20,20,22),1},tracer=false,tracerOrigin='Bottom',tracerColor={Color3.
fromRGB(220,40,40),1},tracerOutline=true,tracerOutlineColor={Color3.fromRGB(20,
20,22),1},offScreenArrow=false,offScreenArrowColor={Color3.fromRGB(255,120,120),
1},offScreenArrowSize=15,offScreenArrowRadius=150,offScreenArrowOutline=true,
offScreenArrowOutlineColor={Color3.fromRGB(20,20,22),1},targetHighlight=false,
targetHighlightColor={Color3.fromRGB(255,255,255),0.8},chams=false,
chamsVisibleOnly=false,chamsFillColor={Color3.fromRGB(220,40,40),0}},sherrif={
enabled=false,box=false,boxColor={Color3.fromRGB(50,138,220),1},boxOutline=true,
boxOutlineColor={Color3.fromRGB(120,180,255),1},boxFill=false,boxFillColor={
Color3.fromRGB(50,138,220),0.16},skeletons=false,healthBar=false,healthyColor=
Color3.fromRGB(60,200,100),dyingColor=Color3.fromRGB(214,60,60),healthBarOutline
=true,healthBarOutlineColor={Color3.fromRGB(20,20,22),0.8},healthText=false,
healthTextColor={Color3.fromRGB(240,240,240),1},healthTextOutline=true,
healthTextOutlineColor={Color3.fromRGB(20,20,22),1},name=false,nameColor={Color3
.fromRGB(240,240,240),1},nameOutline=true,nameOutlineColor={Color3.fromRGB(20,20
,22),1},weapon=false,weaponColor={Color3.fromRGB(178,178,178),1},weaponOutline=
true,weaponOutlineColor={Color3.fromRGB(20,20,22),1},distance=false,
distanceColor={Color3.fromRGB(178,178,178),1},distanceOutline=true,
distanceOutlineColor={Color3.fromRGB(20,20,22),1},tracer=false,tracerOrigin=
'Bottom',tracerColor={Color3.fromRGB(50,138,220),1},tracerOutline=true,
tracerOutlineColor={Color3.fromRGB(20,20,22),1},offScreenArrow=false,
offScreenArrowColor={Color3.fromRGB(120,180,255),1},offScreenArrowSize=15,
offScreenArrowRadius=150,offScreenArrowOutline=true,offScreenArrowOutlineColor={
Color3.fromRGB(20,20,22),1},targetHighlight=false,targetHighlightColor={Color3.
fromRGB(255,255,255),0.8},chams=false,chamsVisibleOnly=false,chamsFillColor={
Color3.fromRGB(50,138,220),0}},hero={enabled=false,box=false,boxColor={Color3.
fromRGB(255,215,0),1},boxOutline=true,boxOutlineColor={Color3.fromRGB(255,235,
120),1},boxFill=false,boxFillColor={Color3.fromRGB(255,215,0),0.18},skeletons=
false,healthBar=false,healthyColor=Color3.fromRGB(60,200,100),dyingColor=Color3.
fromRGB(214,60,60),healthBarOutline=true,healthBarOutlineColor={Color3.fromRGB(
20,20,22),0.8},healthText=false,healthTextColor={Color3.fromRGB(240,240,240),1},
healthTextOutline=true,healthTextOutlineColor={Color3.fromRGB(20,20,22),1},name=
false,nameColor={Color3.fromRGB(240,240,240),1},nameOutline=true,
nameOutlineColor={Color3.fromRGB(20,20,22),1},weapon=false,weaponColor={Color3.
fromRGB(178,178,178),1},weaponOutline=true,weaponOutlineColor={Color3.fromRGB(20
,20,22),1},distance=false,distanceColor={Color3.fromRGB(178,178,178),1},
distanceOutline=true,distanceOutlineColor={Color3.fromRGB(20,20,22),1},tracer=
false,tracerOrigin='Bottom',tracerColor={Color3.fromRGB(255,215,0),1},
tracerOutline=true,tracerOutlineColor={Color3.fromRGB(20,20,22),1},
offScreenArrow=false,offScreenArrowColor={Color3.fromRGB(255,235,120),1},
offScreenArrowSize=15,offScreenArrowRadius=150,offScreenArrowOutline=true,
offScreenArrowOutlineColor={Color3.fromRGB(20,20,22),1},targetHighlight=false,
targetHighlightColor={Color3.fromRGB(255,255,255),0.8},chams=false,
chamsVisibleOnly=false,chamsFillColor={Color3.fromRGB(255,215,0),0}}}}function
EspInterface.AddInstance(instance,options)local cache=EspInterface._objectCache
if cache[instance]then warn('Instance handler already exists.')return cache[
instance][1]end cache[instance]={InstanceObject.new(instance,options)}return
cache[instance][1]end function EspInterface.Load()assert(not EspInterface.
_hasLoaded,'Esp has already been loaded.')local function CreateEntry(player)if
player==LocalPlayer then return end EspInterface._objectCache[player]={EspObject
.new(player,EspInterface),ChamObject.new(player,EspInterface)}end local function
RemoveEntry(player)local entry=EspInterface._objectCache[player]if not entry
then return end for _,object in ipairs(entry)do object:Destruct()end
EspInterface._objectCache[player]=nil end for _,player in ipairs(Players:
GetPlayers())do CreateEntry(player)end EspInterface.playerAdded=Players.
PlayerAdded:Connect(CreateEntry)EspInterface.playerRemoving=Players.
PlayerRemoving:Connect(RemoveEntry)EspInterface._updateConnection=RunService.
RenderStepped:Connect(function()for _,entry in pairs(EspInterface._objectCache)
do entry[1]:Update()entry[1]:Render()end end)EspInterface._hasLoaded=true end
function EspInterface.Cleanup()for _,entry in pairs(EspInterface._objectCache)do
for _,object in ipairs(entry)do object:Destruct()end end EspInterface.
_objectCache={}if EspInterface.playerAdded then EspInterface.playerAdded:
Disconnect()EspInterface.playerAdded=nil end if EspInterface.playerRemoving then
EspInterface.playerRemoving:Disconnect()EspInterface.playerRemoving=nil end if
EspInterface._updateConnection then EspInterface._updateConnection:Disconnect()
EspInterface._updateConnection=nil end EspInterface._hasLoaded=false if
EspInterface._container and EspInterface._container.Parent then EspInterface.
_container:Destroy()end Drawing.clear()end function EspInterface.SetTarget(
player)EspInterface._target=player end function EspInterface.GetWeapon(player)
local character=player.Character or player.CharacterAdded:Wait()local tool=
character:FindFirstChildOfClass('Tool')return tool and tool.Name or'Unknown'end
function EspInterface.IsFriendly(player)return player.Team and player.Team==
LocalPlayer.Team end function EspInterface.GetTeamColor(player)return player.
Team and player.Team.TeamColor and player.Team.TeamColor.Color end function
EspInterface.GetCharacter(player)return player.Character end function
EspInterface.GetHealth(player)local character=player and EspInterface.
GetCharacter(player)local humanoid=character and character:
FindFirstChildOfClass('Humanoid')if humanoid then return humanoid.Health,
humanoid.MaxHealth end return 100,100 end function EspInterface.GetTeamKey(
interface,player)return interface.IsFriendly(player)and'friendly'or'enemy'end
EspInterface.GlobalChamRenderer=GlobalChamRenderer return EspInterface
