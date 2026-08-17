local function GetService(name)local service=game:GetService(name)return
cloneref and cloneref(service)or service end local TweenService=GetService(
'TweenService')local UserInputService=GetService('UserInputService')local
HttpService=GetService('HttpService')local CoreGui=GetService('CoreGui')local
RunService=GetService('RunService')local kTweenFast=TweenInfo.new(0.18,Enum.
EasingStyle.Exponential)local kTweenMid=TweenInfo.new(0.35,Enum.EasingStyle.
Exponential)local kTweenSlow=TweenInfo.new(0.55,Enum.EasingStyle.Exponential)
local kConfigExt='.json'local kBaseFolderName='Aetherea'local kThemeFolder=
'Themes'local kBaseURL='https://raw.githubusercontent.com/smallhuang100/aetherea/main/'local kLucideURL=
[[https://raw.githubusercontent.com/latte-soft/lucide-roblox/refs/heads/master/icons/compiled/48px/]]
local kLucideIcons={[1]='home.png',[2]='user.png',[3]='chevron-down.png',[4]=
'search.png',[5]='x.png',[6]='check.png',[7]='loader-circle.png',[8]='menu.png',
[9]='panel-left.png',[10]='panel-right.png',[11]='layout-dashboard.png',[12]=
'folder.png',[13]='folder-open.png',[14]='settings.png',[15]='cog.png',[16]=
'sliders-horizontal.png',[17]='users.png',[18]='user-plus.png',[19]=
'user-minus.png',[20]='log-in.png',[21]='log-out.png',[22]='filter.png',[23]=
'zoom-in.png',[24]='zoom-out.png',[25]='alert-circle.png',[26]=
'alert-triangle.png',[27]='info.png',[28]='help-circle.png',[29]=
'check-circle.png',[30]='x-circle.png',[31]='minus-circle.png',[32]=
'plus-circle.png',[33]='toggle-left.png',[34]='toggle-right.png',[35]=
'switch-camera.png',[36]='eye.png',[37]='eye-off.png',[38]='lock.png',[39]=
'unlock.png',[40]='file.png',[41]='file-plus.png',[42]='file-minus.png',[43]=
'file-edit.png',[44]='save.png',[45]='download.png',[46]='upload.png',[47]=
'wifi.png',[48]='wifi-off.png',[49]='server.png',[50]='cloud.png',[51]=
'cloud-off.png',[52]='link.png',[53]='unlink.png',[54]='play.png',[55]=
'pause.png',[56]='skip-forward.png',[57]='skip-back.png',[58]='volume.png',[59]=
'volume-x.png',[60]='volume-1.png',[61]='volume-2.png',[62]='star.png',[63]=
'star-off.png',[64]='heart.png',[65]='heart-off.png',[66]='trash.png',[67]=
'refresh-cw.png',[68]='refresh-ccw.png',[69]='clipboard.png',[70]=
'clipboard-copy.png',[71]='clipboard-check.png',[72]='calendar.png',[73]=
'clock.png',[74]='map.png',[75]='flag.png',[76]='sparkles.png',[77]=
'crosshair.png',[78]='view.png',[79]='globe.png',[80]='rainbow.png',[81]=
'smartphone.png',[82]='list.png',[83]='box.png',[84]='circle-dollar-sign.png',[
85]='cat.png'}local kDefaultTheme={FontRegular=Font.new(
'rbxasset://fonts/families/Montserrat.json',Enum.FontWeight.Regular,Enum.
FontStyle.Normal),FontSemiBold=Font.new(
'rbxasset://fonts/families/Montserrat.json',Enum.FontWeight.SemiBold,Enum.
FontStyle.Normal),Background=Color3.fromRGB(28,28,30),Stroke=Color3.fromRGB(38,
38,40),Text=Color3.fromRGB(240,240,240),SubText=Color3.fromRGB(178,178,178),
TextEnabled=Color3.fromRGB(181,126,220),SectionBackground=Color3.fromRGB(35,35,
37),SectionStroke=Color3.fromRGB(35,35,37),SectionTopbar=Color3.fromRGB(32,32,34
),ElementBackground=Color3.fromRGB(38,38,40),ElementStroke=Color3.fromRGB(42,42,
44),ElementSelected=Color3.fromRGB(44,44,46),TabBackgroundSelected=Color3.
fromRGB(50,50,52),TabText=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.
fromRGB(181,126,220)),ColorSequenceKeypoint.new(1,Color3.fromRGB(181,126,220))})
,TabTextSelected=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(
106,13,173)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(181,126,220)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(106,13,173))}),TabStroke=Color3.
fromRGB(54,54,56),ButtonBackground=Color3.fromRGB(38,38,40),ButtonStroke=Color3.
fromRGB(42,42,44),ButtonHoverBackground=Color3.fromRGB(44,44,46),ToggleEnabled=
Color3.fromRGB(106,13,173),ToggleDisabled=Color3.fromRGB(100,100,102),
ToggleEnabledStroke=Color3.fromRGB(131,38,198),ToggleDisabledStroke=Color3.
fromRGB(125,125,127),ToggleHoverEnabled=Color3.fromRGB(133,40,200),
ToggleHoverDisabled=Color3.fromRGB(127,127,129),SliderBackground=Color3.fromRGB(
38,38,40),SliderFill=Color3.fromRGB(106,13,173),SliderStroke=Color3.fromRGB(42,
42,44),SliderHoverBackground=Color3.fromRGB(44,44,46),SliderHoverFill=Color3.
fromRGB(133,40,200),DropdownBackground=Color3.fromRGB(38,38,40),DropdownStroke=
Color3.fromRGB(42,42,44),DropdownHoverBackground=Color3.fromRGB(44,44,46),
DropdownSelected=Color3.fromRGB(48,48,50),DropdownUnselected=Color3.fromRGB(38,
38,40),InputBackground=Color3.fromRGB(38,38,40),InputStroke=Color3.fromRGB(42,42
,44),InputStrokeSelected=Color3.fromRGB(44,44,46),KeybindBackground=Color3.
fromRGB(38,38,40),KeybindStroke=Color3.fromRGB(42,42,44),KeybindStrokeSelected=
Color3.fromRGB(44,44,46),ColorPickerBackground=Color3.fromRGB(38,38,40),
ColorPickerStroke=Color3.fromRGB(42,42,44),ColorPickerHoverBackground=Color3.
fromRGB(44,44,46),ColorPickerPanel=Color3.fromRGB(38,38,40),RadioEnabled=Color3.
fromRGB(106,13,173),RadioDisabled=Color3.fromRGB(100,100,102),RadioEnabledStroke
=Color3.fromRGB(131,38,198),RadioDisabledStroke=Color3.fromRGB(125,125,127),
RadioHoverEnabled=Color3.fromRGB(133,40,200),RadioHoverDisabled=Color3.fromRGB(
127,127,129),NotificationTopbar=Color3.fromRGB(32,32,34),NotificationBackground=
Color3.fromRGB(35,35,37),NotificationStroke=Color3.fromRGB(35,35,37),AccentColor
=Color3.fromRGB(50,138,220),DangerColor=Color3.fromRGB(214,60,60),SuccessColor=
Color3.fromRGB(60,200,100),WarningColor=Color3.fromRGB(220,160,0)}local function
GetProtectedParent()if gethui then return gethui()end local roblox_gui=CoreGui:
FindFirstChild('RobloxGui')return roblox_gui or CoreGui end local kAssetCache={}
local Assets={}local function EnsureFolder(path)if isfolder and not isfolder(
path)then makefolder(path)end end function Assets.Register(id,url)kAssetCache[
tostring(id)]={url=url,uri=nil}end function Assets.Preload()local has_gca=type(
getcustomasset)=='function'local has_fs=type(writefile)=='function'and type(
isfile)=='function'EnsureFolder(kBaseFolderName)EnsureFolder(kBaseFolderName..
'/assets')local pending=0 local done=Instance.new('BindableEvent')for id_str,
entry in pairs(kAssetCache)do if entry.uri then continue end pending+=1 task.
spawn(function()local file_path=kBaseFolderName..'/assets/'..id_str..'.png'if
has_gca and has_fs then if not isfile(file_path)then local ok,body=pcall(game.
HttpGet,game,entry.url)if ok and#body>0 then writefile(file_path,body)end end if
isfile(file_path)then local ok,uri=pcall(getcustomasset,file_path)entry.uri=ok
and uri or('rbxassetid://'..id_str)else entry.uri='rbxassetid://'..id_str end
else entry.uri='rbxassetid://'..id_str end pending-=1 if pending==0 then done:
Fire()end end)end if pending>0 then done.Event:Wait()end done:Destroy()end
function Assets.Get(id)local entry=kAssetCache[tostring(id)]if not entry then
return''end return entry.uri or('rbxassetid://'..id)end local SequenceTween={}
SequenceTween.__index=SequenceTween local function LerpNumberSequence(a,b,alpha)
local keypoints={}local count=math.max(#a.Keypoints,#b.Keypoints)for i=1,count
do local ak=a.Keypoints[math.min(i,#a.Keypoints)]local bk=b.Keypoints[math.min(i
,#b.Keypoints)]local time=ak.Time+(bk.Time-ak.Time)*alpha local value=ak.Value+(
bk.Value-ak.Value)*alpha local envelope=(ak.Envelope or 0)+(((bk.Envelope or 0)-
(ak.Envelope or 0))*alpha)table.insert(keypoints,NumberSequenceKeypoint.new(time
,value,envelope))end return NumberSequence.new(keypoints)end local function
LerpColorSequence(a,b,alpha)local keypoints={}local count=math.max(#a.Keypoints,
#b.Keypoints)for i=1,count do local ak=a.Keypoints[math.min(i,#a.Keypoints)]
local bk=b.Keypoints[math.min(i,#b.Keypoints)]local time=ak.Time+(bk.Time-ak.
