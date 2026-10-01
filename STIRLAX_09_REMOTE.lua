local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local VirtualUser=nil
pcall(function()
    VirtualUser=game:GetService("VirtualUser")
end)

local ENV=(type(getgenv)=="function" and getgenv()) or _G
if type(ENV)=="table" and type(ENV.STIRLAX_MODZ_KILL)=="function" then
    pcall(ENV.STIRLAX_MODZ_KILL)
end

local LP=Players.LocalPlayer
while not LP do
    task.wait()
    LP=Players.LocalPlayer
end

local PG=LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui",15)
if not PG then
    warn("[STIRLAX MODZ] No se encontro PlayerGui.")
    return
end

local GUI_PARENT=PG
pcall(function()
    if type(gethui)=="function" then
        local hui=gethui()
        if typeof(hui)=="Instance" then
            GUI_PARENT=hui
        end
    end
end)

for _,container in ipairs({PG,GUI_PARENT}) do
    for _,oldName in ipairs({"09","STIRLAX_MODZ"}) do
        local old=container:FindFirstChild(oldName)
        if old then
            pcall(function()
                old:Destroy()
            end)
        end
    end
end

local C={
    black=Color3.fromRGB(6,2,4),
    glass=Color3.fromRGB(20,4,9),
    card=Color3.fromRGB(32,7,14),
    cardHi=Color3.fromRGB(46,9,19),
    hover=Color3.fromRGB(82,12,28),
    white=Color3.fromRGB(255,246,248),
    gray=Color3.fromRGB(196,146,156),
    dim=Color3.fromRGB(122,78,88),
    red=Color3.fromRGB(255,24,52),
    redSoft=Color3.fromRGB(255,72,96),
    redDeep=Color3.fromRGB(150,6,26),
    gold=Color3.fromRGB(255,190,120),
    green=Color3.fromRGB(70,235,120),
    off=Color3.fromRGB(58,22,30)
}

local CFG={
    ui={
        redGlow=.78,
        particles=true,
        particleDensity=60,
        reduceMotion=false,
        performance="Alto",
        notify=true,
        notifyTime=2.6,
        compactLauncher=false,
        lockMenu=false,
        menuKey=Enum.KeyCode.RightShift,
        fpsMonitor=false,
        targetCounter=false,
        teamCheck=false
    },
    aim={
        enabled=false,
        activation="Hold",
        showFov=true,
        marker=true,
        wall=false,
        fov=150,
        strength=.35,
        range=650,
        bone="Head",
        priority="Center",
        deadzone=0,
        lock=false
    },
    esp={
        boxes=false,
        boxStyle="Corners",
        names=false,
        distance=false,
        health=false,
        healthText=false,
        tracers=false,
        tracerOrigin="Bottom",
        arrows=false,
        xray=false,
        outline=false,
        hpColor=true,
        wall=false,
        range=1500,
        thickness=1.5,
        boxScale=1,
        xrayFill=.55,
        rate=60,
        maxTargets=40
    },
    move={
        speed=false,
        speedValue=32,
        jump=false,
        jumpValue=100,
        infJump=false,
        fly=false,
        flySpeed=80,
        flyVertical=60,
        flyAccel=.25,
        flyPad=false,
        noclip=false,
        gravity=false,
        gravityValue=100,
        clickTp=false
    },
    world={
        fullbright=false,
        noFog=false,
        noShadows=false,
        hour=false,
        hourValue=14,
        camFov=false,
        camFovValue=90,
        zoom=false,
        fade=false,
        fadeAmount=.55,
        fadeExclude="Both"
    },
    extra={
        spin=false,
        spinSpeed=360,
        antiAfk=false,
        tool=false,
        toolCooldown=.08,
        toolFilter="Authorized"
    }
}

local STATE={
    alive=true,
    menuOpen=false,
    menuBusy=false,
    minimized=false,
    mobile=false,
    fps=0,
    frames=0,
    fpsTime=0,
    targetCount=0,
    aimModel=nil,
    aimPart=nil,
    aimToggled=false,
    skipModel=nil,
    muteNotify=false,
    listening=nil,
    themeStrokes={},
    controls={},
    keyed={},
    layoutHooks={},
    conns={},
    presets={},
    flyUp=false,
    flyDown=false,
    toolLast=0,
    espLast=0,
    targetCache={},
    targetCacheTime=0,
    touches={},
    camFovActive=false
}

local function Track(connection)
    table.insert(STATE.conns,connection)
    return connection
end

local errorTimes={}

local function SafeCall(label,fn,...)
    if type(fn)~="function" then
        return true
    end
    local ok,err=pcall(fn,...)
    if not ok then
        local key=tostring(label)
        local now=os.clock()
        if not errorTimes[key] or now-errorTimes[key]>4 then
            errorTimes[key]=now
            warn("[STIRLAX MODZ] "..key..": "..tostring(err))
        end
    end
    return ok
end

local function N(className,props)
    local object=Instance.new(className)
    local parent=nil
    for key,value in pairs(props) do
        if key=="Parent" then
            parent=value
        else
            local ok,err=pcall(function()
                object[key]=value
            end)
            if not ok then
                warn("[STIRLAX MODZ] "..className.."."..tostring(key)..": "..tostring(err))
            end
        end
    end
    if parent then
        object.Parent=parent
    end
    return object
end

local function R(object,radius)
    return N("UICorner",{
        CornerRadius=UDim.new(0,radius or 10),
        Parent=object
    })
end

local function GlowTransparency()
    return math.clamp(.86-CFG.ui.redGlow*.7,.05,.85)
end

local function S(object,color,thickness,themed)
    local stroke=N("UIStroke",{
        Color=color or C.red,
        Thickness=thickness or 1,
        Transparency=themed==false and .7 or GlowTransparency(),
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        Parent=object
    })
    if themed~=false then
        table.insert(STATE.themeStrokes,stroke)
    end
    return stroke
end

local function G(object,a,b,rotation)
    return N("UIGradient",{
        Color=ColorSequence.new(a,b),
        Rotation=rotation or 90,
        Parent=object
    })
end

local function T(parent,text,size,position,textSize,color,font)
    return N("TextLabel",{
        Text=text or "",
        Size=size or UDim2.fromScale(1,1),
        Position=position or UDim2.new(),
        BackgroundTransparency=1,
        TextColor3=color or C.white,
        Font=font or Enum.Font.Gotham,
        TextSize=textSize or 12,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Parent=parent
    })
end

local function B(parent,text,size,position)
    local button=N("TextButton",{
        Text=text or "",
        Size=size or UDim2.fromOffset(80,28),
        Position=position or UDim2.new(),
        BackgroundColor3=C.card,
        TextColor3=C.white,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        AutoButtonColor=false,
        BorderSizePixel=0,
        Parent=parent
    })
    R(button,9)
    return button
end

local function Tween(object,time,props,style,direction)
    if not object or not object.Parent then
        return nil
    end
    local duration=CFG.ui.reduceMotion and 0 or time
    local ok,tween=pcall(function()
        return TweenService:Create(object,TweenInfo.new(duration,style or Enum.EasingStyle.Quint,direction or Enum.EasingDirection.Out),props)
    end)
    if ok and tween then
        tween:Play()
        return tween
    end
    for key,value in pairs(props) do
        pcall(function()
            object[key]=value
        end)
    end
    return nil
end

local function Root()
    local character=LP.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function Hum()
    local character=LP.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local ORIGINAL={
    brightness=Lighting.Brightness,
    clockTime=Lighting.ClockTime,
    fogEnd=Lighting.FogEnd,
    fogStart=Lighting.FogStart,
    shadows=Lighting.GlobalShadows,
    ambient=Lighting.Ambient,
    outdoor=Lighting.OutdoorAmbient,
    gravity=workspace.Gravity,
    zoom=LP.CameraMaxZoomDistance,
    fov=workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70,
    atmosphere={}
}

local Gui=N("ScreenGui",{
    Name="STIRLAX_MODZ",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=50
})
local parented=pcall(function()
    Gui.Parent=GUI_PARENT
end)
if not parented or not Gui.Parent then
    Gui.Parent=PG
end

local EspLayer=N("Frame",{
    Name="EspLayer",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=1,
    Parent=Gui
})

local FovCircle=N("Frame",{
    Name="FovCircle",
    Size=UDim2.fromOffset(300,300),
    Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundTransparency=1,
    Visible=false,
    ZIndex=2,
    Parent=Gui
})
N("UICorner",{CornerRadius=UDim.new(1,0),Parent=FovCircle})
local FovStroke=N("UIStroke",{Color=C.red,Thickness=1.6,Transparency=.15,Parent=FovCircle})

local NotifyLayer=N("Frame",{
    Name="Notifications",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=60,
    Parent=Gui
})

local Overlay=T(Gui,"",UDim2.fromOffset(260,20),UDim2.fromOffset(14,12),11,C.redSoft,Enum.Font.GothamBold)
Overlay.ZIndex=59
Overlay.Visible=false
Overlay.TextStrokeTransparency=.35
Overlay.TextStrokeColor3=C.black

local notifySlots={}

local function Notify(title,body,color)
    if not CFG.ui.notify or STATE.muteNotify or not Gui.Parent then
        return
    end
    local accent=color or C.red
    local slot=1
    for i=1,4 do
        if not notifySlots[i] or not notifySlots[i].Parent then
            slot=i
            break
        end
        slot=i
    end
    if notifySlots[slot] and notifySlots[slot].Parent then
        notifySlots[slot]:Destroy()
    end
    local width=STATE.mobile and 236 or 286
    local y=-16-(slot-1)*62
    local card=N("Frame",{
        Size=UDim2.fromOffset(width,54),
        Position=UDim2.new(1,width+30,1,y),
        AnchorPoint=Vector2.new(1,1),
        BackgroundColor3=C.glass,
        BackgroundTransparency=.06,
        BorderSizePixel=0,
        ZIndex=61,
        Parent=NotifyLayer
    })
    notifySlots[slot]=card
    R(card,12)
    S(card,accent,1.2,false)
    G(card,C.cardHi,C.glass,90)
    local bar=N("Frame",{
        Size=UDim2.fromOffset(4,32),
        Position=UDim2.fromOffset(10,11),
        BackgroundColor3=accent,
        BorderSizePixel=0,
        ZIndex=62,
        Parent=card
    })
    R(bar,2)
    local titleLabel=T(card,title,UDim2.new(1,-30,0,18),UDim2.fromOffset(22,7),11,accent,Enum.Font.GothamBlack)
    titleLabel.ZIndex=62
    local bodyLabel=T(card,body,UDim2.new(1,-30,0,18),UDim2.fromOffset(22,27),10,C.white,Enum.Font.GothamMedium)
    bodyLabel.ZIndex=62
    Tween(card,.25,{Position=UDim2.new(1,-16,1,y)})
    task.delay(math.max(CFG.ui.notifyTime,.8),function()
        if not card.Parent then
            return
        end
        local out=Tween(card,.2,{Position=UDim2.new(1,width+30,1,y)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.delay(CFG.ui.reduceMotion and 0 or .22,function()
            if card.Parent then
                card:Destroy()
            end
        end)
        if not out and card.Parent then
            card:Destroy()
        end
    end)
end

local Main=N("Frame",{
    Name="Main",
    Size=UDim2.fromOffset(940,580),
    Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundColor3=C.black,
    BackgroundTransparency=.08,
    BorderSizePixel=0,
    ClipsDescendants=true,
    Active=true,
    Visible=false,
    ZIndex=20,
    Parent=Gui
})
R(Main,18)
S(Main,C.red,2)
G(Main,C.glass,C.black,135)
local MainScale=N("UIScale",{Scale=1,Parent=Main})

local Space=N("Frame",{
    Name="Particles",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ClipsDescendants=true,
    ZIndex=1,
    Parent=Main
})

local RootFrame=N("Frame",{
    Name="Root",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=2,
    Parent=Main
})

local Header=N("Frame",{
    Name="Header",
    Size=UDim2.new(1,-28,0,60),
    Position=UDim2.fromOffset(14,12),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.18,
    BorderSizePixel=0,
    ZIndex=3,
    Parent=RootFrame
})
R(Header,14)
S(Header,C.red,1)
G(Header,C.cardHi,C.glass,0)

local DragHandle=N("TextButton",{
    Name="DragHandle",
    Text="",
    AutoButtonColor=false,
    BackgroundTransparency=1,
    Size=UDim2.fromScale(1,1),
    ZIndex=3,
    Parent=Header
})

local Logo=N("Frame",{
    Size=UDim2.fromOffset(44,44),
    Position=UDim2.fromOffset(10,8),
    BackgroundColor3=C.red,
    BorderSizePixel=0,
    ZIndex=4,
    Parent=Header
})
R(Logo,14)
S(Logo,C.gold,1.2,false)
G(Logo,C.red,C.redDeep,135)
local LogoText=T(Logo,"S",UDim2.fromScale(1,1),nil,22,C.white,Enum.Font.GothamBlack)
LogoText.TextXAlignment=Enum.TextXAlignment.Center
LogoText.ZIndex=5

local TitleLabel=T(Header,"STIRLAX MODZ",UDim2.fromOffset(150,24),UDim2.fromOffset(64,8),18,C.red,Enum.Font.GothamBlack)
TitleLabel.ZIndex=4
TitleLabel.TextStrokeColor3=C.black
TitleLabel.TextStrokeTransparency=.4
local SubLabel=T(Header,"DEVELOPER STIRLAX",UDim2.fromOffset(150,16),UDim2.fromOffset(64,33),10,C.gray,Enum.Font.GothamBold)
SubLabel.ZIndex=4

local TabBar=N("ScrollingFrame",{
    Name="Tabs",
    Size=UDim2.fromOffset(520,34),
    Position=UDim2.fromOffset(226,13),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=0,
    ScrollingDirection=Enum.ScrollingDirection.X,
    CanvasSize=UDim2.new(),
    ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,
    ZIndex=4,
    Parent=Header
})
local TabList=N("UIListLayout",{
    FillDirection=Enum.FillDirection.Horizontal,
    Padding=UDim.new(0,5),
    SortOrder=Enum.SortOrder.LayoutOrder,
    VerticalAlignment=Enum.VerticalAlignment.Center,
    Parent=TabBar
})
Track(TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBar.CanvasSize=UDim2.fromOffset(TabList.AbsoluteContentSize.X/math.max(MainScale.Scale,.01)+4,0)
end))

local MinButton=B(Header,"—",UDim2.fromOffset(34,32),UDim2.new(1,-160,0,14))
MinButton.ZIndex=5
MinButton.TextColor3=C.white
MinButton.TextSize=14
S(MinButton,C.red,1)
local CloseButton=B(Header,"X",UDim2.fromOffset(34,32),UDim2.new(1,-120,0,14))
CloseButton.ZIndex=5
CloseButton.TextColor3=C.white
CloseButton.TextSize=12
S(CloseButton,C.red,1)
local KillButton=B(Header,"KILL",UDim2.fromOffset(70,32),UDim2.new(1,-80,0,14))
KillButton.ZIndex=5
KillButton.TextColor3=C.red
KillButton.TextSize=11
S(KillButton,C.red,1)

local Body=N("Frame",{
    Name="Body",
    Size=UDim2.new(1,-28,1,-92),
    Position=UDim2.fromOffset(14,80),
    BackgroundTransparency=1,
    ZIndex=3,
    Parent=RootFrame
})

local PAGE_ORDER={"PEOPLE","AIM","ESP","MOVE","WORLD","SKINS","EXTRAS","CONFIG"}
local PAGE_TITLE={
    PEOPLE="JUGADORES",
    AIM="AIM ASSIST",
    ESP="ESP VISUAL",
    MOVE="MOVIMIENTO",
    WORLD="MUNDO Y CAMARA",
    SKINS="SKINS",
    EXTRAS="EXTRAS",
    CONFIG="CONFIGURACION"
}
local PAGE_DESC={
    PEOPLE="Lista de jugadores, perfil 3D, ropa y herramientas visibles.",
    AIM="Asistencia de camara local hacia objetivos autorizados. Fuerza 1.00 = respuesta instantanea.",
    ESP="Cada elemento se activa por separado. Solo modelos en workspace.Targets o con etiqueta Target.",
    MOVE="Velocidad, saltos, vuelo estable, noclip, gravedad y teletransporte.",
    WORLD="Iluminacion, niebla, sombras, hora, campo de vision, zoom y transparencia del mapa.",
    SKINS="Skins locales para tu personaje y para la vista previa 3D.",
    EXTRAS="Funciones secundarias: giro, anti AFK, tool assist y monitores en pantalla.",
    CONFIG="Tecla del menu, launcher, apariencia, rendimiento, filtros, presets y reinicio."
}

local Pages={}
local PageTitles={}
local PageDescs={}
local Tabs={}

for index,name in ipairs(PAGE_ORDER) do
    local page=N("Frame",{
        Name=name,
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=C.glass,
        BackgroundTransparency=.22,
        BorderSizePixel=0,
        Visible=false,
        ZIndex=3,
        Parent=Body
    })
    R(page,14)
    S(page,C.red,1)
    G(page,C.glass,C.black,90)
    local title=T(page,PAGE_TITLE[name],UDim2.new(1,-36,0,24),UDim2.fromOffset(18,10),20,C.white,Enum.Font.GothamBlack)
    title.ZIndex=4
    local desc=T(page,PAGE_DESC[name],UDim2.new(1,-36,0,16),UDim2.fromOffset(18,36),10,C.gray,Enum.Font.GothamMedium)
    desc.ZIndex=4
    Pages[name]=page
    PageTitles[name]=title
    PageDescs[name]=desc

    local tab=B(TabBar,name,UDim2.fromOffset(62,30))
    tab.LayoutOrder=index
    tab.TextSize=10
    tab.ZIndex=5
    tab.TextColor3=C.gray
    S(tab,C.red,1)
    Tabs[name]=tab
end

local Launcher=N("TextButton",{
    Name="Launcher",
    Text="",
    AutoButtonColor=false,
    Size=UDim2.fromOffset(190,50),
    Position=UDim2.new(1,-206,1,-70),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.04,
    BorderSizePixel=0,
    Active=true,
    ZIndex=40,
    Parent=Gui
})
R(Launcher,16)
S(Launcher,C.red,1.6)
G(Launcher,C.cardHi,C.glass,135)
local LauncherDot=N("Frame",{
    Size=UDim2.fromOffset(34,34),
    Position=UDim2.fromOffset(8,8),
    BackgroundColor3=C.red,
    BorderSizePixel=0,
    ZIndex=41,
    Parent=Launcher
})
R(LauncherDot,11)
G(LauncherDot,C.red,C.redDeep,135)
local LauncherDotText=T(LauncherDot,"S",UDim2.fromScale(1,1),nil,18,C.white,Enum.Font.GothamBlack)
LauncherDotText.TextXAlignment=Enum.TextXAlignment.Center
LauncherDotText.ZIndex=42
local LauncherTitle=T(Launcher,"STIRLAX MODZ",UDim2.new(1,-56,0,18),UDim2.fromOffset(50,8),13,C.red,Enum.Font.GothamBlack)
LauncherTitle.ZIndex=41
local LauncherSub=T(Launcher,"TOCA PARA ABRIR",UDim2.new(1,-56,0,14),UDim2.fromOffset(50,27),9,C.gray,Enum.Font.GothamBold)
LauncherSub.ZIndex=41

local Particles={}

local function ParticleCount()
    local factor=CFG.ui.performance=="Bajo" and .4 or CFG.ui.performance=="Medio" and .7 or 1
    if STATE.mobile then
        factor=factor*.7
    end
    return math.clamp(math.floor(80*CFG.ui.particleDensity/100*factor),0,90)
end

local function BuildParticles()
    for _,p in ipairs(Particles) do
        if p.frame and p.frame.Parent then
            p.frame:Destroy()
        end
    end
    table.clear(Particles)
    for i=1,ParticleCount() do
        local size=math.random(2,5)
        local frame=N("Frame",{
            Size=UDim2.fromOffset(size,size),
            Position=UDim2.fromScale(math.random(),math.random()),
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=i%6==0 and C.gold or (i%2==0 and C.red or C.redSoft),
            BackgroundTransparency=.4,
            BorderSizePixel=0,
            ZIndex=1,
            Parent=Space
        })
        R(frame,size)
        table.insert(Particles,{
            frame=frame,
            x=math.random(),
            y=math.random(),
            vx=math.random(-6,6)/1000,
            vy=-math.random(2,10)/1000,
            phase=math.random()*6.28
        })
    end
end

local function UpdateParticles(dt)
    if not Main.Visible then
        return
    end
    local enabled=CFG.ui.particles and not CFG.ui.reduceMotion
    for _,p in ipairs(Particles) do
        local frame=p.frame
        if frame.Parent then
            if enabled then
                p.x=(p.x+p.vx*dt*60)%1
                p.y=(p.y+p.vy*dt*60)%1
                p.phase=p.phase+dt*2
                frame.Position=UDim2.fromScale(p.x,p.y)
                frame.BackgroundTransparency=math.clamp(.5+math.sin(p.phase)*.25,.15,.85)
                frame.Visible=true
            else
                frame.Visible=false
            end
        end
    end
end

local function ApplyGlow()
    local value=GlowTransparency()
    for _,stroke in ipairs(STATE.themeStrokes) do
        if stroke.Parent then
            stroke.Transparency=value
        end
    end
end

local LAYOUT={
    width=940,
    height=580,
    header=60,
    cardHeight=54,
    columns=2,
    cellWidth=430,
    scale=1
}

local function Viewport()
    local camera=workspace.CurrentCamera
    if camera then
        local size=camera.ViewportSize
        if size.X>10 and size.Y>10 then
            return size
        end
    end
    return Vector2.new(1280,720)
end

local function LayoutLauncher()
    local vp=Viewport()
    if CFG.ui.compactLauncher then
        Launcher.Size=UDim2.fromOffset(54,54)
        LauncherDot.Position=UDim2.fromOffset(10,10)
        LauncherTitle.Visible=false
        LauncherSub.Visible=false
    else
        local width=STATE.mobile and 160 or 190
        Launcher.Size=UDim2.fromOffset(width,50)
        LauncherDot.Position=UDim2.fromOffset(8,8)
        LauncherTitle.Visible=true
        LauncherSub.Visible=true
        LauncherSub.Text=STATE.mobile and "TOCA PARA ABRIR" or "CLIC O "..(CFG.ui.menuKey and CFG.ui.menuKey.Name:upper() or "SIN TECLA")
    end
    local pos=Launcher.Position
    local size=Launcher.Size
    local x=pos.X.Scale*vp.X+pos.X.Offset
    local y=pos.Y.Scale*vp.Y+pos.Y.Offset
    x=math.clamp(x,4,math.max(4,vp.X-size.X.Offset-4))
    y=math.clamp(y,4,math.max(4,vp.Y-size.Y.Offset-4))
    Launcher.Position=UDim2.fromOffset(x,y)
end

local function ApplyLayout()
    local vp=Viewport()
    local touch=UIS.TouchEnabled and not UIS.KeyboardEnabled
    STATE.mobile=touch or vp.X<780 or vp.Y<500
    local width,height,scale
    if STATE.mobile then
        width=math.floor(math.clamp(vp.X-16,300,860))
        height=math.floor(math.clamp(vp.Y-16,240,600))
        scale=1
    else
        width,height=940,580
        scale=math.clamp(math.min((vp.X-40)/width,(vp.Y-40)/height),.62,1)
    end
    local twoRows=STATE.mobile and width<620
    local headerHeight=twoRows and 92 or (STATE.mobile and 50 or 60)
    LAYOUT.width=width
    LAYOUT.height=height
    LAYOUT.header=headerHeight
    LAYOUT.cardHeight=STATE.mobile and 58 or 54
    LAYOUT.scale=scale
    MainScale.Scale=scale

    local fullHeight=STATE.minimized and (headerHeight+24) or height
    Main.Size=UDim2.fromOffset(width,fullHeight)
    Header.Size=UDim2.new(1,-24,0,headerHeight)
    Header.Position=UDim2.fromOffset(12,12)
    Body.Position=UDim2.fromOffset(12,headerHeight+20)
    Body.Size=UDim2.new(1,-24,1,-(headerHeight+32))
    Body.Visible=not STATE.minimized

    local buttonSize=STATE.mobile and 36 or 32
    local killWidth=STATE.mobile and 58 or 70
    local headerWidth=width-24
    local topRowY=STATE.mobile and 7 or 14
    KillButton.Size=UDim2.fromOffset(killWidth,buttonSize)
    KillButton.Position=UDim2.new(1,-(killWidth+8),0,topRowY)
    CloseButton.Size=UDim2.fromOffset(buttonSize,buttonSize)
    CloseButton.Position=UDim2.new(1,-(killWidth+8+buttonSize+6),0,topRowY)
    MinButton.Size=UDim2.fromOffset(buttonSize,buttonSize)
    MinButton.Position=UDim2.new(1,-(killWidth+8+(buttonSize+6)*2),0,topRowY)
    local buttonsWidth=killWidth+8+(buttonSize+6)*2+8

    if STATE.mobile then
        Logo.Size=UDim2.fromOffset(36,36)
        Logo.Position=UDim2.fromOffset(8,7)
        LogoText.TextSize=18
        TitleLabel.Position=UDim2.fromOffset(52,7)
        TitleLabel.Size=UDim2.fromOffset(130,20)
        TitleLabel.TextSize=15
        SubLabel.Position=UDim2.fromOffset(52,27)
        SubLabel.Size=UDim2.fromOffset(130,14)
        SubLabel.TextSize=9
        if twoRows then
            TabBar.Position=UDim2.fromOffset(8,52)
            TabBar.Size=UDim2.fromOffset(headerWidth-16,36)
        else
            TabBar.Position=UDim2.fromOffset(190,7)
            TabBar.Size=UDim2.fromOffset(math.max(120,headerWidth-190-buttonsWidth),36)
        end
    else
        Logo.Size=UDim2.fromOffset(44,44)
        Logo.Position=UDim2.fromOffset(10,8)
        LogoText.TextSize=22
        TitleLabel.Position=UDim2.fromOffset(64,8)
        TitleLabel.Size=UDim2.fromOffset(150,24)
        TitleLabel.TextSize=18
        SubLabel.Position=UDim2.fromOffset(64,33)
        SubLabel.Size=UDim2.fromOffset(150,16)
        SubLabel.TextSize=10
        TabBar.Position=UDim2.fromOffset(222,13)
        TabBar.Size=UDim2.fromOffset(math.max(200,headerWidth-222-buttonsWidth),34)
    end

    local tabWidth=STATE.mobile and 74 or 62
    local tabHeight=STATE.mobile and 34 or 30
    for _,tab in pairs(Tabs) do
        tab.Size=UDim2.fromOffset(tabWidth,tabHeight)
        tab.TextSize=STATE.mobile and 11 or 10
    end
    TabBar.CanvasSize=UDim2.fromOffset(#PAGE_ORDER*(tabWidth+5)+4,0)

    for name,title in pairs(PageTitles) do
        title.TextSize=STATE.mobile and 16 or 20
        title.Size=UDim2.new(1,-36,0,STATE.mobile and 20 or 24)
        title.Position=UDim2.fromOffset(16,STATE.mobile and 8 or 10)
        local desc=PageDescs[name]
        desc.Visible=not (STATE.mobile and height<330)
        desc.Position=UDim2.fromOffset(16,STATE.mobile and 29 or 36)
        desc.TextSize=STATE.mobile and 9 or 10
    end

    local contentWidth=width-24-28-10
    local columns=contentWidth>=620 and 2 or 1
    LAYOUT.columns=columns
    LAYOUT.cellWidth=math.floor((contentWidth-(columns-1)*10)/columns)

    for _,hook in ipairs(STATE.layoutHooks) do
        SafeCall("layout",hook)
    end

    LayoutLauncher()

    local pos=Main.Position
    local x=pos.X.Scale*vp.X+pos.X.Offset
    local y=pos.Y.Scale*vp.Y+pos.Y.Offset
    local halfW=width*scale/2
    local halfH=fullHeight*scale/2
    x=math.clamp(x,math.min(halfW,vp.X/2),math.max(vp.X-halfW,vp.X/2))
    y=math.clamp(y,math.min(halfH,vp.Y/2),math.max(vp.Y-halfH,vp.Y/2))
    Main.Position=UDim2.fromOffset(x,y)
end

local function MakeDraggable(handle,target,onTap)
    local dragging=false
    local moved=false
    local startInput=nil
    local startPos=nil
    local activeInput=nil
    Track(handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            moved=false
            activeInput=input
            startInput=input.Position
            local vp=Viewport()
            local pos=target.Position
            startPos=Vector2.new(pos.X.Scale*vp.X+pos.X.Offset,pos.Y.Scale*vp.Y+pos.Y.Offset)
        end
    end))
    Track(UIS.InputChanged:Connect(function(input)
        if not dragging or not startInput then
            return
        end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then
            return
        end
        if input.UserInputType==Enum.UserInputType.Touch and activeInput and activeInput.UserInputType==Enum.UserInputType.Touch and input~=activeInput then
            return
        end
        local delta=Vector2.new(input.Position.X-startInput.X,input.Position.Y-startInput.Y)
        if delta.Magnitude>6 then
            moved=true
        end
        if moved and not CFG.ui.lockMenu then
            local vp=Viewport()
            local x=math.clamp(startPos.X+delta.X,0,vp.X)
            local y=math.clamp(startPos.Y+delta.Y,0,vp.Y)
            target.Position=UDim2.fromOffset(x,y)
        end
    end))
    Track(UIS.InputEnded:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            if input.UserInputType==Enum.UserInputType.Touch and activeInput and input~=activeInput then
                return
            end
            dragging=false
            activeInput=nil
            if not moved and onTap then
                SafeCall("tap",onTap)
            end
            if target==Launcher then
                LayoutLauncher()
            end
        end
    end))
end

local function KeyName(key)
    return key and key.Name:upper() or "NONE"
end

local function Content(page)
    local scroll=N("ScrollingFrame",{
        Name="Content",
        Size=UDim2.new(1,-24,1,-68),
        Position=UDim2.fromOffset(12,58),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=C.red,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        CanvasSize=UDim2.new(),
        ZIndex=4,
        Parent=page
    })
    N("UIPadding",{
        PaddingRight=UDim.new(0,8),
        PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,2),
        PaddingTop=UDim.new(0,2),
        Parent=scroll
    })
    local list=N("UIListLayout",{
        Padding=UDim.new(0,12),
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=scroll
    })
    local content={scroll=scroll,list=list,order=0,sections={}}
    function content.Refresh()
        local total=0
        for _,section in ipairs(content.sections) do
            total=total+section.height
        end
        total=total+math.max(#content.sections-1,0)*12+16
        scroll.CanvasSize=UDim2.fromOffset(0,total)
    end
    table.insert(STATE.layoutHooks,function()
        local compact=STATE.mobile and LAYOUT.height<330
        local top=STATE.mobile and (compact and 34 or 48) or 58
        scroll.Position=UDim2.fromOffset(12,top)
        scroll.Size=UDim2.new(1,-24,1,-(top+8))
        scroll.ScrollBarThickness=STATE.mobile and 6 or 4
        content.Refresh()
    end)
    return content
end

local function Section(content,title)
    content.order=content.order+1
    local frame=N("Frame",{
        Name=title,
        Size=UDim2.new(1,0,0,40),
        BackgroundTransparency=1,
        LayoutOrder=content.order,
        ZIndex=4,
        Parent=content.scroll
    })
    local label=T(frame,title,UDim2.new(1,-4,0,18),UDim2.fromOffset(4,0),11,C.redSoft,Enum.Font.GothamBlack)
    label.ZIndex=5
    local line=N("Frame",{
        Size=UDim2.new(1,-4,0,1),
        Position=UDim2.fromOffset(2,21),
        BackgroundColor3=C.red,
        BackgroundTransparency=.55,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=frame
    })
    G(line,C.red,C.black,0)
    local holder=N("Frame",{
        Name="Cards",
        Size=UDim2.new(1,0,0,10),
        Position=UDim2.fromOffset(0,30),
        BackgroundTransparency=1,
        ZIndex=4,
        Parent=frame
    })
    local grid=N("UIGridLayout",{
        CellSize=UDim2.fromOffset(LAYOUT.cellWidth,LAYOUT.cardHeight),
        CellPadding=UDim2.fromOffset(10,8),
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=holder
    })
    local section={frame=frame,holder=holder,grid=grid,count=0,height=40,content=content}
    function section.Resize()
        local rows=math.ceil(section.count/math.max(LAYOUT.columns,1))
        local h=rows*LAYOUT.cardHeight+math.max(rows-1,0)*8
        holder.Size=UDim2.new(1,0,0,h)
        section.height=30+h
        frame.Size=UDim2.new(1,0,0,section.height)
        content.Refresh()
    end
    table.insert(content.sections,section)
    table.insert(STATE.layoutHooks,function()
        grid.CellSize=UDim2.fromOffset(LAYOUT.cellWidth,LAYOUT.cardHeight)
        section.Resize()
    end)
    return section
end

local function Card(section)
    section.count=section.count+1
    local card=N("Frame",{
        BackgroundColor3=C.card,
        BackgroundTransparency=.08,
        BorderSizePixel=0,
        LayoutOrder=section.count,
        ZIndex=5,
        Parent=section.holder
    })
    R(card,12)
    S(card,C.red,1)
    G(card,C.cardHi,C.card,90)
    section.Resize()
    return card
end

local function CardLabel(card,label,rightSpace)
    local text=T(card,label,UDim2.new(1,-(14+rightSpace),1,-6),UDim2.fromOffset(14,3),11,C.white,Enum.Font.GothamBold)
    text.TextWrapped=true
    text.ZIndex=6
    return text
end

local function Register(obj)
    obj.id=(STATE.buildPrefix or "MENU").."/"..tostring(obj.Label)
    table.insert(STATE.controls,obj)
    return obj
end

local function AttachKey(card,obj,offset)
    local keyButton=B(card,"[NONE]",UDim2.fromOffset(66,24),UDim2.new(1,offset,.5,-12))
    keyButton.BackgroundColor3=C.off
    keyButton.TextColor3=C.dim
    keyButton.TextSize=9
    keyButton.ZIndex=7
    obj.KeyButton=keyButton
    obj.keyId=(STATE.buildPrefix or "MENU").."/"..tostring(obj.Label)
    function obj.SetKey(key)
        obj.Key=key
        keyButton.Text="["..KeyName(key).."]"
        keyButton.TextColor3=key and C.redSoft or C.dim
    end
    Track(keyButton.Activated:Connect(function()
        if STATE.listening==obj then
            STATE.listening=nil
            obj.SetKey(obj.Key)
            return
        end
        if STATE.listening and STATE.listening.SetKey then
            STATE.listening.SetKey(STATE.listening.Key)
        end
        STATE.listening=obj
        keyButton.Text="[...]"
        keyButton.TextColor3=C.gold
    end))
    table.insert(STATE.keyed,obj)
end

local function MakeToggle(section,label,default,onChange)
    local card=Card(section)
    local text=CardLabel(card,label,132)
    local switch=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        Size=UDim2.fromOffset(46,24),
        Position=UDim2.new(1,-58,.5,-12),
        BackgroundColor3=C.off,
        BorderSizePixel=0,
        ZIndex=7,
        Parent=card
    })
    R(switch,12)
    local switchStroke=S(switch,C.red,1)
    local knob=N("Frame",{
        Size=UDim2.fromOffset(18,18),
        Position=UDim2.fromOffset(3,3),
        BackgroundColor3=C.gray,
        BorderSizePixel=0,
        ZIndex=8,
        Parent=switch
    })
    R(knob,9)
    local hit=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-140,1,0),
        ZIndex=6,
        Parent=card
    })
    local obj={kind="toggle",id=label,Label=label,Default=default and true or false,State=false,Key=nil}
    function obj.Set(value,silent)
        obj.State=value and true or false
        Tween(switch,.16,{BackgroundColor3=obj.State and C.red or C.off})
        Tween(knob,.16,{
            Position=obj.State and UDim2.fromOffset(25,3) or UDim2.fromOffset(3,3),
            BackgroundColor3=obj.State and C.white or C.gray
        })
        text.TextColor3=obj.State and C.white or C.gray
        switchStroke.Color=obj.State and C.gold or C.red
        if not silent then
            SafeCall(label,onChange,obj.State)
            Notify(label,obj.State and "ACTIVADO" or "DESACTIVADO",obj.State and C.red or C.dim)
        end
    end
    function obj.Get()
        return obj.State
    end
    function obj.Trigger()
        obj.Set(not obj.State)
    end
    AttachKey(card,obj,-132)
    Track(switch.Activated:Connect(obj.Trigger))
    Track(hit.Activated:Connect(obj.Trigger))
    table.insert(STATE.layoutHooks,function()
        obj.KeyButton.Visible=not STATE.mobile
        local right=STATE.mobile and 70 or 132
        text.Size=UDim2.new(1,-(14+right),1,-6)
        hit.Size=UDim2.new(1,-right,1,0)
    end)
    obj.Set(obj.Default,true)
    return Register(obj)
end

local function MakeButton(section,label,actionText,onClick)
    local card=Card(section)
    local text=CardLabel(card,label,176)
    local run=B(card,actionText or "EJECUTAR",UDim2.fromOffset(92,28),UDim2.new(1,-104,.5,-14))
    run.BackgroundColor3=C.redDeep
    run.TextColor3=C.white
    run.TextSize=10
    run.ZIndex=7
    S(run,C.red,1)
    local obj={kind="button",id=label,Label=label,Key=nil}
    function obj.Trigger()
        Tween(run,.08,{BackgroundColor3=C.red})
        task.delay(.12,function()
            if run.Parent then
                Tween(run,.15,{BackgroundColor3=C.redDeep})
            end
        end)
        SafeCall(label,onClick)
    end
    AttachKey(card,obj,-176)
    Track(run.Activated:Connect(obj.Trigger))
    table.insert(STATE.layoutHooks,function()
        obj.KeyButton.Visible=not STATE.mobile
        local right=STATE.mobile and 112 or 176
        text.Size=UDim2.new(1,-(14+right),1,-6)
    end)
    return obj
end

local function MakeSlider(section,label,min,max,default,decimals,suffix,onChange)
    local card=Card(section)
    local text=T(card,label,UDim2.new(1,-110,0,18),UDim2.fromOffset(14,6),11,C.white,Enum.Font.GothamBold)
    text.ZIndex=6
    local valueLabel=T(card,"",UDim2.fromOffset(86,18),UDim2.new(1,-100,0,6),11,C.redSoft,Enum.Font.GothamBlack)
    valueLabel.TextXAlignment=Enum.TextXAlignment.Right
    valueLabel.ZIndex=6
    local track=N("Frame",{
        Size=UDim2.new(1,-28,0,6),
        Position=UDim2.new(0,14,1,-16),
        BackgroundColor3=C.off,
        BorderSizePixel=0,
        ZIndex=6,
        Parent=card
    })
    R(track,3)
    local fill=N("Frame",{
        Size=UDim2.fromScale(0,1),
        BackgroundColor3=C.red,
        BorderSizePixel=0,
        ZIndex=7,
        Parent=track
    })
    R(fill,3)
    G(fill,C.redSoft,C.red,0)
    local knob=N("Frame",{
        Size=UDim2.fromOffset(16,16),
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(0,.5),
        BackgroundColor3=C.white,
        BorderSizePixel=0,
        ZIndex=8,
        Parent=track
    })
    R(knob,8)
    S(knob,C.red,1.5,false)
    local hit=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-12,0,30),
        Position=UDim2.new(0,6,1,-30),
        ZIndex=9,
        Parent=card
    })
    local obj={kind="slider",id=label,Label=label,Default=default,Value=default}
    local format="%."..tostring(decimals or 0).."f"
    local function render()
        local rel=(obj.Value-min)/math.max(max-min,1e-6)
        fill.Size=UDim2.fromScale(rel,1)
        knob.Position=UDim2.fromScale(rel,.5)
        valueLabel.Text=string.format(format,obj.Value)..(suffix or "")
    end
    function obj.Set(value,silent)
        local factor=10^(decimals or 0)
        value=tonumber(value) or obj.Default
        value=math.clamp(math.floor(value*factor+.5)/factor,min,max)
        local changed=value~=obj.Value
        obj.Value=value
        render()
        if not silent and (changed or silent==false) then
            SafeCall(label,onChange,value)
        end
    end
    function obj.Get()
        return obj.Value
    end
    local dragging=false
    local dragInput=nil
    local function fromX(x)
        local width=track.AbsoluteSize.X
        if width<=0 then
            return
        end
        local rel=math.clamp((x-track.AbsolutePosition.X)/width,0,1)
        obj.Set(min+(max-min)*rel)
    end
    Track(hit.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragInput=input
            section.content.scroll.ScrollingEnabled=false
            fromX(input.Position.X)
        end
    end))
    Track(UIS.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType==Enum.UserInputType.MouseMovement or (input.UserInputType==Enum.UserInputType.Touch and (dragInput==nil or input==dragInput or dragInput.UserInputType~=Enum.UserInputType.Touch)) then
            fromX(input.Position.X)
        end
    end))
    Track(UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            dragging=false
            dragInput=nil
            section.content.scroll.ScrollingEnabled=true
        end
    end))
    obj.Value=math.clamp(default,min,max)
    render()
    return Register(obj)
end

local function MakeSelector(section,label,options,defaultValue,onChange)
    local card=Card(section)
    local text=CardLabel(card,label,186)
    local left=B(card,"<",UDim2.fromOffset(28,28),UDim2.new(1,-182,.5,-14))
    local value=B(card,"",UDim2.fromOffset(112,28),UDim2.new(1,-150,.5,-14))
    local right=B(card,">",UDim2.fromOffset(28,28),UDim2.new(1,-36,.5,-14))
    for _,button in ipairs({left,value,right}) do
        button.BackgroundColor3=C.off
        button.TextColor3=C.redSoft
        button.TextSize=10
        button.ZIndex=7
        S(button,C.red,1)
    end
    value.TextColor3=C.white
    local defaultIndex=1
    for i,option in ipairs(options) do
        if option[2]==defaultValue then
            defaultIndex=i
        end
    end
    local obj={kind="selector",id=label,Label=label,Default=defaultIndex,Index=defaultIndex}
    local function render()
        value.Text=options[obj.Index][1]
    end
    function obj.Set(index,silent)
        index=tonumber(index) or obj.Default
        index=((math.floor(index)-1)%#options)+1
        obj.Index=index
        render()
        if not silent then
            SafeCall(label,onChange,options[index][2])
            Notify(label,options[index][1],C.red)
        end
    end
    function obj.Get()
        return obj.Index
    end
    function obj.Value()
        return options[obj.Index][2]
    end
    Track(left.Activated:Connect(function()
        obj.Set(obj.Index-1)
    end))
    Track(right.Activated:Connect(function()
        obj.Set(obj.Index+1)
    end))
    Track(value.Activated:Connect(function()
        obj.Set(obj.Index+1)
    end))
    table.insert(STATE.layoutHooks,function()
        local compact=LAYOUT.cellWidth<330
        local valueWidth=compact and 92 or 112
        value.Size=UDim2.fromOffset(valueWidth,28)
        right.Position=UDim2.new(1,-36,.5,-14)
        value.Position=UDim2.new(1,-(36+4+valueWidth),.5,-14)
        left.Position=UDim2.new(1,-(36+4+valueWidth+4+28),.5,-14)
        text.Size=UDim2.new(1,-(14+36+4+valueWidth+4+28+8),1,-6)
    end)
    render()
    return Register(obj)
end

local function MakeKeybind(section,label,default,onSet)
    local card=Card(section)
    CardLabel(card,label,120)
    local keyButton=B(card,"",UDim2.fromOffset(104,28),UDim2.new(1,-116,.5,-14))
    keyButton.BackgroundColor3=C.off
    keyButton.TextColor3=C.redSoft
    keyButton.TextSize=10
    keyButton.ZIndex=7
    S(keyButton,C.red,1)
    local obj={kind="keybind",id=label,Label=label,Default=default,Key=default,IsMenuKey=true}
    function obj.SetKey(key)
        obj.Key=key
        keyButton.Text="["..KeyName(key).."]"
        keyButton.TextColor3=key and C.redSoft or C.dim
        SafeCall(label,onSet,key)
    end
    function obj.Set(key)
        if typeof(key)=="EnumItem" then
            obj.SetKey(key)
        elseif type(key)=="string" and Enum.KeyCode[key] then
            obj.SetKey(Enum.KeyCode[key])
        else
            obj.SetKey(obj.Default)
        end
    end
    function obj.Get()
        return obj.Key and obj.Key.Name or nil
    end
    Track(keyButton.Activated:Connect(function()
        if STATE.listening==obj then
            STATE.listening=nil
            obj.SetKey(obj.Key)
            return
        end
        if STATE.listening and STATE.listening.SetKey then
            STATE.listening.SetKey(STATE.listening.Key)
        end
        STATE.listening=obj
        keyButton.Text="[PULSA TECLA]"
        keyButton.TextColor3=C.gold
    end))
    keyButton.Text="["..KeyName(default).."]"
    return Register(obj)
end

C.blue=C.redSoft
C.hover=C.hover or C.cardHi

local PeoplePage=Pages.PEOPLE

local List=N("ScrollingFrame",{
    Name="PlayerList",
    Size=UDim2.new(0,200,1,-64),
    Position=UDim2.fromOffset(12,54),
    BackgroundColor3=C.black,
    BackgroundTransparency=.45,
    BorderSizePixel=0,
    ScrollBarThickness=4,
    ScrollBarImageColor3=C.red,
    CanvasSize=UDim2.new(),
    ZIndex=4,
    Parent=PeoplePage
})
R(List,12)
S(List,C.red,1)
N("UIPadding",{
    PaddingTop=UDim.new(0,6),
    PaddingBottom=UDim.new(0,6),
    PaddingLeft=UDim.new(0,2),
    PaddingRight=UDim.new(0,6),
    Parent=List
})
local LL=N("UIListLayout",{
    Padding=UDim.new(0,6),
    SortOrder=Enum.SortOrder.LayoutOrder,
    Parent=List
})
Track(LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize=UDim2.fromOffset(0,LL.AbsoluteContentSize.Y/math.max(MainScale.Scale,.01)+16)
end))

local Info=N("Frame",{
    Name="Profile",
    Size=UDim2.new(1,-236,1,-64),
    Position=UDim2.fromOffset(222,54),
    BackgroundColor3=C.black,
    BackgroundTransparency=.45,
    BorderSizePixel=0,
    ZIndex=4,
    Parent=PeoplePage
})
R(Info,12)
S(Info,C.red,1)

local View=N("ViewportFrame",{
    Size=UDim2.fromOffset(240,240),
    Position=UDim2.fromOffset(12,12),
    BackgroundColor3=C.black,
    Ambient=Color3.fromRGB(200,190,195),
    LightColor=C.white,
    LightDirection=Vector3.new(-1,-1,-1),
    ZIndex=5,
    Parent=Info
})
R(View,12)
S(View,C.red,1)

local Camera=N("Camera",{Parent=View})
View.CurrentCamera=Camera

local Name=T(Info,"Selecciona un jugador",UDim2.new(1,-280,0,26),UDim2.fromOffset(268,14),18,C.white,Enum.Font.GothamBlack)
Name.ZIndex=5
local User=T(Info,"@-",UDim2.new(1,-280,0,18),UDim2.fromOffset(268,42),11,C.redSoft,Enum.Font.GothamBold)
User.ZIndex=5
local State=T(Info,"estado: --",UDim2.new(1,-280,0,18),UDim2.fromOffset(268,62),11,C.gray,Enum.Font.GothamMedium)
State.ZIndex=5

local DetailList=N("ScrollingFrame",{
    Size=UDim2.new(1,-280,1,-100),
    Position=UDim2.fromOffset(268,88),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=4,
    ScrollBarImageColor3=C.red,
    CanvasSize=UDim2.new(),
    ZIndex=5,
    Parent=Info
})
local DL=N("UIListLayout",{
    Padding=UDim.new(0,6),
    SortOrder=Enum.SortOrder.LayoutOrder,
    Parent=DetailList
})
Track(DL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DetailList.CanvasSize=UDim2.fromOffset(0,DL.AbsoluteContentSize.Y/math.max(MainScale.Scale,.01)+10)
end))

table.insert(STATE.layoutHooks,function()
    local pageWidth=LAYOUT.width-24
    local pageHeight=LAYOUT.height-(LAYOUT.header+32)
    local compact=STATE.mobile and LAYOUT.height<330
    local top=STATE.mobile and (compact and 34 or 48) or 54
    local listWidth=pageWidth<520 and 112 or (STATE.mobile and 160 or 200)
    List.Position=UDim2.fromOffset(10,top)
    List.Size=UDim2.new(0,listWidth,1,-(top+10))
    Info.Position=UDim2.fromOffset(listWidth+18,top)
    Info.Size=UDim2.new(1,-(listWidth+28),1,-(top+10))
    local infoWidth=pageWidth-(listWidth+28)
    local infoHeight=pageHeight-(top+10)
    local view=math.floor(math.clamp(math.min(infoHeight-24,infoWidth*.45,250),70,250))
    local sideWidth=infoWidth-view-36
    if sideWidth>=150 then
        View.Size=UDim2.fromOffset(view,view)
        View.Position=UDim2.fromOffset(12,12)
        Name.Position=UDim2.fromOffset(view+24,12)
        Name.Size=UDim2.new(1,-(view+36),0,24)
        User.Position=UDim2.fromOffset(view+24,38)
        User.Size=UDim2.new(1,-(view+36),0,18)
        State.Position=UDim2.fromOffset(view+24,56)
        State.Size=UDim2.new(1,-(view+36),0,18)
        DetailList.Position=UDim2.fromOffset(view+24,80)
        DetailList.Size=UDim2.new(1,-(view+36),1,-92)
    else
        view=math.floor(math.clamp(math.min(infoWidth-24,infoHeight*.42),70,180))
        View.Size=UDim2.fromOffset(view,view)
        View.Position=UDim2.new(.5,-view/2,0,10)
        Name.Position=UDim2.fromOffset(10,view+14)
        Name.Size=UDim2.new(1,-20,0,20)
        User.Position=UDim2.fromOffset(10,view+34)
        User.Size=UDim2.new(1,-20,0,16)
        State.Position=UDim2.fromOffset(10,view+50)
        State.Size=UDim2.new(1,-20,0,16)
        DetailList.Position=UDim2.fromOffset(10,view+70)
        DetailList.Size=UDim2.new(1,-20,1,-(view+78))
    end
    Name.TextSize=STATE.mobile and 15 or 18
end)
local function Clear(parent)
    for _,child in ipairs(parent:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function Detail(title,value,color)
    local box=N("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundColor3=C.card,
        Parent=DetailList
    })

    R(box,9)

    N("Frame",{
        Size=UDim2.fromOffset(4,60),
        BackgroundColor3=color,
        Parent=box
    })

    T(
        box,
        title,
        UDim2.new(1,-20,0,16),
        UDim2.fromOffset(14,5),
        10,
        color,
        Enum.Font.GothamBold
    )

    local valueLabel=T(
        box,
        value,
        UDim2.new(1,-20,0,34),
        UDim2.fromOffset(14,23),
        11,
        C.white
    )

    valueLabel.TextWrapped=true
    valueLabel.TextYAlignment=Enum.TextYAlignment.Top
end

local function Tools(player)
    local tools={}
    local backpack=player:FindFirstChildOfClass("Backpack")

    if backpack then
        for _,item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools,item.Name)
            end
        end
    end

    if player.Character then
        for _,item in ipairs(player.Character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools,item.Name.." equipada")
            end
        end
    end

    return #tools>0 and table.concat(tools,", ")
        or "sin armas visibles"
end

local function Clothes(player)
    local clothes={}

    if player.Character then
        for _,item in ipairs(player.Character:GetChildren()) do
            if item:IsA("Shirt")
                or item:IsA("Pants")
                or item:IsA("ShirtGraphic") then

                table.insert(
                    clothes,
                    item.ClassName..": "..item.Name
                )
            end
        end
    end

    return #clothes>0 and table.concat(clothes," • ")
        or "ropa predeterminada"
end
local AMONG={
    red=Color3.fromRGB(197,17,17),
    blue=Color3.fromRGB(19,46,209),
    green=Color3.fromRGB(17,128,45),
    pink=Color3.fromRGB(237,84,186),
    orange=Color3.fromRGB(239,125,13),
    yellow=Color3.fromRGB(245,245,87),
    black=Color3.fromRGB(63,71,78),
    white=Color3.fromRGB(214,224,240),
    purple=Color3.fromRGB(107,47,188),
    brown=Color3.fromRGB(113,73,30),
    cyan=Color3.fromRGB(57,254,221),
    lime=Color3.fromRGB(80,239,57)
}

local NEON_COLOR=Color3.fromRGB(190,210,225)
local FF_ORANGE=Color3.fromRGB(255,110,10)
local FF_DARK=Color3.fromRGB(30,30,34)
local FF_SKIN=Color3.fromRGB(255,204,153)

local SKIN_LIST={
    {"normal","NORMAL"},
    {"freefire","FREE FIRE"},
    {"neon","NEON"},
    {"red","ROJO"},
    {"blue","AZUL"},
    {"green","VERDE"},
    {"pink","ROSA"},
    {"orange","NARANJA"},
    {"yellow","AMARILLO"},
    {"black","NEGRO"},
    {"white","BLANCO"},
    {"purple","MORADO"},
    {"brown","CAFE"},
    {"cyan","CIAN"},
    {"lime","LIMA"}
}

local skin="normal"
local ownSkinOn=true
local ownStore={}
local previewStore={}

local function Restore(store)
    for inst,data in pairs(store) do
        if data.created then
            pcall(function()
                inst:Destroy()
            end)
        elseif data.parent then
            pcall(function()
                inst.Parent=data.parent
            end)
        elseif data.props then
            for k,v in pairs(data.props) do
                pcall(function()
                    inst[k]=v
                end)
            end
        end
    end

    table.clear(store)
end

local function FFColor(part)
    local n=part.Name:lower()

    if n=="head" or n:find("hand") then
        return FF_SKIN
    elseif n:find("foot") then
        return FF_ORANGE
    elseif n=="torso" or n=="uppertorso" then
        return FF_ORANGE
    end

    return FF_DARK
end

local function Paint(model,store,key,anchored)
    Restore(store)

    if not model or key=="normal" then
        return
    end

    local among=AMONG[key]~=nil
    local ff=key=="freefire"
    local strip=among or ff

    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("Shirt")
            or item:IsA("Pants")
            or item:IsA("ShirtGraphic")
            or (strip and item:IsA("Accessory")) then

            store[item]={parent=item.Parent}
            item.Parent=nil

        elseif item:IsA("Decal")
            and item.Name:lower()=="face"
            and not ff then

            store[item]={props={Transparency=item.Transparency}}
            item.Transparency=1
        end
    end

    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            store[item]={
                props={
                    Color=item.Color,
                    Material=item.Material
                }
            }

            if ff then
                item.Color=FFColor(item)
                item.Material=Enum.Material.SmoothPlastic
            elseif among then
                item.Color=AMONG[key]
                item.Material=Enum.Material.SmoothPlastic
            else
                item.Color=NEON_COLOR
                item.Material=Enum.Material.Neon
            end
        end
    end

    if ff then
        local head=model:FindFirstChild("Head")
        local hrp=model:FindFirstChild("HumanoidRootPart")

        local torso=model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")

        if head and head:IsA("BasePart") then
            local band=N("Part",{
                Name="FFBandana",
                Size=Vector3.new(
                    head.Size.X+.12,
                    .35,
                    head.Size.Z+.12
                ),
                Color=Color3.fromRGB(215,40,20),
                Material=Enum.Material.SmoothPlastic,
                CanCollide=false,
                CanQuery=false,
                Massless=true,
                Anchored=anchored,
                CFrame=head.CFrame*CFrame.new(0,head.Size.Y*.28,0),
                Parent=model
            })

            if not anchored then
                N("WeldConstraint",{
                    Part0=head,
                    Part1=band,
                    Parent=band
                })
            end

            store[band]={created=true}
        end

        local host=hrp or torso

        if host then
            local fire=N("Fire",{
                Color=Color3.fromRGB(255,130,0),
                SecondaryColor=Color3.fromRGB(255,40,0),
                Size=5,
                Heat=9,
                Parent=host
            })

            store[fire]={created=true}
        end

        if torso then
            local light=N("PointLight",{
                Color=Color3.fromRGB(255,120,20),
                Range=12,
                Brightness=1.5,
                Parent=torso
            })

            store[light]={created=true}
        end

        if not anchored then
            local hl=N("Highlight",{
                Adornee=model,
                FillTransparency=1,
                OutlineColor=FF_ORANGE,
                OutlineTransparency=.2,
                Parent=model
            })

            store[hl]={created=true}
        end
    end
end
local Selected=LP
local Model=nil
local BaseY=0
local FocusY=2
local yaw=0
local pitch=0
local distance=7
local drag=false
local last=nil

local function ApplyOwn()
    local ch=LP.Character

    if ownSkinOn and ch then
        Paint(ch,ownStore,skin,false)
    else
        Restore(ownStore)
    end
end

local function ApplyPreview()
    if Model then
        Paint(Model,previewStore,skin,true)
    end
end

local function ApplySkin()
    ApplyPreview()
    ApplyOwn()
end

local function Cam()
    if Model and Model.Parent then
        Camera.CFrame=CFrame.lookAt(
            Vector3.new(0,FocusY,distance),
            Vector3.new(0,FocusY,0)
        )
    end
end

local function ShowModel(player)
    for _,child in ipairs(View:GetChildren()) do
        if child:IsA("Model") or child:IsA("Camera") then
            child:Destroy()
        end
    end

    Camera=N("Camera",{
        Parent=View
    })

    View.CurrentCamera=Camera
    Model=nil
    table.clear(previewStore)
    BaseY=0
    FocusY=2
    distance=7

    if not player.Character then
        return
    end

    local wasOwn=player==LP and next(ownStore)~=nil

    if wasOwn then
        Restore(ownStore)
    end

    player.Character.Archivable=true

    local clone=player.Character:Clone()

    player.Character.Archivable=false

    if wasOwn then
        ApplyOwn()
    end

    if not clone then
        return
    end

    for _,item in ipairs(clone:GetDescendants()) do
        if item:IsA("Script")
            or item:IsA("LocalScript")
            or item:IsA("ModuleScript")
            or item:IsA("Tool") then

            item:Destroy()

        elseif item:IsA("BasePart") then
            item.Anchored=true
            item.AssemblyLinearVelocity=Vector3.zero
            item.AssemblyAngularVelocity=Vector3.zero

        elseif item:IsA("Motor6D") then
            item.Transform=CFrame.new()
        end
    end

    clone.Parent=View

    local boundsCFrame,boundsSize=clone:GetBoundingBox()
    local bottom=boundsCFrame.Position.Y-boundsSize.Y/2

    BaseY=-bottom+.1
    FocusY=BaseY+boundsSize.Y*.48
    distance=math.clamp(boundsSize.Y*1.35,6,10)

    Model=clone

    clone:PivotTo(
        CFrame.new(0,BaseY,0)
    )

    ApplyPreview()
    Cam()
end

local function Show(player)
    Selected=player

    Name.Text=player.DisplayName
    User.Text="@"..player.Name.." | "..player.UserId

    State.Text=player.Character
        and "estado: modelo quieto"
        or "estado: esperando"

    Clear(DetailList)

    Detail(
        "IDENTIDAD",
        "nombre: "..player.DisplayName.."\nusuario: @"..player.Name,
        C.blue
    )

    Detail(
        "ROPA",
        Clothes(player),
        C.gold
    )

    Detail(
        "ARMAS",
        Tools(player),
        C.red
    )

    ShowModel(player)
end

local function Update()
    Clear(List)

    local all=Players:GetPlayers()

    table.sort(
        all,
        function(a,b)
            return a.DisplayName:lower()<b.DisplayName:lower()
        end
    )

    for i,player in ipairs(all) do
        local row=B(
            List,
            "",
            UDim2.new(1,-8,0,52),
            UDim2.fromOffset(4,0)
        )

        row.LayoutOrder=i
        row.BackgroundColor3=player==Selected and C.hover or C.card

        local image=N("ImageLabel",{
            Size=UDim2.fromOffset(36,36),
            Position=UDim2.fromOffset(8,8),
            BackgroundColor3=C.black,
            Parent=row
        })

        R(image,18)

        task.spawn(function()
            local ok,url=pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)

            if ok and image.Parent then
                image.Image=url
            end
        end)

        T(
            row,
            player.DisplayName,
            UDim2.new(1,-52,0,18),
            UDim2.fromOffset(52,7),
            11,
            C.white,
            Enum.Font.GothamBold
        )

        T(
            row,
            "@"..player.Name,
            UDim2.new(1,-52,0,16),
            UDim2.fromOffset(52,27),
            9,
            C.gray
        )

        row.Activated:Connect(function()
            Show(player)
            Update()
        end)
    end
end


local Engine={}

local function AsPart(object)
    if object and object:IsA("BasePart") then
        return object
    end
    return nil
end

function Engine.Targets()
    local now=os.clock()
    if now-STATE.targetCacheTime<.2 then
        return STATE.targetCache
    end
    local output={}
    local seen={}
    local own=LP.Character
    local function add(model)
        if typeof(model)=="Instance" and model:IsA("Model") and model~=own and not seen[model] and model:IsDescendantOf(workspace) then
            seen[model]=true
            table.insert(output,model)
        end
    end
    local folder=workspace:FindFirstChild("Targets")
    if folder then
        for _,model in ipairs(folder:GetChildren()) do
            add(model)
        end
    end
    local ok,tagged=pcall(function()
        return CollectionService:GetTagged("Target")
    end)
    if ok and type(tagged)=="table" then
        for _,model in ipairs(tagged) do
            add(model)
        end
    end
    STATE.targetCache=output
    STATE.targetCacheTime=now
    STATE.targetCount=#output
    return output
end

function Engine.IsFriendly(model)
    if not CFG.ui.teamCheck then
        return false
    end
    local player=Players:GetPlayerFromCharacter(model)
    if player and LP.Team and player.Team==LP.Team then
        return true
    end
    local team=model:GetAttribute("Team")
    return team~=nil and LP.Team~=nil and tostring(team)==LP.Team.Name
end

function Engine.Parts(model)
    local hum=model:FindFirstChildOfClass("Humanoid")
    local root=AsPart(model:FindFirstChild("HumanoidRootPart"))
        or AsPart(model.PrimaryPart)
        or AsPart(model:FindFirstChild("UpperTorso"))
        or AsPart(model:FindFirstChild("Torso"))
        or model:FindFirstChildWhichIsA("BasePart",true)
    local head=AsPart(model:FindFirstChild("Head"))
    return hum,root,head
end

function Engine.BonePoint(model,bone)
    local _,root,head=Engine.Parts(model)
    local upper=AsPart(model:FindFirstChild("UpperTorso")) or AsPart(model:FindFirstChild("Torso"))
    local lower=AsPart(model:FindFirstChild("LowerTorso"))
    if bone=="Head" and head then
        return head,head.Position
    end
    if bone=="Neck" and head then
        return head,head.Position-head.CFrame.UpVector*(head.Size.Y*.45)
    end
    if bone=="Chest" and upper then
        return upper,upper.Position+upper.CFrame.UpVector*(upper.Size.Y*.15)
    end
    if bone=="Hip" then
        if lower then
            return lower,lower.Position
        end
        if upper then
            return upper,upper.Position-upper.CFrame.UpVector*(upper.Size.Y*.4)
        end
    end
    local part=upper or root or head
    if part then
        return part,part.Position
    end
    return nil,nil
end

local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Exclude

function Engine.Visible(origin,model,point)
    local filter={model}
    if LP.Character then
        table.insert(filter,LP.Character)
    end
    rayParams.FilterDescendantsInstances=filter
    local direction=point-origin
    for _=1,4 do
        local result=workspace:Raycast(origin,direction,rayParams)
        if not result then
            return true
        end
        local hit=result.Instance
        if hit and hit:IsA("BasePart") and (hit.Transparency>=.8 or not hit.CanCollide) then
            table.insert(filter,hit)
            rayParams.FilterDescendantsInstances=filter
        else
            return false
        end
    end
    return false
end

local AimMarker=N("Frame",{
    Size=UDim2.fromOffset(24,24),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundTransparency=1,
    Visible=false,
    ZIndex=3,
    Parent=Gui
})
N("UICorner",{CornerRadius=UDim.new(1,0),Parent=AimMarker})
N("UIStroke",{Color=C.gold,Thickness=2,Parent=AimMarker})
local AimMarkerLabel=T(AimMarker,"AIM",UDim2.fromOffset(60,14),UDim2.new(.5,-30,1,4),10,C.gold,Enum.Font.GothamBlack)
AimMarkerLabel.TextXAlignment=Enum.TextXAlignment.Center
AimMarkerLabel.TextStrokeTransparency=.2
AimMarkerLabel.TextStrokeColor3=C.black

function Engine.AimActive()
    local mode=CFG.aim.activation
    if mode=="Always" then
        return true
    end
    if mode=="Hold" then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    if mode=="HoldAny" then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end
    if mode=="Touch" then
        return next(STATE.touches)~=nil
    end
    return false
end

function Engine.EvaluateAim(model,camera,center,origin,from,fov)
    if not model.Parent or Engine.IsFriendly(model) then
        return false
    end
    local hum=model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health<=0 then
        return false
    end
    local part,point=Engine.BonePoint(model,CFG.aim.bone)
    if not part or not point then
        return false
    end
    local worldDistance=(point-from).Magnitude
    if worldDistance>CFG.aim.range then
        return false
    end
    local screen,onScreen=camera:WorldToViewportPoint(point)
    if not onScreen then
        return false
    end
    local screenDistance=(Vector2.new(screen.X,screen.Y)-center).Magnitude
    if screenDistance>fov then
        return false
    end
    if CFG.aim.wall and not Engine.Visible(origin,model,point) then
        return false
    end
    return true,part,point,screenDistance,worldDistance
end

function Engine.FindAimTarget(camera)
    local center=camera.ViewportSize/2
    local origin=camera.CFrame.Position
    local root=Root()
    local from=root and root.Position or origin
    if CFG.aim.lock and STATE.aimModel and STATE.aimModel~=STATE.skipModel then
        local ok,part,point=Engine.EvaluateAim(STATE.aimModel,camera,center,origin,from,CFG.aim.fov*1.35)
        if ok then
            return STATE.aimModel,part,point
        end
    end
    local bestModel,bestPart,bestPoint=nil,nil,nil
    local bestScore=math.huge
    for _,model in ipairs(Engine.Targets()) do
        if model~=STATE.skipModel then
            local ok,part,point,screenDistance,worldDistance=Engine.EvaluateAim(model,camera,center,origin,from,CFG.aim.fov)
            if ok then
                local score=CFG.aim.priority=="Distance" and worldDistance or screenDistance
                if score<bestScore then
                    bestScore=score
                    bestModel=model
                    bestPart=part
                    bestPoint=point
                end
            end
        end
    end
    if not bestModel and STATE.skipModel then
        STATE.skipModel=nil
    end
    return bestModel,bestPart,bestPoint
end

function Engine.SwitchTarget()
    if STATE.aimModel then
        STATE.skipModel=STATE.aimModel
        STATE.aimModel=nil
        Notify("AIM ASSIST","Objetivo cambiado",C.gold)
    else
        STATE.skipModel=nil
        Notify("AIM ASSIST","Sin objetivo para cambiar",C.dim)
    end
end

function Engine.AimStep(dt)
    local camera=workspace.CurrentCamera
    local aim=CFG.aim
    FovCircle.Visible=aim.enabled and aim.showFov
    FovCircle.Size=UDim2.fromOffset(aim.fov*2,aim.fov*2)
    if not aim.enabled or not camera then
        STATE.aimModel=nil
        STATE.aimPart=nil
        AimMarker.Visible=false
        FovStroke.Color=C.red
        return
    end
    if not Engine.AimActive() then
        if not aim.lock then
            STATE.aimModel=nil
        end
        STATE.aimPart=nil
        AimMarker.Visible=false
        FovStroke.Color=C.red
        return
    end
    local model,part,point=Engine.FindAimTarget(camera)
    STATE.aimModel=model
    STATE.aimPart=part
    FovStroke.Color=model and C.gold or C.red
    if not point then
        AimMarker.Visible=false
        return
    end
    local screen=camera:WorldToViewportPoint(point)
    if aim.marker then
        AimMarker.Position=UDim2.fromOffset(screen.X,screen.Y)
        AimMarker.Visible=true
    else
        AimMarker.Visible=false
    end
    local offset=(Vector2.new(screen.X,screen.Y)-camera.ViewportSize/2).Magnitude
    if offset<=aim.deadzone then
        return
    end
    local current=camera.CFrame
    local goal=CFrame.lookAt(current.Position,point)
    local alpha=aim.strength>=.999 and 1 or math.clamp(1-(1-aim.strength)^(math.max(dt,1/240)*60),0,1)
    camera.CFrame=current:Lerp(goal,alpha)
end

local Esp={entries={}}

function Esp.New()
    local e={}
    e.box=N("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=3,Parent=EspLayer})
    e.stroke=N("UIStroke",{Color=C.red,Thickness=1.5,Transparency=0,Parent=e.box})
    e.corners={}
    for i=1,8 do
        e.corners[i]=N("Frame",{BackgroundColor3=C.red,BorderSizePixel=0,Visible=false,ZIndex=4,Parent=EspLayer})
    end
    e.name=T(EspLayer,"",UDim2.fromOffset(200,16),nil,11,C.white,Enum.Font.GothamBold)
    e.name.AnchorPoint=Vector2.new(.5,1)
    e.name.TextXAlignment=Enum.TextXAlignment.Center
    e.name.TextStrokeColor3=C.black
    e.name.TextStrokeTransparency=.15
    e.name.Visible=false
    e.name.ZIndex=5
    e.dist=T(EspLayer,"",UDim2.fromOffset(200,14),nil,10,C.gray,Enum.Font.GothamBold)
    e.dist.AnchorPoint=Vector2.new(.5,0)
    e.dist.TextXAlignment=Enum.TextXAlignment.Center
    e.dist.TextStrokeColor3=C.black
    e.dist.TextStrokeTransparency=.15
    e.dist.Visible=false
    e.dist.ZIndex=5
    e.hpBack=N("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.25,BorderSizePixel=0,Visible=false,ZIndex=4,Parent=EspLayer})
    e.hpStroke=N("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Transparency=.3,Parent=e.hpBack})
    e.hpFill=N("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.fromScale(1,1),BackgroundColor3=C.green,BorderSizePixel=0,ZIndex=5,Parent=e.hpBack})
    e.hpText=T(EspLayer,"",UDim2.fromOffset(40,12),nil,9,C.white,Enum.Font.GothamBold)
    e.hpText.AnchorPoint=Vector2.new(1,.5)
    e.hpText.TextXAlignment=Enum.TextXAlignment.Right
    e.hpText.TextStrokeColor3=C.black
    e.hpText.TextStrokeTransparency=.15
    e.hpText.Visible=false
    e.hpText.ZIndex=5
    e.tracer=N("Frame",{AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.red,BorderSizePixel=0,Visible=false,ZIndex=2,Parent=EspLayer})
    e.arrow=T(EspLayer,"▲",UDim2.fromOffset(24,24),nil,18,C.red,Enum.Font.GothamBlack)
    e.arrow.AnchorPoint=Vector2.new(.5,.5)
    e.arrow.TextXAlignment=Enum.TextXAlignment.Center
    e.arrow.TextStrokeColor3=C.black
    e.arrow.TextStrokeTransparency=.2
    e.arrow.Visible=false
    e.arrow.ZIndex=6
    return e
end

function Esp.HideCorners(e)
    for _,corner in ipairs(e.corners) do
        corner.Visible=false
    end
end

function Esp.Hide(e)
    e.box.Visible=false
    e.name.Visible=false
    e.dist.Visible=false
    e.hpBack.Visible=false
    e.hpText.Visible=false
    e.tracer.Visible=false
    e.arrow.Visible=false
    Esp.HideCorners(e)
end

function Esp.Destroy(e)
    for _,object in ipairs({e.box,e.name,e.dist,e.hpBack,e.hpText,e.tracer,e.arrow}) do
        if object and object.Parent then
            object:Destroy()
        end
    end
    for _,corner in ipairs(e.corners) do
        if corner.Parent then
            corner:Destroy()
        end
    end
end

function Esp.Clear()
    for model,e in pairs(Esp.entries) do
        Esp.Destroy(e)
        Esp.entries[model]=nil
    end
end

function Esp.Corners(e,left,top,width,height,thickness,color)
    local length=math.max(math.floor(math.min(width,height)*.28),4)
    local t=math.max(math.floor(thickness+.5),1)
    local right=left+width
    local bottom=top+height
    local layout={
        {left,top,length,t},
        {left,top,t,length},
        {right-length,top,length,t},
        {right-t,top,t,length},
        {left,bottom-t,length,t},
        {left,bottom-length,t,length},
        {right-length,bottom-t,length,t},
        {right-t,bottom-length,t,length}
    }
    for i,data in ipairs(layout) do
        local corner=e.corners[i]
        corner.Position=UDim2.fromOffset(data[1],data[2])
        corner.Size=UDim2.fromOffset(data[3],data[4])
        corner.BackgroundColor3=color
        corner.Visible=true
    end
end

function Esp.Bounds(camera,model,hum,root,head)
    local topWorld,bottomWorld
    if head and root then
        topWorld=head.Position+Vector3.new(0,head.Size.Y*.5+.25,0)
        local legs=3
        if hum and hum.RigType==Enum.HumanoidRigType.R15 then
            legs=hum.HipHeight+root.Size.Y*.5
        end
        bottomWorld=root.Position-Vector3.new(0,legs,0)
    else
        local ok,cf,size=pcall(function()
            return model:GetBoundingBox()
        end)
        if not ok or not cf then
            return false
        end
        topWorld=cf.Position+Vector3.new(0,size.Y*.5,0)
        bottomWorld=cf.Position-Vector3.new(0,size.Y*.5,0)
    end
    local topScreen=camera:WorldToViewportPoint(topWorld)
    local bottomScreen=camera:WorldToViewportPoint(bottomWorld)
    if topScreen.Z<=0 or bottomScreen.Z<=0 then
        return false
    end
    local height=math.abs(bottomScreen.Y-topScreen.Y)*CFG.esp.boxScale
    height=math.clamp(height,6,4000)
    local width=height*.55
    local centerX=(topScreen.X+bottomScreen.X)*.5
    local centerY=(topScreen.Y+bottomScreen.Y)*.5
    return true,centerX-width*.5,centerY-height*.5,width,height
end

function Esp.Step()
    local now=os.clock()
    local esp=CFG.esp
    if now-STATE.espLast<1/math.max(esp.rate,1) then
        return
    end
    STATE.espLast=now
    local camera=workspace.CurrentCamera
    local any=esp.boxes or esp.names or esp.distance or esp.health or esp.healthText or esp.tracers or esp.arrows
    local wanted={}
    if any and camera then
        local targets=Engine.Targets()
        for i=1,math.min(#targets,esp.maxTargets) do
            wanted[targets[i]]=true
        end
    end
    for model,e in pairs(Esp.entries) do
        if not wanted[model] or not model.Parent then
            Esp.Destroy(e)
            Esp.entries[model]=nil
        end
    end
    if not any or not camera then
        return
    end
    local viewport=camera.ViewportSize
    local origin=camera.CFrame.Position
    local myRoot=Root()
    local from=myRoot and myRoot.Position or origin
    for model in pairs(wanted) do
        local e=Esp.entries[model]
        if not e then
            e=Esp.New()
            Esp.entries[model]=e
        end
        local hum,root,head=Engine.Parts(model)
        local shown=false
        if root and (not hum or hum.Health>0) and not Engine.IsFriendly(model) then
            local distance=(root.Position-from).Magnitude
            if distance<=esp.range and (not esp.wall or Engine.Visible(origin,model,(head or root).Position)) then
                local fraction=hum and math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1) or 1
                local color=(esp.hpColor and hum) and Color3.fromHSV(fraction*.33,.85,1) or C.red
                if model==STATE.aimModel then
                    color=C.gold
                end
                local _,onScreen=camera:WorldToViewportPoint(root.Position)
                local ok,left,top,width,height=false,0,0,0,0
                if onScreen then
                    ok,left,top,width,height=Esp.Bounds(camera,model,hum,root,head)
                end
                if ok then
                    shown=true
                    e.arrow.Visible=false
                    local centerX=left+width*.5
                    if esp.boxes then
                        if esp.boxStyle=="Corners" then
                            e.box.Visible=false
                            Esp.Corners(e,left,top,width,height,esp.thickness,color)
                        else
                            Esp.HideCorners(e)
                            e.box.Position=UDim2.fromOffset(left,top)
                            e.box.Size=UDim2.fromOffset(width,height)
                            e.stroke.Color=color
                            e.stroke.Thickness=esp.thickness
                            e.box.Visible=true
                        end
                    else
                        e.box.Visible=false
                        Esp.HideCorners(e)
                    end
                    if esp.names then
                        local player=Players:GetPlayerFromCharacter(model)
                        e.name.Text=player and player.DisplayName or model.Name
                        e.name.Position=UDim2.fromOffset(centerX,top-3)
                        e.name.TextColor3=model==STATE.aimModel and C.gold or C.white
                        e.name.Visible=true
                    else
                        e.name.Visible=false
                    end
                    if esp.distance then
                        e.dist.Text=string.format("%d studs",math.floor(distance+.5))
                        e.dist.Position=UDim2.fromOffset(centerX,top+height+3)
                        e.dist.Visible=true
                    else
                        e.dist.Visible=false
                    end
                    local barWidth=math.clamp(math.floor(height*.035+.5),2,4)
                    if esp.health then
                        e.hpBack.Position=UDim2.fromOffset(left-barWidth-4,top)
                        e.hpBack.Size=UDim2.fromOffset(barWidth,height)
                        e.hpFill.Size=UDim2.fromScale(1,fraction)
                        e.hpFill.BackgroundColor3=Color3.fromHSV(fraction*.33,.85,1)
                        e.hpBack.Visible=true
                    else
                        e.hpBack.Visible=false
                    end
                    if esp.healthText and hum then
                        e.hpText.Text=tostring(math.floor(hum.Health+.5))
                        e.hpText.Position=UDim2.fromOffset(left-barWidth-7,top+height*(1-fraction))
                        e.hpText.TextColor3=Color3.fromHSV(fraction*.33,.85,1)
                        e.hpText.Visible=true
                    else
                        e.hpText.Visible=false
                    end
                    if esp.tracers then
                        local startPoint
                        local endPoint
                        if esp.tracerOrigin=="Top" then
                            startPoint=Vector2.new(viewport.X*.5,2)
                            endPoint=Vector2.new(centerX,top)
                        elseif esp.tracerOrigin=="Center" then
                            startPoint=viewport*.5
                            endPoint=Vector2.new(centerX,top+height*.5)
                        else
                            startPoint=Vector2.new(viewport.X*.5,viewport.Y-2)
                            endPoint=Vector2.new(centerX,top+height)
                        end
                        local delta=endPoint-startPoint
                        local middle=startPoint+delta*.5
                        e.tracer.Size=UDim2.fromOffset(math.max(delta.Magnitude,1),math.max(esp.thickness,1))
                        e.tracer.Position=UDim2.fromOffset(middle.X,middle.Y)
                        e.tracer.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                        e.tracer.BackgroundColor3=color
                        e.tracer.Visible=true
                    else
                        e.tracer.Visible=false
                    end
                elseif esp.arrows then
                    Esp.Hide(e)
                    local relative=camera.CFrame:PointToObjectSpace(root.Position)
                    local direction=Vector2.new(relative.X,-relative.Y)
                    if direction.Magnitude<.001 then
                        direction=Vector2.new(0,1)
                    end
                    direction=direction.Unit
                    local radius=math.min(viewport.X,viewport.Y)*.38
                    local center=viewport*.5
                    e.arrow.Position=UDim2.fromOffset(center.X+direction.X*radius,center.Y+direction.Y*radius)
                    e.arrow.Rotation=math.deg(math.atan2(direction.Y,direction.X))+90
                    e.arrow.TextColor3=color
                    e.arrow.Visible=true
                    shown=true
                end
            end
        end
        if not shown then
            Esp.Hide(e)
        end
    end
end

local Highlights={store={}}

function Highlights.Sync()
    local esp=CFG.esp
    local enabled=esp.xray or esp.outline
    local wanted={}
    if enabled then
        local count=0
        for _,model in ipairs(Engine.Targets()) do
            if count>=30 then
                break
            end
            if not Engine.IsFriendly(model) then
                wanted[model]=true
                count=count+1
            end
        end
    end
    for model,highlight in pairs(Highlights.store) do
        if not wanted[model] or not highlight.Parent then
            pcall(function()
                highlight:Destroy()
            end)
            Highlights.store[model]=nil
        end
    end
    for model in pairs(wanted) do
        local highlight=Highlights.store[model]
        if not highlight then
            highlight=N("Highlight",{
                Name="STIRLAX_Highlight",
                Adornee=model,
                DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
                Parent=model
            })
            Highlights.store[model]=highlight
        end
        if esp.xray then
            highlight.FillColor=C.red
            highlight.OutlineColor=C.white
            highlight.FillTransparency=esp.xrayFill
            highlight.OutlineTransparency=0
        else
            highlight.FillColor=C.red
            highlight.OutlineColor=C.red
            highlight.FillTransparency=1
            highlight.OutlineTransparency=0
        end
    end
end

function Highlights.Clear()
    for model,highlight in pairs(Highlights.store) do
        pcall(function()
            highlight:Destroy()
        end)
        Highlights.store[model]=nil
    end
end

local World={active=false,fadeStore={},fadeConn=nil,atmosphere={}}

function World.Apply()
    local w=CFG.world
    local any=w.fullbright or w.noFog or w.noShadows or w.hour
    if not any and not World.active then
        return
    end
    World.active=any
    Lighting.Brightness=w.fullbright and 3 or ORIGINAL.brightness
    Lighting.Ambient=w.fullbright and Color3.fromRGB(180,180,180) or ORIGINAL.ambient
    Lighting.OutdoorAmbient=w.fullbright and Color3.fromRGB(180,180,180) or ORIGINAL.outdoor
    Lighting.FogEnd=(w.fullbright or w.noFog) and 1000000 or ORIGINAL.fogEnd
    Lighting.FogStart=w.noFog and 999999 or ORIGINAL.fogStart
    if w.noShadows then
        Lighting.GlobalShadows=false
    else
        Lighting.GlobalShadows=ORIGINAL.shadows
    end
    if w.hour then
        Lighting.ClockTime=w.hourValue
    elseif w.fullbright then
        Lighting.ClockTime=14
    else
        Lighting.ClockTime=ORIGINAL.clockTime
    end
    for _,child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Atmosphere") then
            if w.noFog then
                if World.atmosphere[child]==nil then
                    World.atmosphere[child]=child.Density
                end
                child.Density=0
            elseif World.atmosphere[child]~=nil then
                child.Density=World.atmosphere[child]
                World.atmosphere[child]=nil
            end
        end
    end
end

function World.Restore()
    local w=CFG.world
    w.fullbright=false
    w.noFog=false
    w.noShadows=false
    w.hour=false
    World.active=true
    pcall(World.Apply)
    World.active=false
end

function World.IsCharacterPart(object)
    local model=object:FindFirstAncestorOfClass("Model")
    while model do
        if Players:GetPlayerFromCharacter(model) then
            return true
        end
        model=model:FindFirstAncestorOfClass("Model")
    end
    return false
end

function World.IsTargetPart(object)
    local folder=workspace:FindFirstChild("Targets")
    if folder and object:IsDescendantOf(folder) then
        return true
    end
    for _,model in ipairs(Engine.Targets()) do
        if object:IsDescendantOf(model) then
            return true
        end
    end
    return false
end

function World.Excluded(object)
    local mode=CFG.world.fadeExclude
    if mode=="None" then
        return false
    end
    if mode=="Characters" then
        return World.IsCharacterPart(object)
    end
    if mode=="Targets" then
        return World.IsTargetPart(object)
    end
    return World.IsCharacterPart(object) or World.IsTargetPart(object)
end

function World.FadePart(object)
    if object:IsA("BasePart") and not World.Excluded(object) then
        if World.fadeStore[object]==nil then
            World.fadeStore[object]=object.LocalTransparencyModifier
        end
        object.LocalTransparencyModifier=CFG.world.fadeAmount
    end
end

function World.SetFade(on)
    if World.fadeConn then
        pcall(function()
            World.fadeConn:Disconnect()
        end)
        World.fadeConn=nil
    end
    for object,value in pairs(World.fadeStore) do
        if object.Parent then
            pcall(function()
                object.LocalTransparencyModifier=value
            end)
        end
    end
    table.clear(World.fadeStore)
    if on then
        for _,object in ipairs(workspace:GetDescendants()) do
            pcall(World.FadePart,object)
        end
        World.fadeConn=workspace.DescendantAdded:Connect(function(object)
            pcall(World.FadePart,object)
        end)
    end
end

function World.CameraStep()
    local camera=workspace.CurrentCamera
    if not camera then
        return
    end
    if CFG.world.camFov then
        STATE.camFovActive=true
        camera.FieldOfView=CFG.world.camFovValue
    elseif STATE.camFovActive then
        STATE.camFovActive=false
        camera.FieldOfView=ORIGINAL.fov
    end
end

function World.ApplyZoom()
    pcall(function()
        LP.CameraMaxZoomDistance=CFG.world.zoom and 10000 or ORIGINAL.zoom
    end)
end

local Move={origSpeed=nil,origJump=nil,origUseJump=nil,noclipStore={}}

function Move.Step()
    local hum=Hum()
    if not hum then
        return
    end
    local m=CFG.move
    if m.speed then
        if Move.origSpeed==nil then
            Move.origSpeed=hum.WalkSpeed
        end
        if hum.WalkSpeed~=m.speedValue then
            hum.WalkSpeed=m.speedValue
        end
    elseif Move.origSpeed~=nil then
        hum.WalkSpeed=Move.origSpeed
        Move.origSpeed=nil
    end
    if m.jump then
        if Move.origJump==nil then
            Move.origJump=hum.JumpPower
            Move.origUseJump=hum.UseJumpPower
        end
        hum.UseJumpPower=true
        if hum.JumpPower~=m.jumpValue then
            hum.JumpPower=m.jumpValue
        end
    elseif Move.origJump~=nil then
        hum.UseJumpPower=Move.origUseJump
        hum.JumpPower=Move.origJump
        Move.origJump=nil
    end
end

function Move.ApplyGravity()
    workspace.Gravity=CFG.move.gravity and CFG.move.gravityValue or ORIGINAL.gravity
end

function Move.Noclip()
    local character=LP.Character
    if CFG.move.noclip and character then
        for _,part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                Move.noclipStore[part]=true
                part.CanCollide=false
            end
        end
    elseif next(Move.noclipStore) then
        for part in pairs(Move.noclipStore) do
            if part.Parent then
                part.CanCollide=true
            end
        end
        table.clear(Move.noclipStore)
    end
end

function Move.NearestTarget()
    local root=Root()
    if not root then
        Notify("TELEPORT","Personaje no disponible",C.dim)
        return
    end
    local bestPart=nil
    local bestDistance=math.huge
    for _,model in ipairs(Engine.Targets()) do
        local _,part=Engine.Parts(model)
        if part then
            local distance=(part.Position-root.Position).Magnitude
            if distance<bestDistance then
                bestDistance=distance
                bestPart=part
            end
        end
    end
    if bestPart then
        root.CFrame=CFrame.new(bestPart.Position+Vector3.new(0,3,6),bestPart.Position)
        Notify("TELEPORT","Objetivo a "..math.floor(bestDistance).." studs",C.red)
    else
        Notify("TELEPORT","No hay objetivos autorizados",C.dim)
    end
end

function Move.ClickTeleport()
    local camera=workspace.CurrentCamera
    local root=Root()
    if not camera or not root then
        return
    end
    local mouse=UIS:GetMouseLocation()
    local ray=camera:ViewportPointToRay(mouse.X,mouse.Y)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character}
    local result=workspace:Raycast(ray.Origin,ray.Direction*2000,params)
    if result then
        root.CFrame=CFrame.new(result.Position+Vector3.new(0,3,0))*(root.CFrame-root.CFrame.Position)
    end
end

function Move.ResetCharacter()
    local hum=Hum()
    if hum then
        hum.Health=0
    end
end

function Move.Restore()
    local hum=Hum()
    if hum then
        if Move.origSpeed~=nil then
            hum.WalkSpeed=Move.origSpeed
        end
        if Move.origJump~=nil then
            hum.UseJumpPower=Move.origUseJump
            hum.JumpPower=Move.origJump
        end
    end
    Move.origSpeed=nil
    Move.origJump=nil
    for part in pairs(Move.noclipStore) do
        if part.Parent then
            part.CanCollide=true
        end
    end
    table.clear(Move.noclipStore)
    workspace.Gravity=ORIGINAL.gravity
end

local Fly={active=false,velocity=Vector3.zero}

function Fly.Stop()
    local hum=Fly.hum
    local root=Fly.root
    for _,key in ipairs({"velocityObject","alignObject","attachment"}) do
        local object=Fly[key]
        if object then
            pcall(function()
                object:Destroy()
            end)
        end
        Fly[key]=nil
    end
    if Fly.active and hum and hum.Parent then
        pcall(function()
            hum.PlatformStand=false
            hum.AutoRotate=true
            if hum.Health>0 then
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end)
    end
    if Fly.active and root and root.Parent then
        pcall(function()
            root.AssemblyLinearVelocity=Vector3.zero
        end)
    end
    Fly.active=false
    Fly.hum=nil
    Fly.root=nil
    Fly.velocity=Vector3.zero
end

function Fly.Start()
    local root=Root()
    local hum=Hum()
    if not root or not hum or hum.Health<=0 then
        return false
    end
    Fly.Stop()
    Fly.root=root
    Fly.hum=hum
    Fly.attachment=N("Attachment",{Name="STIRLAX_FlyAttachment",Parent=root})
    Fly.velocityObject=N("LinearVelocity",{
        Name="STIRLAX_FlyVelocity",
        Attachment0=Fly.attachment,
        RelativeTo=Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode=Enum.VelocityConstraintMode.Vector,
        MaxForce=1e9,
        VectorVelocity=Vector3.zero,
        Parent=root
    })
    Fly.alignObject=N("AlignOrientation",{
        Name="STIRLAX_FlyAlign",
        Attachment0=Fly.attachment,
        Mode=Enum.OrientationAlignmentMode.OneAttachment,
        RigidityEnabled=false,
        Responsiveness=40,
        MaxTorque=1e9,
        CFrame=root.CFrame,
        Parent=root
    })
    hum.PlatformStand=true
    hum.AutoRotate=false
    Fly.active=true
    return true
end

local function KeyDown(key)
    if UIS:GetFocusedTextBox() then
        return false
    end
    return UIS:IsKeyDown(key)
end

function Fly.Step(dt)
    if not CFG.move.fly then
        if Fly.active then
            Fly.Stop()
        end
        return
    end
    local root=Root()
    local hum=Hum()
    if not root or not hum or hum.Health<=0 then
        if Fly.active then
            Fly.Stop()
        end
        return
    end
    if not Fly.active or Fly.root~=root or not Fly.velocityObject or not Fly.velocityObject.Parent then
        if not Fly.Start() then
            return
        end
    end
    local camera=workspace.CurrentCamera
    if not camera then
        return
    end
    local look=camera.CFrame.LookVector
    local right=camera.CFrame.RightVector
    local flatLook=Vector3.new(look.X,0,look.Z)
    local flatRight=Vector3.new(right.X,0,right.Z)
    flatLook=flatLook.Magnitude>.001 and flatLook.Unit or Vector3.new(0,0,-1)
    flatRight=flatRight.Magnitude>.001 and flatRight.Unit or Vector3.new(1,0,0)
    local forward,side=0,0
    local moveDirection=hum.MoveDirection
    if moveDirection.Magnitude>.05 then
        forward=moveDirection:Dot(flatLook)
        side=moveDirection:Dot(flatRight)
    else
        if KeyDown(Enum.KeyCode.W) or KeyDown(Enum.KeyCode.Up) then forward=forward+1 end
        if KeyDown(Enum.KeyCode.S) or KeyDown(Enum.KeyCode.Down) then forward=forward-1 end
        if KeyDown(Enum.KeyCode.D) or KeyDown(Enum.KeyCode.Right) then side=side+1 end
        if KeyDown(Enum.KeyCode.A) or KeyDown(Enum.KeyCode.Left) then side=side-1 end
    end
    local vertical=0
    if KeyDown(Enum.KeyCode.Space) or STATE.flyUp then vertical=vertical+1 end
    if KeyDown(Enum.KeyCode.LeftShift) or KeyDown(Enum.KeyCode.LeftControl) or STATE.flyDown then vertical=vertical-1 end
    local direction=look*forward+flatRight*side
    local goal=Vector3.zero
    if direction.Magnitude>.001 then
        goal=direction.Unit*math.min(direction.Magnitude,1)*CFG.move.flySpeed
    end
    goal=goal+Vector3.new(0,vertical*CFG.move.flyVertical,0)
    local alpha=math.clamp(1-(1-CFG.move.flyAccel)^(math.max(dt,1/240)*60),.02,1)
    Fly.velocity=Fly.velocity:Lerp(goal,alpha)
    Fly.velocityObject.VectorVelocity=Fly.velocity
    if Fly.alignObject then
        Fly.alignObject.CFrame=CFrame.lookAt(root.Position,root.Position+flatLook)
    end
end

local FlyPad=N("Frame",{
    Name="FlyPad",
    Size=UDim2.fromOffset(84,150),
    Position=UDim2.new(1,-100,.5,-110),
    BackgroundTransparency=1,
    Visible=false,
    ZIndex=35,
    Parent=Gui
})
local function PadButton(text,y,flag)
    local button=B(FlyPad,text,UDim2.fromOffset(84,68),UDim2.fromOffset(0,y))
    button.BackgroundColor3=C.glass
    button.BackgroundTransparency=.15
    button.TextColor3=C.white
    button.TextSize=13
    button.ZIndex=36
    S(button,C.red,1.5)
    Track(button.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            STATE[flag]=true
            button.BackgroundColor3=C.redDeep
        end
    end))
    Track(button.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            STATE[flag]=false
            button.BackgroundColor3=C.glass
        end
    end))
    return button
end
PadButton("SUBIR",0,"flyUp")
PadButton("BAJAR",80,"flyDown")

function Fly.UpdatePad()
    FlyPad.Visible=CFG.move.fly and CFG.move.flyPad
    if not FlyPad.Visible then
        STATE.flyUp=false
        STATE.flyDown=false
    end
end

local Extra={}

function Extra.Spin(dt)
    if not CFG.extra.spin or CFG.move.fly then
        return
    end
    local root=Root()
    if root then
        root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(CFG.extra.spinSpeed)*dt,0)
    end
end

function Extra.Tool()
    if not CFG.extra.tool then
        return
    end
    local character=LP.Character
    local tool=character and character:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end
    local allowed=CFG.extra.toolFilter=="Any"
        or tool:GetAttribute("STIRLAXToolAssist")==true
        or tool:GetAttribute("FXRapidFire")==true
    if not allowed then
        return
    end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        return
    end
    local now=os.clock()
    if now-STATE.toolLast>=CFG.extra.toolCooldown then
        STATE.toolLast=now
        pcall(function()
            tool:Activate()
        end)
    end
end

function Extra.Overlay()
    local parts={}
    if CFG.ui.fpsMonitor then
        table.insert(parts,"FPS "..tostring(STATE.fps))
    end
    if CFG.ui.targetCounter then
        table.insert(parts,"OBJETIVOS "..tostring(STATE.targetCount))
    end
    if #parts>0 then
        Overlay.Text=table.concat(parts,"   |   ")
        Overlay.Visible=true
    else
        Overlay.Visible=false
    end
end

local UIX={}

if STATE.mobile and CFG.aim.activation=="Hold" then
    CFG.aim.activation="Touch"
end
CFG.move.flyPad=STATE.mobile

do
    STATE.buildPrefix="AIM"
    local content=Content(Pages.AIM)
    local activation=Section(content,"ACTIVACION")
    MakeToggle(activation,"AIM ASSIST",CFG.aim.enabled,function(v)
        CFG.aim.enabled=v
        if not v then
            STATE.aimModel=nil
            STATE.skipModel=nil
        end
    end)
    MakeSelector(activation,"MODO DE ACTIVACION",{
        {"MANTENER CLIC DER","Hold"},
        {"CLIC IZQ O DER","HoldAny"},
        {"SIEMPRE ACTIVO","Always"},
        {"TOQUE (MOVIL)","Touch"}
    },CFG.aim.activation,function(v)
        CFG.aim.activation=v
    end)
    MakeToggle(activation,"BLOQUEAR OBJETIVO",CFG.aim.lock,function(v)
        CFG.aim.lock=v
        if not v then
            STATE.aimModel=nil
        end
    end)
    UIX.switchTarget=MakeButton(activation,"CAMBIAR OBJETIVO","CAMBIAR",Engine.SwitchTarget)
    UIX.switchTarget.DefaultKey=Enum.KeyCode.Q
    UIX.switchTarget.SetKey(Enum.KeyCode.Q)

    local point=Section(content,"PUNTO DE APUNTE")
    MakeSelector(point,"PARTE DEL CUERPO",{
        {"CABEZA","Head"},
        {"CUELLO","Neck"},
        {"PECHO","Chest"},
        {"CADERA","Hip"}
    },CFG.aim.bone,function(v)
        CFG.aim.bone=v
    end)
    MakeSelector(point,"PRIORIDAD DE OBJETIVO",{
        {"CERCA DE MIRA","Center"},
        {"MAS CERCANO","Distance"}
    },CFG.aim.priority,function(v)
        CFG.aim.priority=v
    end)

    local precision=Section(content,"PRECISION Y RESPUESTA")
    MakeSlider(precision,"RADIO DEL FOV",40,500,CFG.aim.fov,0," px",function(v)
        CFG.aim.fov=v
    end)
    MakeSlider(precision,"FUERZA (1.00 = INSTANTANEO)",.05,1,CFG.aim.strength,2,"",function(v)
        CFG.aim.strength=v
    end)
    MakeSlider(precision,"DISTANCIA MAXIMA",50,2000,CFG.aim.range,0," st",function(v)
        CFG.aim.range=v
    end)
    MakeSlider(precision,"ZONA MUERTA",0,30,CFG.aim.deadzone,0," px",function(v)
        CFG.aim.deadzone=v
    end)

    local visual=Section(content,"VISUAL Y FILTROS")
    MakeToggle(visual,"MOSTRAR CIRCULO FOV",CFG.aim.showFov,function(v)
        CFG.aim.showFov=v
    end)
    MakeToggle(visual,"MARCADOR DE OBJETIVO",CFG.aim.marker,function(v)
        CFG.aim.marker=v
    end)
    MakeToggle(visual,"COMPROBAR PAREDES",CFG.aim.wall,function(v)
        CFG.aim.wall=v
    end)
end

do
    STATE.buildPrefix="ESP"
    local content=Content(Pages.ESP)
    local elements=Section(content,"ELEMENTOS  (ACTIVA CADA UNO POR SEPARADO)")
    MakeToggle(elements,"LINEAS (TRACERS)",CFG.esp.tracers,function(v)
        CFG.esp.tracers=v
    end)
    MakeToggle(elements,"CAJAS",CFG.esp.boxes,function(v)
        CFG.esp.boxes=v
    end)
    MakeToggle(elements,"BARRA DE VIDA",CFG.esp.health,function(v)
        CFG.esp.health=v
    end)
    MakeToggle(elements,"VIDA EN NUMERO",CFG.esp.healthText,function(v)
        CFG.esp.healthText=v
    end)
    MakeToggle(elements,"NOMBRES",CFG.esp.names,function(v)
        CFG.esp.names=v
    end)
    MakeToggle(elements,"DISTANCIA",CFG.esp.distance,function(v)
        CFG.esp.distance=v
    end)
    MakeToggle(elements,"FLECHAS FUERA DE PANTALLA",CFG.esp.arrows,function(v)
        CFG.esp.arrows=v
    end)

    local glow=Section(content,"RESALTADO 3D")
    MakeToggle(glow,"X-RAY (RELLENO)",CFG.esp.xray,function(v)
        CFG.esp.xray=v
        Highlights.Sync()
    end)
    MakeToggle(glow,"CONTORNO",CFG.esp.outline,function(v)
        CFG.esp.outline=v
        Highlights.Sync()
    end)
    MakeSlider(glow,"OPACIDAD X-RAY",0,.95,CFG.esp.xrayFill,2,"",function(v)
        CFG.esp.xrayFill=v
        Highlights.Sync()
    end)

    local style=Section(content,"ESTILO")
    MakeSelector(style,"ESTILO DE CAJA",{
        {"ESQUINAS","Corners"},
        {"COMPLETA","Full"}
    },CFG.esp.boxStyle,function(v)
        CFG.esp.boxStyle=v
    end)
    MakeSelector(style,"ORIGEN DE LINEAS",{
        {"ABAJO","Bottom"},
        {"CENTRO","Center"},
        {"ARRIBA","Top"}
    },CFG.esp.tracerOrigin,function(v)
        CFG.esp.tracerOrigin=v
    end)
    MakeSlider(style,"GROSOR",1,4,CFG.esp.thickness,1," px",function(v)
        CFG.esp.thickness=v
    end)
    MakeSlider(style,"ESCALA DE CAJA",.7,1.5,CFG.esp.boxScale,2,"x",function(v)
        CFG.esp.boxScale=v
    end)
    MakeToggle(style,"COLOR SEGUN VIDA",CFG.esp.hpColor,function(v)
        CFG.esp.hpColor=v
    end)

    local filters=Section(content,"FILTROS Y RENDIMIENTO")
    MakeSlider(filters,"DISTANCIA MAXIMA",100,5000,CFG.esp.range,0," st",function(v)
        CFG.esp.range=v
    end)
    MakeToggle(filters,"SOLO VISIBLES (PAREDES)",CFG.esp.wall,function(v)
        CFG.esp.wall=v
    end)
    UIX.espRate=MakeSlider(filters,"ACTUALIZACIONES POR SEG",10,120,CFG.esp.rate,0," /s",function(v)
        CFG.esp.rate=v
    end)
    UIX.espMax=MakeSlider(filters,"MAXIMO DE OBJETIVOS",5,100,CFG.esp.maxTargets,0,"",function(v)
        CFG.esp.maxTargets=v
    end)
end

do
    STATE.buildPrefix="MOVE"
    local content=Content(Pages.MOVE)
    local walk=Section(content,"VELOCIDAD Y SALTO")
    MakeToggle(walk,"VELOCIDAD",CFG.move.speed,function(v)
        CFG.move.speed=v
    end)
    MakeSlider(walk,"VALOR DE VELOCIDAD",16,250,CFG.move.speedValue,0,"",function(v)
        CFG.move.speedValue=v
    end)
    MakeToggle(walk,"SALTO ALTO",CFG.move.jump,function(v)
        CFG.move.jump=v
    end)
    MakeSlider(walk,"POTENCIA DE SALTO",50,400,CFG.move.jumpValue,0,"",function(v)
        CFG.move.jumpValue=v
    end)
    MakeToggle(walk,"SALTO INFINITO",CFG.move.infJump,function(v)
        CFG.move.infJump=v
    end)

    local fly=Section(content,"VUELO")
    MakeToggle(fly,"FLY",CFG.move.fly,function(v)
        CFG.move.fly=v
        if not v then
            Fly.Stop()
        end
        Fly.UpdatePad()
    end)
    MakeSlider(fly,"VELOCIDAD DE VUELO",10,400,CFG.move.flySpeed,0,"",function(v)
        CFG.move.flySpeed=v
    end)
    MakeSlider(fly,"VELOCIDAD VERTICAL",10,300,CFG.move.flyVertical,0,"",function(v)
        CFG.move.flyVertical=v
    end)
    MakeSlider(fly,"SUAVIDAD (1.00 = DIRECTO)",.05,1,CFG.move.flyAccel,2,"",function(v)
        CFG.move.flyAccel=v
    end)
    MakeToggle(fly,"BOTONES SUBIR / BAJAR",CFG.move.flyPad,function(v)
        CFG.move.flyPad=v
        Fly.UpdatePad()
    end)

    local physics=Section(content,"FISICA")
    MakeToggle(physics,"NOCLIP",CFG.move.noclip,function(v)
        CFG.move.noclip=v
        if not v then
            Move.Noclip()
        end
    end)
    MakeToggle(physics,"GRAVEDAD PERSONALIZADA",CFG.move.gravity,function(v)
        CFG.move.gravity=v
        Move.ApplyGravity()
    end)
    MakeSlider(physics,"GRAVEDAD",0,400,CFG.move.gravityValue,0,"",function(v)
        CFG.move.gravityValue=v
        if CFG.move.gravity then
            Move.ApplyGravity()
        end
    end)

    local teleport=Section(content,"TELEPORT")
    MakeToggle(teleport,"CTRL + CLIC TELEPORT",CFG.move.clickTp,function(v)
        CFG.move.clickTp=v
    end)
    MakeButton(teleport,"IR AL OBJETIVO MAS CERCANO","IR",Move.NearestTarget)
    MakeButton(teleport,"REINICIAR PERSONAJE","REINICIAR",Move.ResetCharacter)
end

do
    STATE.buildPrefix="WORLD"
    local content=Content(Pages.WORLD)
    local light=Section(content,"ILUMINACION")
    MakeToggle(light,"FULLBRIGHT",CFG.world.fullbright,function(v)
        CFG.world.fullbright=v
        World.Apply()
    end)
    MakeToggle(light,"SIN NIEBLA",CFG.world.noFog,function(v)
        CFG.world.noFog=v
        World.Apply()
    end)
    MakeToggle(light,"SIN SOMBRAS",CFG.world.noShadows,function(v)
        CFG.world.noShadows=v
        World.Apply()
    end)
    MakeToggle(light,"HORA FIJA",CFG.world.hour,function(v)
        CFG.world.hour=v
        World.Apply()
    end)
    MakeSlider(light,"HORA DEL DIA",0,24,CFG.world.hourValue,1," h",function(v)
        CFG.world.hourValue=v
        if CFG.world.hour then
            World.Apply()
        end
    end)

    local camera=Section(content,"CAMARA")
    MakeToggle(camera,"FOV DE CAMARA",CFG.world.camFov,function(v)
        CFG.world.camFov=v
        World.CameraStep()
    end)
    MakeSlider(camera,"VALOR DEL FOV",40,120,CFG.world.camFovValue,0,"",function(v)
        CFG.world.camFovValue=v
    end)
    MakeToggle(camera,"ZOOM MAXIMO",CFG.world.zoom,function(v)
        CFG.world.zoom=v
        World.ApplyZoom()
    end)

    local fade=Section(content,"TRANSPARENCIA DEL MAPA")
    MakeToggle(fade,"WORLD FADE",CFG.world.fade,function(v)
        CFG.world.fade=v
        World.SetFade(v)
    end)
    MakeSlider(fade,"INTENSIDAD",.1,.95,CFG.world.fadeAmount,2,"",function(v)
        CFG.world.fadeAmount=v
        if CFG.world.fade then
            for object in pairs(World.fadeStore) do
                if object.Parent then
                    object.LocalTransparencyModifier=v
                end
            end
        end
    end)
    MakeSelector(fade,"EXCLUIR DEL FADE",{
        {"PERSONAJES+OBJ.","Both"},
        {"PERSONAJES","Characters"},
        {"OBJETIVOS","Targets"},
        {"NINGUNO","None"}
    },CFG.world.fadeExclude,function(v)
        CFG.world.fadeExclude=v
        if CFG.world.fade then
            World.SetFade(true)
        end
    end)
end

local skinCards={}

local function SelectSkin(key)
    skin=key
    for cardKey,data in pairs(skinCards) do
        local selected=cardKey==key
        data.ring.Visible=selected
        data.label.TextColor3=selected and C.gold or C.white
    end
    ApplySkin()
end

do
    STATE.buildPrefix="SKINS"
    local content=Content(Pages.SKINS)
    local apply=Section(content,"APLICACION")
    MakeToggle(apply,"APLICAR SKIN A MI PERSONAJE",ownSkinOn,function(v)
        ownSkinOn=v
        ApplyOwn()
    end)
    MakeButton(apply,"QUITAR SKIN (NORMAL)","NORMAL",function()
        SelectSkin("normal")
        Notify("SKINS","Skin normal restaurada",C.red)
    end)
    local catalog=Section(content,"CATALOGO DE SKINS")
    for _,entry in ipairs(SKIN_LIST) do
        local key,label=entry[1],entry[2]
        local card=Card(catalog)
        local swatch=N("Frame",{
            Size=UDim2.fromOffset(28,28),
            Position=UDim2.new(0,14,.5,-14),
            BackgroundColor3=AMONG[key] or (key=="neon" and NEON_COLOR) or (key=="freefire" and FF_ORANGE) or C.gray,
            BorderSizePixel=0,
            ZIndex=6,
            Parent=card
        })
        R(swatch,14)
        S(swatch,C.white,1,false)
        local text=T(card,label,UDim2.new(1,-64,1,0),UDim2.fromOffset(54,0),12,C.white,Enum.Font.GothamBold)
        text.ZIndex=6
        local ring=N("Frame",{
            Size=UDim2.new(1,-4,1,-4),
            Position=UDim2.fromOffset(2,2),
            BackgroundTransparency=1,
            Visible=false,
            ZIndex=6,
            Parent=card
        })
        R(ring,11)
        N("UIStroke",{Color=C.gold,Thickness=2,Parent=ring})
        local hit=N("TextButton",{
            Text="",
            AutoButtonColor=false,
            BackgroundTransparency=1,
            Size=UDim2.fromScale(1,1),
            ZIndex=7,
            Parent=card
        })
        Track(hit.Activated:Connect(function()
            SelectSkin(key)
            Notify("SKINS",label,C.red)
        end))
        skinCards[key]={ring=ring,label=text}
    end
end

do
    STATE.buildPrefix="EXTRAS"
    local content=Content(Pages.EXTRAS)
    local character=Section(content,"PERSONAJE")
    MakeToggle(character,"GIRAR PERSONAJE",CFG.extra.spin,function(v)
        CFG.extra.spin=v
    end)
    MakeSlider(character,"VELOCIDAD DE GIRO",30,1440,CFG.extra.spinSpeed,0," g/s",function(v)
        CFG.extra.spinSpeed=v
    end)
    MakeToggle(character,"ANTI AFK",CFG.extra.antiAfk,function(v)
        CFG.extra.antiAfk=v
        if v and not VirtualUser then
            Notify("ANTI AFK","VirtualUser no disponible",C.dim)
        end
    end)

    local tools=Section(content,"TOOL ASSIST")
    MakeToggle(tools,"TOOL ASSIST (MANTENER CLIC)",CFG.extra.tool,function(v)
        CFG.extra.tool=v
    end)
    MakeSelector(tools,"HERRAMIENTAS",{
        {"AUTORIZADAS","Authorized"},
        {"CUALQUIERA","Any"}
    },CFG.extra.toolFilter,function(v)
        CFG.extra.toolFilter=v
    end)
    MakeSlider(tools,"CADENCIA",.03,.5,CFG.extra.toolCooldown,2," s",function(v)
        CFG.extra.toolCooldown=v
    end)

    local monitors=Section(content,"MONITORES EN PANTALLA")
    MakeToggle(monitors,"MONITOR DE FPS",CFG.ui.fpsMonitor,function(v)
        CFG.ui.fpsMonitor=v
        Extra.Overlay()
    end)
    MakeToggle(monitors,"CONTADOR DE OBJETIVOS",CFG.ui.targetCounter,function(v)
        CFG.ui.targetCounter=v
        Extra.Overlay()
    end)
end

local Presets={}
local PRESET_FILE="STIRLAX_MODZ_PRESETS.json"

function Presets.CanUseFiles()
    return type(writefile)=="function" and type(readfile)=="function"
end

function Presets.LoadFile()
    if not Presets.CanUseFiles() then
        return
    end
    local ok,data=pcall(function()
        if type(isfile)=="function" and not isfile(PRESET_FILE) then
            return nil
        end
        return HttpService:JSONDecode(readfile(PRESET_FILE))
    end)
    if ok and type(data)=="table" then
        STATE.presets=data
    end
end

function Presets.SaveFile()
    if not Presets.CanUseFiles() then
        return false
    end
    return pcall(function()
        writefile(PRESET_FILE,HttpService:JSONEncode(STATE.presets))
    end)
end

function Presets.Capture()
    local data={values={},keys={}}
    for _,obj in ipairs(STATE.controls) do
        if not obj.noPreset then
            local value=obj.Get()
            if value~=nil then
                data.values[obj.id]=value
            end
        end
    end
    for _,obj in ipairs(STATE.keyed) do
        if obj.keyId then
            data.keys[obj.keyId]=obj.Key and obj.Key.Name or "NONE"
        end
    end
    return data
end

function Presets.Apply(data)
    if type(data)~="table" then
        return false
    end
    STATE.muteNotify=true
    local values=type(data.values)=="table" and data.values or {}
    local keys=type(data.keys)=="table" and data.keys or {}
    for pass=1,2 do
        for _,obj in ipairs(STATE.controls) do
            local value=values[obj.id]
            local first=obj.applyFirst==true
            if value~=nil and not obj.noPreset and ((pass==1)==first) then
                SafeCall("preset "..obj.id,obj.Set,value)
            end
        end
    end
    for _,obj in ipairs(STATE.keyed) do
        local name=obj.keyId and keys[obj.keyId]
        if name=="NONE" then
            obj.SetKey(nil)
        elseif type(name)=="string" and Enum.KeyCode[name] then
            obj.SetKey(Enum.KeyCode[name])
        end
    end
    STATE.muteNotify=false
    return true
end

function Presets.Reset()
    STATE.muteNotify=true
    for pass=1,2 do
        for _,obj in ipairs(STATE.controls) do
            local first=obj.applyFirst==true
            if not obj.noPreset and ((pass==1)==first) then
                SafeCall("reset "..obj.id,obj.Set,obj.Default)
            end
        end
    end
    for _,obj in ipairs(STATE.keyed) do
        obj.SetKey(obj.DefaultKey)
    end
    STATE.muteNotify=false
end

local function SetPerformance(mode)
    CFG.ui.performance=mode
    local rate=mode=="Bajo" and 20 or mode=="Medio" and 40 or 60
    local maxTargets=mode=="Bajo" and 15 or mode=="Medio" and 30 or 40
    CFG.esp.rate=rate
    CFG.esp.maxTargets=maxTargets
    if UIX.espRate then
        UIX.espRate.Set(rate,true)
    end
    if UIX.espMax then
        UIX.espMax.Set(maxTargets,true)
    end
    BuildParticles()
end

do
    STATE.buildPrefix="CONFIG"
    local content=Content(Pages.CONFIG)
    local menu=Section(content,"MENU Y LAUNCHER")
    UIX.menuKey=MakeKeybind(menu,"TECLA ABRIR / CERRAR MENU",CFG.ui.menuKey,function(key)
        CFG.ui.menuKey=key
        LayoutLauncher()
    end)
    MakeToggle(menu,"LAUNCHER COMPACTO",CFG.ui.compactLauncher,function(v)
        CFG.ui.compactLauncher=v
        LayoutLauncher()
    end)
    MakeToggle(menu,"BLOQUEAR POSICION",CFG.ui.lockMenu,function(v)
        CFG.ui.lockMenu=v
    end)
    MakeButton(menu,"CENTRAR MENU Y LAUNCHER","CENTRAR",function()
        Main.Position=UDim2.fromScale(.5,.5)
        Launcher.Position=UDim2.new(1,-(Launcher.Size.X.Offset+16),1,-(Launcher.Size.Y.Offset+20))
        ApplyLayout()
    end)

    local look=Section(content,"APARIENCIA")
    MakeSlider(look,"BRILLO ROJO",.1,1,CFG.ui.redGlow,2,"",function(v)
        CFG.ui.redGlow=v
        ApplyGlow()
    end)
    MakeToggle(look,"PARTICULAS",CFG.ui.particles,function(v)
        CFG.ui.particles=v
    end)
    MakeSlider(look,"DENSIDAD DE PARTICULAS",10,100,CFG.ui.particleDensity,0," %",function(v)
        CFG.ui.particleDensity=v
        BuildParticles()
    end)
    MakeToggle(look,"REDUCIR MOVIMIENTO",CFG.ui.reduceMotion,function(v)
        CFG.ui.reduceMotion=v
    end)

    local performance=Section(content,"RENDIMIENTO")
    UIX.performance=MakeSelector(performance,"MODO DE RENDIMIENTO",{
        {"ALTO","Alto"},
        {"MEDIO","Medio"},
        {"BAJO","Bajo"}
    },CFG.ui.performance,SetPerformance)
    UIX.performance.applyFirst=true

    local alerts=Section(content,"NOTIFICACIONES Y FILTROS")
    MakeToggle(alerts,"NOTIFICACIONES",CFG.ui.notify,function(v)
        CFG.ui.notify=v
    end)
    MakeSlider(alerts,"DURACION DE AVISOS",1,6,CFG.ui.notifyTime,1," s",function(v)
        CFG.ui.notifyTime=v
    end)
    MakeToggle(alerts,"IGNORAR MI EQUIPO",CFG.ui.teamCheck,function(v)
        CFG.ui.teamCheck=v
        STATE.targetCacheTime=0
        Highlights.Sync()
    end)

    local presets=Section(content,"PRESETS")
    UIX.slot=MakeSelector(presets,"RANURA",{
        {"PRESET 1","1"},
        {"PRESET 2","2"},
        {"PRESET 3","3"}
    },"1",function() end)
    UIX.slot.noPreset=true
    MakeButton(presets,"GUARDAR PRESET","GUARDAR",function()
        local slot=UIX.slot.Value()
        STATE.presets[slot]=Presets.Capture()
        local stored=Presets.SaveFile()
        Notify("PRESETS","Preset "..slot.." guardado"..(stored and " en archivo" or " en sesion"),C.red)
    end)
    MakeButton(presets,"CARGAR PRESET","CARGAR",function()
        local slot=UIX.slot.Value()
        local data=STATE.presets[slot]
        if not data then
            Notify("PRESETS","Preset "..slot.." vacio",C.dim)
            return
        end
        Presets.Apply(data)
        Notify("PRESETS","Preset "..slot.." cargado",C.red)
    end)
    MakeButton(presets,"RESTABLECER TODO","RESET",function()
        Presets.Reset()
        Notify("STIRLAX MODZ","Todo restablecido",C.red)
    end)
end

STATE.buildPrefix=nil

local function Page(name)
    if not Pages[name] then
        return
    end
    STATE.page=name
    for pageName,page in pairs(Pages) do
        local active=pageName==name
        page.Visible=active
        if active then
            page.Position=UDim2.fromOffset(0,10)
            Tween(page,.22,{Position=UDim2.fromOffset(0,0)})
            local content=page:FindFirstChild("Content")
            if content and content:IsA("ScrollingFrame") then
                content.CanvasPosition=Vector2.zero
            end
        end
    end
    for tabName,tab in pairs(Tabs) do
        local active=tabName==name
        Tween(tab,.15,{BackgroundColor3=active and C.red or C.card})
        tab.TextColor3=active and C.white or C.gray
    end
    local tab=Tabs[name]
    if tab then
        local index=tab.LayoutOrder
        local tabWidth=tab.Size.X.Offset+5
        local visible=TabBar.AbsoluteSize.X/math.max(MainScale.Scale,.01)
        local target=math.max(0,(index-1)*tabWidth-(visible-tabWidth)/2)
        TabBar.CanvasPosition=Vector2.new(target,0)
    end
end

for name,tab in pairs(Tabs) do
    Track(tab.Activated:Connect(function()
        Page(name)
    end))
end

local function CancelListening()
    local target=STATE.listening
    STATE.listening=nil
    if target and target.SetKey then
        target.SetKey(target.Key)
    end
end

local function SetMenuOpen(open)
    if STATE.menuBusy or not Gui.Parent then
        return
    end
    STATE.menuOpen=open and true or false
    if STATE.menuOpen then
        ApplyLayout()
        Main.Visible=true
        Launcher.Visible=false
        if CFG.ui.reduceMotion then
            MainScale.Scale=LAYOUT.scale
        else
            MainScale.Scale=LAYOUT.scale*.92
            Main.BackgroundTransparency=.4
            Tween(MainScale,.24,{Scale=LAYOUT.scale},Enum.EasingStyle.Back)
            Tween(Main,.24,{BackgroundTransparency=.08})
        end
    else
        CancelListening()
        STATE.menuBusy=true
        Tween(MainScale,.16,{Scale=LAYOUT.scale*.92},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        Tween(Main,.16,{BackgroundTransparency=.5},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.delay(CFG.ui.reduceMotion and 0 or .17,function()
            STATE.menuBusy=false
            if not STATE.menuOpen and Main.Parent then
                Main.Visible=false
                MainScale.Scale=LAYOUT.scale
                Main.BackgroundTransparency=.08
            end
            if Launcher.Parent then
                Launcher.Visible=true
                LayoutLauncher()
            end
        end)
    end
end

local function SetMinimized(value)
    STATE.minimized=value and true or false
    MinButton.Text=STATE.minimized and "+" or "—"
    ApplyLayout()
end

MakeDraggable(DragHandle,Main,nil)
MakeDraggable(Launcher,Launcher,function()
    SetMenuOpen(not STATE.menuOpen)
end)

Track(MinButton.Activated:Connect(function()
    SetMinimized(not STATE.minimized)
end))

Track(CloseButton.Activated:Connect(function()
    SetMenuOpen(false)
end))

for _,button in ipairs({MinButton,CloseButton,KillButton}) do
    Track(button.MouseEnter:Connect(function()
        Tween(button,.12,{BackgroundColor3=C.hover})
    end))
    Track(button.MouseLeave:Connect(function()
        Tween(button,.12,{BackgroundColor3=C.card})
    end))
end

local Cleanup

Track(KillButton.Activated:Connect(function()
    local now=os.clock()
    if STATE.killArmed and now-STATE.killArmed<2.5 then
        Cleanup()
        if Gui.Parent then
            Gui:Destroy()
        end
        return
    end
    STATE.killArmed=now
    KillButton.Text="SEGURO?"
    Notify("KILL SCRIPT","Pulsa otra vez para cerrar todo",C.red)
    task.delay(2.5,function()
        if KillButton.Parent and STATE.killArmed==now then
            STATE.killArmed=nil
            KillButton.Text="KILL"
        end
    end)
end))

local function HandleListening(key)
    local target=STATE.listening
    STATE.listening=nil
    if key==Enum.KeyCode.Escape or key==Enum.KeyCode.Backspace then
        target.SetKey(nil)
        return
    end
    if key==nil or key.Name=="Unknown" then
        target.SetKey(target.Key)
        return
    end
    if target.IsMenuKey then
        for _,obj in ipairs(STATE.keyed) do
            if obj.Key==key then
                obj.SetKey(nil)
            end
        end
        target.SetKey(key)
        return
    end
    if CFG.ui.menuKey==key then
        target.SetKey(target.Key)
        Notify("TECLAS","Esa tecla abre el menu",C.dim)
        return
    end
    for _,obj in ipairs(STATE.keyed) do
        if obj~=target and obj.Key==key then
            obj.SetKey(nil)
        end
    end
    target.SetKey(key)
end

Track(UIS.InputBegan:Connect(function(input,gameProcessed)
    if input.UserInputType==Enum.UserInputType.Keyboard then
        local key=input.KeyCode
        if STATE.listening then
            SafeCall("keybind",HandleListening,key)
            return
        end
        if gameProcessed or UIS:GetFocusedTextBox() then
            return
        end
        if CFG.ui.menuKey and key==CFG.ui.menuKey then
            SetMenuOpen(not STATE.menuOpen)
            return
        end
        for _,obj in ipairs(STATE.keyed) do
            if obj.Key==key then
                SafeCall(obj.Label or "tecla",obj.Trigger)
            end
        end
        return
    end
    if input.UserInputType==Enum.UserInputType.MouseButton1 and not gameProcessed and CFG.move.clickTp then
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
            SafeCall("click teleport",Move.ClickTeleport)
        end
    end
end))

Track(UIS.TouchStarted:Connect(function(touch)
    STATE.touches[touch]=true
end))

Track(UIS.TouchEnded:Connect(function(touch)
    STATE.touches[touch]=nil
end))

Track(UIS.WindowFocusReleased:Connect(function()
    table.clear(STATE.touches)
    STATE.flyUp=false
    STATE.flyDown=false
end))

Track(UIS.JumpRequest:Connect(function()
    if not CFG.move.infJump then
        return
    end
    local hum=Hum()
    if hum and hum.Health>0 then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end))

Track(LP.Idled:Connect(function()
    if CFG.extra.antiAfk and VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

Track(View.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        drag=true
        last=input.Position
        STATE.viewInput=input
    end
end))

Track(View.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseWheel then
        distance=math.clamp(distance-input.Position.Z*.7,4.5,12)
        Cam()
    end
end))

Track(UIS.InputChanged:Connect(function(input)
    if not drag or not last then
        return
    end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then
        return
    end
    if input.UserInputType==Enum.UserInputType.Touch and STATE.viewInput and STATE.viewInput.UserInputType==Enum.UserInputType.Touch and input~=STATE.viewInput then
        return
    end
    local delta=input.Position-last
    last=input.Position
    yaw=yaw+delta.X*.012
    pitch=math.clamp(pitch+delta.Y*.006,-.75,.75)
    if Model and Model.Parent then
        Model:PivotTo(CFrame.new(0,BaseY,0)*CFrame.Angles(pitch,yaw,0))
        Cam()
    end
end))

Track(UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        if input.UserInputType==Enum.UserInputType.Touch and STATE.viewInput and input~=STATE.viewInput then
            return
        end
        drag=false
        last=nil
        STATE.viewInput=nil
    end
end))

local function WatchPlayer(player)
    Track(player.CharacterAdded:Connect(function()
        if player==Selected and player~=LP then
            task.wait(.5)
            if STATE.alive and Selected==player then
                SafeCall("perfil",Show,player)
            end
        end
    end))
end

for _,player in ipairs(Players:GetPlayers()) do
    WatchPlayer(player)
end

Track(Players.PlayerAdded:Connect(function(player)
    WatchPlayer(player)
    SafeCall("lista",Update)
end))

Track(Players.PlayerRemoving:Connect(function(player)
    if player==Selected then
        SafeCall("perfil",Show,LP)
    end
    task.defer(function()
        if STATE.alive then
            SafeCall("lista",Update)
        end
    end)
end))

Track(LP.CharacterAdded:Connect(function()
    table.clear(ownStore)
    table.clear(Move.noclipStore)
    Move.origSpeed=nil
    Move.origJump=nil
    Fly.Stop()
    task.wait(.5)
    if not STATE.alive then
        return
    end
    SafeCall("skin propia",ApplyOwn)
    if Selected==LP then
        SafeCall("perfil",Show,LP)
    end
end))

pcall(function()
    RunService:UnbindFromRenderStep("STIRLAX_MODZ_CAMERA")
end)
RunService:BindToRenderStep("STIRLAX_MODZ_CAMERA",Enum.RenderPriority.Camera.Value+1,function(dt)
    SafeCall("aim assist",Engine.AimStep,dt)
    SafeCall("camara",World.CameraStep)
end)

local overlayClock=0
Track(RunService.RenderStepped:Connect(function(dt)
    STATE.frames=STATE.frames+1
    STATE.fpsTime=STATE.fpsTime+dt
    if STATE.fpsTime>=.5 then
        STATE.fps=math.floor(STATE.frames/STATE.fpsTime+.5)
        STATE.frames=0
        STATE.fpsTime=0
    end
    SafeCall("esp",Esp.Step)
    SafeCall("particulas",UpdateParticles,dt)
    overlayClock=overlayClock+dt
    if overlayClock>=.25 then
        overlayClock=0
        SafeCall("monitor",Extra.Overlay)
    end
end))

Track(RunService.Heartbeat:Connect(function(dt)
    SafeCall("movimiento",Move.Step)
    SafeCall("fly",Fly.Step,dt)
    SafeCall("giro",Extra.Spin,dt)
    SafeCall("tool assist",Extra.Tool)
end))

Track(RunService.Stepped:Connect(function()
    SafeCall("noclip",Move.Noclip)
end))

local lastViewport=Viewport()
task.spawn(function()
    while STATE.alive and Gui.Parent do
        SafeCall("highlights",Highlights.Sync)
        SafeCall("mundo",World.Apply)
        SafeCall("fly pad",Fly.UpdatePad)
        local viewport=Viewport()
        if (viewport-lastViewport).Magnitude>2 then
            lastViewport=viewport
            SafeCall("layout",ApplyLayout)
            SafeCall("particulas",BuildParticles)
        end
        task.wait(.5)
    end
end)

local cleaned=false
Cleanup=function()
    if cleaned then
        return
    end
    cleaned=true
    STATE.alive=false
    STATE.menuOpen=false
    pcall(function()
        RunService:UnbindFromRenderStep("STIRLAX_MODZ_CAMERA")
    end)
    for _,connection in ipairs(STATE.conns) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(STATE.conns)
    pcall(Esp.Clear)
    pcall(Highlights.Clear)
    pcall(World.Restore)
    pcall(World.SetFade,false)
    CFG.world.camFov=false
    pcall(World.CameraStep)
    CFG.world.zoom=false
    pcall(World.ApplyZoom)
    CFG.move.fly=false
    pcall(Fly.Stop)
    pcall(Move.Restore)
    pcall(Restore,ownStore)
    pcall(Restore,previewStore)
    CFG.aim.enabled=false
    if type(ENV)=="table" and ENV.STIRLAX_MODZ_KILL then
        ENV.STIRLAX_MODZ_KILL=nil
    end
end

if type(ENV)=="table" then
    ENV.STIRLAX_MODZ_KILL=function()
        Cleanup()
        if Gui.Parent then
            Gui:Destroy()
        end
    end
end

Gui.Destroying:Connect(function()
    Cleanup()
end)

Presets.LoadFile()
SafeCall("inicio: layout",ApplyLayout)
SafeCall("inicio: particulas",BuildParticles)
SafeCall("inicio: brillo",ApplyGlow)
SafeCall("inicio: pagina",Page,"PEOPLE")
SafeCall("inicio: perfil",Show,LP)
SafeCall("inicio: lista",Update)
SafeCall("inicio: skin",SelectSkin,"normal")
SafeCall("inicio: launcher",LayoutLauncher)
SafeCall("inicio: fly pad",Fly.UpdatePad)
Launcher.Visible=false
SetMenuOpen(true)
Notify("STIRLAX MODZ",STATE.mobile and "Listo. Usa el launcher para abrir y cerrar" or ("Listo. Tecla del menu: "..KeyName(CFG.ui.menuKey)),C.red)
