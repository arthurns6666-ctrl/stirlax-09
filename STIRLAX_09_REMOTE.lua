
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local VirtualUser
pcall(function() VirtualUser=game:GetService("VirtualUser") end)

local LP=Players.LocalPlayer

if not LP then
    warn("[09] LocalPlayer todavía no está disponible; ejecuta el código como LocalScript en Play.")
    return
end

local PG=LP:WaitForChild("PlayerGui",10)

if not PG then
    warn("[09] No se encontró PlayerGui después de 10 segundos.")
    return
end

local ADMIN_USERNAMES={
    gian12_10=true
}

if not ADMIN_USERNAMES[LP.Name:lower()] then
    warn("[09] Usuario no autorizado: "..LP.Name..". Cuenta permitida: gian12_10")
    return
end

local MW,MH=880,540

local C={
    black=Color3.fromRGB(2,3,7),
    glass=Color3.fromRGB(7,8,14),
    card=Color3.fromRGB(15,17,23),
    hover=Color3.fromRGB(36,40,50),
    white=Color3.fromRGB(245,247,255),
    gray=Color3.fromRGB(160,168,185),
    blue=Color3.fromRGB(185,215,240),
    green=Color3.fromRGB(160,220,180),
    red=Color3.fromRGB(225,150,160),
    gold=Color3.fromRGB(225,210,170),
    yellow=Color3.fromRGB(255,214,40),
    amber=Color3.fromRGB(255,170,0)
}

local function N(c,p)
    local o=Instance.new(c)

    for k,v in pairs(p) do
        local ok,err=pcall(function()
            o[k]=v
        end)

        if not ok then
            warn("[09] Propiedad ignorada en "..c.."."..tostring(k)..": "..tostring(err))
        end
    end

    return o
end

local function R(o,n)
    N("UICorner",{
        CornerRadius=UDim.new(0,n or 10),
        Parent=o
    })
end

local function S(o,c,t)
    N("UIStroke",{
        Color=c or C.blue,
        Thickness=t or 1,
        Transparency=.25,
        Parent=o
    })
end

local function T(p,v,z,pos,sz,col,font)
    return N("TextLabel",{
        Parent=p,
        Text=v,
        Size=z,
        Position=pos or UDim2.new(),
        BackgroundTransparency=1,
        TextColor3=col or C.white,
        Font=font or Enum.Font.Gotham,
        TextSize=sz or 12,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center
    })
end

local function B(p,v,z,pos)
    local b=N("TextButton",{
        Parent=p,
        Text=v,
        Size=z,
        Position=pos,
        BackgroundColor3=C.card,
        TextColor3=C.white,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        AutoButtonColor=false,
        BorderSizePixel=0
    })

    R(b,8)

    return b
end

local function Root()
    local ch=LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function Hum()
    local ch=LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local old=PG:FindFirstChild("09")

if old then
    old:Destroy()
end


local origLight={
    Brightness=Lighting.Brightness,
    ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd,
    GlobalShadows=Lighting.GlobalShadows
}

local origGravity=workspace.Gravity
local origZoom=LP.CameraMaxZoomDistance
local origFov=workspace.CurrentCamera
    and workspace.CurrentCamera.FieldOfView
    or 70

local Gui=N("ScreenGui",{
    Name="09",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    Parent=PG
})


local EspLayer=N("Frame",{
    Name="EspLayer",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=0,
    Parent=Gui
})

local Main=N("Frame",{
    Size=UDim2.fromOffset(MW,MH),
    Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundColor3=C.black,
    BackgroundTransparency=.12,
    ClipsDescendants=true,
    Active=true,
    Draggable=true,
    Parent=Gui
})

R(Main,18)
S(Main,C.blue,2)

local MainScale=N("UIScale",{
    Scale=1,
    Parent=Main
})

local Launcher=N("TextButton",{
    Name="FloatingLauncher",
    Text="",
    AutoButtonColor=false,
    Size=UDim2.fromOffset(184,50),
    Position=UDim2.new(1,-204,1,-74),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.08,
    BorderSizePixel=0,
    Active=true,
    Draggable=true,
    ZIndex=50,
    Parent=Gui
})

R(Launcher,15)
S(Launcher,C.blue,1.5)

local LauncherScale=N("UIScale",{
    Scale=1,
    Parent=Launcher
})

local LauncherAccent=N("Frame",{
    Size=UDim2.fromOffset(4,30),
    Position=UDim2.fromOffset(10,10),
    BackgroundColor3=C.yellow,
    BorderSizePixel=0,
    ZIndex=51,
    Parent=Launcher
})
R(LauncherAccent,3)

local LauncherTitle=T(
    Launcher,
    "STIRLAX",
    UDim2.new(1,-68,0,20),
    UDim2.fromOffset(24,7),
    13,
    C.white,
    Enum.Font.GothamBlack
)
LauncherTitle.ZIndex=51

local LauncherSub=T(
    Launcher,
    "ABRIR PANEL 09",
    UDim2.new(1,-68,0,14),
    UDim2.fromOffset(24,28),
    9,
    C.gray,
    Enum.Font.GothamBold
)
LauncherSub.ZIndex=51

local LauncherAction=B(
    Launcher,
    "OPEN",
    UDim2.fromOffset(52,28),
    UDim2.new(1,-62,.5,-14)
)
LauncherAction.BackgroundColor3=C.hover
LauncherAction.TextColor3=C.blue
LauncherAction.TextSize=10
LauncherAction.ZIndex=52

local NotificationLayer=N("Frame",{
    Name="NotificationLayer",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=90,
    Parent=Gui
})

local notificationSerial=0

local function Notify(title,body,color)
    if not Gui.Parent then
        return
    end

    notificationSerial+=1
    local slot=(notificationSerial-1)%3
    local card=N("Frame",{
        Size=UDim2.fromOffset(278,58),
        Position=UDim2.new(1,310,1,-22-slot*66),
        AnchorPoint=Vector2.new(1,1),
        BackgroundColor3=C.glass,
        BackgroundTransparency=.05,
        BorderSizePixel=0,
        ZIndex=91,
        Parent=NotificationLayer
    })

    R(card,12)
    S(card,color or C.blue,1)

    local bar=N("Frame",{
        Size=UDim2.fromOffset(4,34),
        Position=UDim2.fromOffset(10,12),
        BackgroundColor3=color or C.blue,
        BorderSizePixel=0,
        ZIndex=92,
        Parent=card
    })
    R(bar,3)

    local titleLabel=T(card,title,UDim2.new(1,-30,0,18),UDim2.fromOffset(24,7),11,color or C.blue,Enum.Font.GothamBold)
    titleLabel.ZIndex=92
    local bodyLabel=T(card,body,UDim2.new(1,-30,0,22),UDim2.fromOffset(24,27),10,C.white,Enum.Font.GothamMedium)
    bodyLabel.ZIndex=92

    local inTween=TweenService:Create(card,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Position=UDim2.new(1,-18,1,-22-slot*66)
    })
    inTween:Play()

    task.delay(2.6,function()
        if not card.Parent then
            return
        end
        local outTween=TweenService:Create(card,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
            Position=UDim2.new(1,310,1,-22-slot*66)
        })
        outTween.Completed:Connect(function()
            if card.Parent then
                card:Destroy()
            end
        end)
        outTween:Play()
    end)
end

Main.Visible=false


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

N("UICorner",{
    CornerRadius=UDim.new(1,0),
    Parent=FovCircle
})

N("UIStroke",{
    Color=C.blue,
    Thickness=1.5,
    Transparency=.2,
    Parent=FovCircle
})


local Space=N("Frame",{
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ClipsDescendants=true,
    ZIndex=0,
    Parent=Main
})

for i=1,160 do
    local q=N("Frame",{
        Size=UDim2.fromOffset(
            math.random(1,3),
            math.random(1,3)
        ),
        Position=UDim2.new(
            math.random(),
            0,
            math.random(),
            0
        ),
        BackgroundColor3=i%7==0 and C.blue or C.white,
        BackgroundTransparency=math.random(25,85)/100,
        BorderSizePixel=0,
        ZIndex=1,
        Parent=Space
    })

    R(q,4)

    task.spawn(function()
        while q.Parent do
            TweenService:Create(
                q,
                TweenInfo.new(
                    math.random(15,40)/10,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    BackgroundTransparency=math.random(20,90)/100
                }
            ):Play()

            task.wait(math.random(15,40)/10)
        end
    end)
end


local function FogBlob(i,n)
    local blob=N("Frame",{
        Size=UDim2.fromOffset(
            math.random(420,640),
            math.random(170,280)
        ),
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(
            (i-1)/(n-1),
            math.random(10,90)/100
        ),
        BackgroundTransparency=1,
        ZIndex=1,
        Parent=Space
    })

    for k=1,6 do
        local s=1-(k-1)*.16

        local e=N("Frame",{
            Size=UDim2.fromScale(s,s),
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromScale(.5,.5),
            BackgroundColor3=Color3.fromRGB(175,198,230),
            BackgroundTransparency=.96,
            BorderSizePixel=0,
            ZIndex=1,
            Parent=blob
        })

        N("UICorner",{
            CornerRadius=UDim.new(1,0),
            Parent=e
        })
    end

    task.spawn(function()
        while blob.Parent do
            local tw=TweenService:Create(
                blob,
                TweenInfo.new(
                    math.random(90,180)/10,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    Position=UDim2.fromScale(
                        math.random(-10,110)/100,
                        math.random(0,100)/100
                    )
                }
            )

            tw:Play()
            tw.Completed:Wait()
        end
    end)
end

for i=1,9 do
    FogBlob(i,9)
end


local function Bolt()
    local curX=math.random(60,MW-60)
    local y=-10
    local pts={Vector2.new(curX,y)}
    local maxY=MH*math.random(55,100)/100

    while y<maxY do
        y=y+math.random(30,65)
        curX=curX+math.random(-45,45)
        table.insert(pts,Vector2.new(curX,y))
    end

    local parts={}

    local function Seg(a,b,thick,alpha)
        local d=b-a
        local mid=(a+b)/2

        local f=N("Frame",{
            Size=UDim2.fromOffset(d.Magnitude,thick),
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromOffset(mid.X,mid.Y),
            Rotation=math.deg(math.atan2(d.Y,d.X)),
            BackgroundColor3=C.white,
            BackgroundTransparency=alpha,
            BorderSizePixel=0,
            ZIndex=2,
            Parent=Space
        })

        local st=N("UIStroke",{
            Color=C.blue,
            Thickness=thick+3,
            Transparency=.6,
            Parent=f
        })

        table.insert(parts,{f,st})
    end

    for i=1,#pts-1 do
        Seg(pts[i],pts[i+1],3,0)

        if math.random()<.3 then
            local a=pts[i+1]

            local dir=Vector2.new(
                math.random(-70,70),
                math.random(25,60)
            )

            Seg(a,a+dir,1.5,.3)
        end
    end

    local flash=N("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=C.blue,
        BackgroundTransparency=.86,
        BorderSizePixel=0,
        ZIndex=1,
        Parent=Space
    })

    TweenService:Create(
        flash,
        TweenInfo.new(.55),
        {BackgroundTransparency=1}
    ):Play()

    task.delay(.6,function()
        flash:Destroy()
    end)

    local fade=.3+math.random()*.25

    for _,p in ipairs(parts) do
        TweenService:Create(
            p[1],
            TweenInfo.new(fade),
            {BackgroundTransparency=1}
        ):Play()

        TweenService:Create(
            p[2],
            TweenInfo.new(fade),
            {Transparency=1}
        ):Play()
    end

    task.delay(fade+.1,function()
        for _,p in ipairs(parts) do
            p[1]:Destroy()
        end
    end)
end

task.spawn(function()
    task.wait(.4)

    while Gui.Parent do
        Bolt()

        if math.random()<.45 then
            task.delay(.1,function()
                if Gui.Parent then
                    Bolt()
                end
            end)
        end

        if math.random()<.2 then
            task.delay(.22,function()
                if Gui.Parent then
                    Bolt()
                end
            end)
        end

        task.wait(math.random(6,22)/10)
    end
end)

local RootFrame=N("Frame",{
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=3,
    Parent=Main
})


local Header=N("Frame",{
    Size=UDim2.new(1,-32,0,60),
    Position=UDim2.fromOffset(16,14),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.25,
    ZIndex=4,
    Parent=RootFrame
})

R(Header,13)
S(Header,C.blue,1)


local BoltIcon=N("Frame",{
    Size=UDim2.fromOffset(50,50),
    Position=UDim2.fromOffset(14,5),
    BackgroundTransparency=1,
    Parent=Header
})

local boltPts={
    Vector2.new(32,2),
    Vector2.new(17,25),
    Vector2.new(30,25),
    Vector2.new(18,48)
}

local boltGlow={}

for i=1,#boltPts-1 do
    local a,b=boltPts[i],boltPts[i+1]
    local d=b-a
    local mid=(a+b)/2

    local f=N("Frame",{
        Size=UDim2.fromOffset(d.Magnitude+2,6),
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromOffset(mid.X,mid.Y),
        Rotation=math.deg(math.atan2(d.Y,d.X)),
        BackgroundColor3=C.yellow,
        BorderSizePixel=0,
        Parent=BoltIcon
    })

    R(f,3)

    table.insert(boltGlow,N("UIStroke",{
        Color=C.amber,
        Thickness=3,
        Transparency=.45,
        Parent=f
    }))
end

task.spawn(function()
    while Gui.Parent do
        for _,g in ipairs(boltGlow) do
            TweenService:Create(
                g,
                TweenInfo.new(.9,Enum.EasingStyle.Sine),
                {Transparency=.1}
            ):Play()
        end

        task.wait(.9)

        for _,g in ipairs(boltGlow) do
            TweenService:Create(
                g,
                TweenInfo.new(.9,Enum.EasingStyle.Sine),
                {Transparency=.7}
            ):Play()
        end

        task.wait(.9)
    end
end)

T(
    Header,
    "ADMIN",
    UDim2.fromOffset(120,22),
    UDim2.fromOffset(76,9),
    15,
    C.blue,
    Enum.Font.GothamBold
)

T(
    Header,
    "devolper 19",
    UDim2.fromOffset(120,18),
    UDim2.fromOffset(76,31),
    11,
    C.gray,
    Enum.Font.GothamBold
)

local tabs={}
local names={
    "PEOPLE",
    "MISC",
    "OG",
    "ESP",
    "SKINS",
    "EXTRAS",
    "STIRLAX"
}

for i,n in ipairs(names) do
    local b=B(
        Header,
        n,
        UDim2.fromOffset(64,30),
        UDim2.fromOffset(200+(i-1)*70,15)
    )

    tabs[n]=b
end

tabs.PEOPLE.BackgroundColor3=C.hover

local kill=B(
    Header,
    "KILL SCRIPT",
    UDim2.fromOffset(92,30),
    UDim2.new(1,-104,0,15)
)

kill.TextColor3=C.red


local Body=N("Frame",{
    Size=UDim2.new(1,-32,1,-96),
    Position=UDim2.fromOffset(16,82),
    BackgroundTransparency=1,
    ZIndex=4,
    Parent=RootFrame
})

local People=N("Frame",{
    Size=UDim2.fromScale(1,1),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.3,
    ZIndex=5,
    Parent=Body
})

R(People,14)
S(People,C.blue,1)

local List=N("ScrollingFrame",{
    Size=UDim2.new(0,200,1,-58),
    Position=UDim2.fromOffset(14,44),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.blue,
    CanvasSize=UDim2.new(),
    ZIndex=6,
    Parent=People
})

local LL=N("UIListLayout",{
    Padding=UDim.new(0,6),
    Parent=List
})

LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize=UDim2.fromOffset(
        0,
        LL.AbsoluteContentSize.Y+10
    )
end)

T(
    People,
    "PEOPLE",
    UDim2.fromOffset(180,25),
    UDim2.fromOffset(16,10),
    15,
    C.white,
    Enum.Font.GothamBold
)


local Info=N("Frame",{
    Size=UDim2.new(1,-232,1,-20),
    Position=UDim2.fromOffset(218,10),
    BackgroundColor3=C.glass,
    BackgroundTransparency=.35,
    ZIndex=5,
    Parent=People
})

R(Info,14)
S(Info,C.blue,1)

T(
    Info,
    "PERFIL 3D",
    UDim2.fromOffset(200,25),
    UDim2.fromOffset(16,8),
    14,
    C.blue,
    Enum.Font.GothamBold
)

local View=N("ViewportFrame",{
    Size=UDim2.fromOffset(250,250),
    Position=UDim2.fromOffset(16,40),
    BackgroundColor3=C.black,
    Ambient=Color3.fromRGB(200,200,210),
    LightColor=C.white,
    LightDirection=Vector3.new(-1,-1,-1),
    ZIndex=7,
    Parent=Info
})

R(View,14)
S(View,C.blue,1)

local Camera=N("Camera",{
    Parent=View
})

View.CurrentCamera=Camera

local Name=T(
    Info,
    "Selecciona un jugador",
    UDim2.new(1,-298,0,26),
    UDim2.fromOffset(282,44),
    19,
    C.white,
    Enum.Font.GothamBold
)

local User=T(
    Info,
    "@-",
    UDim2.new(1,-298,0,18),
    UDim2.fromOffset(282,74),
    11,
    C.blue
)

local State=T(
    Info,
    "estado: --",
    UDim2.new(1,-298,0,18),
    UDim2.fromOffset(282,96),
    11,
    C.green
)

local DetailList=N("ScrollingFrame",{
    Size=UDim2.new(1,-298,1,-140),
    Position=UDim2.fromOffset(282,126),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    CanvasSize=UDim2.new(),
    ZIndex=7,
    Parent=Info
})

local DL=N("UIListLayout",{
    Padding=UDim.new(0,6),
    Parent=DetailList
})

DL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DetailList.CanvasSize=UDim2.fromOffset(
        0,
        DL.AbsoluteContentSize.Y+10
    )
end)


local Pages={}

local PageDesc={
    MISC="Aim, movimiento, camara y utilidades. Clic en [NONE] para asignar tecla (Esc o Backspace la quita).",
    ESP="Solo afecta modelos en workspace.Targets o con la etiqueta Target.",
    SKINS="Skins Among Us y Free Fire. Solo las ves tu en tu personaje.",
    STIRLAX="Motores STIRLAX adicionales: ESP autorizada, aim local, fly estable y utilidades."
}

for _,n in ipairs({
    "MISC",
    "OG",
    "ESP",
    "SKINS",
    "EXTRAS",
    "STIRLAX"
}) do
    local page=N("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=C.glass,
        BackgroundTransparency=.3,
        Visible=false,
        ZIndex=10,
        Parent=Body
    })

    R(page,14)
    S(page,C.blue,1)

    T(
        page,
        n,
        UDim2.fromOffset(300,28),
        UDim2.fromOffset(20,10),
        22,
        C.white,
        Enum.Font.GothamBlack
    )

    if PageDesc[n] then
        T(
            page,
            PageDesc[n],
            UDim2.fromOffset(800,16),
            UDim2.fromOffset(20,40),
            10,
            C.gray
        )
    end

    Pages[n]=page
end


local conns={}

local function Track(c)
    table.insert(conns,c)
    return c
end

local function SafeCallback(label,callback,...)
    if not callback then
        return true
    end

    local ok,err=pcall(callback,...)
    if not ok then
        warn("[09] Error en callback "..tostring(label)..": "..tostring(err))
    end
    return ok
end

local function SafeDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local responsiveViewportConnection=nil
local function RefreshResponsive()
    local cam=workspace.CurrentCamera
    if not cam then
        return
    end

    local viewport=cam.ViewportSize
    local scale=math.clamp(
        math.min(viewport.X/(MW+24),viewport.Y/(MH+24)),
        .38,
        1
    )

    MainScale.Scale=scale
    LauncherScale.Scale=math.clamp(scale*1.08,.82,1.08)
end

local function BindResponsiveCamera()
    if responsiveViewportConnection then
        SafeDisconnect(responsiveViewportConnection)
        responsiveViewportConnection=nil
    end

    local cam=workspace.CurrentCamera
    if cam then
        responsiveViewportConnection=cam:GetPropertyChangedSignal("ViewportSize"):Connect(RefreshResponsive)
        Track(responsiveViewportConnection)
    end

    RefreshResponsive()
end

Track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindResponsiveCamera))
BindResponsiveCamera()


local Toggles={}
local listening=nil

local function Card(parent,order,pos)
    local card=N("Frame",{
        Size=UDim2.fromOffset(392,54),
        Position=pos or UDim2.new(),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
        Parent=parent
    })

    R(card,12)

    N("UIStroke",{
        Color=C.blue,
        Thickness=1,
        Transparency=.75,
        Parent=card
    })

    return card
end

local function Content(page,cw,ch,top)
    local sc=N("ScrollingFrame",{
        Size=UDim2.new(1,-40,1,-(top+12)),
        Position=UDim2.fromOffset(20,top),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=C.blue,
        CanvasSize=UDim2.new(),
        Parent=page
    })

    local grid=N("UIGridLayout",{
        CellSize=UDim2.fromOffset(cw,ch),
        CellPadding=UDim2.fromOffset(12,10),
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=sc
    })

    grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize=UDim2.fromOffset(
            0,
            grid.AbsoluteContentSize.Y+10
        )
    end)

    return sc
end

local function AttachKey(card,obj,x)
    local keyBtn=B(
        card,
        "[NONE]",
        UDim2.fromOffset(70,24),
        UDim2.new(1,x,.5,-12)
    )

    keyBtn.BackgroundColor3=C.hover
    keyBtn.TextColor3=C.gray
    keyBtn.TextSize=10

    function obj.SetKey(k)
        obj.Key=k

        keyBtn.Text=k
            and ("["..k.Name:upper().."]")
            or "[NONE]"

        keyBtn.TextColor3=k and C.blue or C.gray
    end

    keyBtn.Activated:Connect(function()
        if listening==obj then
            listening=nil
            obj.SetKey(obj.Key)
        else
            if listening then
                listening.SetKey(listening.Key)
            end

            listening=obj
            keyBtn.Text="[...]"
            keyBtn.TextColor3=C.gold
        end
    end)
end

local function MakeToggle(parent,order,label,default,onChange,pos)
    local card=Card(parent,order,pos)

    T(
        card,
        label,
        UDim2.new(1,-150,1,0),
        UDim2.fromOffset(14,0),
        11,
        C.white,
        Enum.Font.GothamBold
    )

    local sw=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        Size=UDim2.fromOffset(40,22),
        Position=UDim2.new(1,-52,.5,-11),
        BackgroundColor3=C.hover,
        BorderSizePixel=0,
        Parent=card
    })

    R(sw,11)

    local knob=N("Frame",{
        Size=UDim2.fromOffset(16,16),
        Position=UDim2.fromOffset(3,3),
        BackgroundColor3=C.gray,
        BorderSizePixel=0,
        Parent=sw
    })

    R(knob,8)

    local obj={
        Key=nil,
        State=false
    }

    local info=TweenInfo.new(.18,Enum.EasingStyle.Quad)

    function obj.Set(v,silent)
        obj.State=v and true or false

        TweenService:Create(sw,info,{
            BackgroundColor3=obj.State and C.green or C.hover
        }):Play()

        TweenService:Create(knob,info,{
            Position=obj.State
                and UDim2.fromOffset(21,3)
                or UDim2.fromOffset(3,3),
            BackgroundColor3=obj.State and C.white or C.gray
        }):Play()

        if not silent and onChange then
            SafeCallback(label,onChange,obj.State)
        end
    end

    function obj.Trigger()
        obj.Set(not obj.State)
    end

    AttachKey(card,obj,-130)

    sw.Activated:Connect(obj.Trigger)

    obj.Set(default,not default)

    table.insert(Toggles,obj)

    return obj
end

local function MakeButton(parent,order,label,onClick)
    local card=Card(parent,order)

    T(
        card,
        label,
        UDim2.new(1,-190,1,0),
        UDim2.fromOffset(14,0),
        11,
        C.white,
        Enum.Font.GothamBold
    )

    local run=B(
        card,
        "EJECUTAR",
        UDim2.fromOffset(76,24),
        UDim2.new(1,-88,.5,-12)
    )

    run.BackgroundColor3=C.hover
    run.TextColor3=C.green
    run.TextSize=10

    local obj={
        Key=nil,
        State=false
    }

    function obj.Trigger()
        SafeCallback(label,onClick)
    end

    AttachKey(card,obj,-166)

    run.Activated:Connect(obj.Trigger)

    table.insert(Toggles,obj)

    return obj
end

local function MakeSlider(parent,order,label,min,max,default,decimals,suffix,onChange)
    local card=Card(parent,order)

    T(
        card,
        label,
        UDim2.new(1,-110,0,18),
        UDim2.fromOffset(14,6),
        11,
        C.white,
        Enum.Font.GothamBold
    )

    local valueLabel=T(
        card,
        "",
        UDim2.fromOffset(90,18),
        UDim2.new(1,-104,0,6),
        10,
        C.blue,
        Enum.Font.GothamBold
    )

    valueLabel.TextXAlignment=Enum.TextXAlignment.Right

    local track=N("Frame",{
        Size=UDim2.new(1,-28,0,6),
        Position=UDim2.fromOffset(14,36),
        BackgroundColor3=C.hover,
        BorderSizePixel=0,
        Parent=card
    })

    R(track,3)

    local fill=N("Frame",{
        Size=UDim2.fromScale(0,1),
        BackgroundColor3=C.blue,
        BorderSizePixel=0,
        Parent=track
    })

    R(fill,3)

    local knob=N("Frame",{
        Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(0,.5),
        BackgroundColor3=C.white,
        BorderSizePixel=0,
        Parent=track
    })

    R(knob,7)

    local hit=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-28,0,24),
        Position=UDim2.fromOffset(14,27),
        Parent=card
    })

    local obj={
        Value=default
    }

    local fmt="%."..decimals.."f"

    local function render()
        local rel=(obj.Value-min)/(max-min)

        fill.Size=UDim2.fromScale(rel,1)
        knob.Position=UDim2.fromScale(rel,.5)
        valueLabel.Text=string.format(fmt,obj.Value)..(suffix or "")
    end

    function obj.Set(v,silent)
        local m=10^decimals

        v=math.clamp(math.floor(v*m+.5)/m,min,max)

        obj.Value=v
        render()

        if not silent and onChange then
            SafeCallback(label,onChange,v)
        end
    end

    local dragging=false

    local function fromX(x)
        local rel=math.clamp(
            (x-track.AbsolutePosition.X)/track.AbsoluteSize.X,
            0,
            1
        )

        obj.Set(min+(max-min)*rel)
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
            or input.UserInputType==Enum.UserInputType.Touch then

            dragging=true
            fromX(input.Position.X)
        end
    end)

    Track(UIS.InputChanged:Connect(function(input)
        if dragging
            and (
                input.UserInputType==Enum.UserInputType.MouseMovement
                or input.UserInputType==Enum.UserInputType.Touch
            ) then

            fromX(input.Position.X)
        end
    end))

    Track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
            or input.UserInputType==Enum.UserInputType.Touch then

            dragging=false
        end
    end))

    obj.Set(default,true)

    return obj
end

local function MakeSelector(parent,order,label,options,default,onChange)
    local card=Card(parent,order)

    T(
        card,
        label,
        UDim2.new(1,-160,1,0),
        UDim2.fromOffset(14,0),
        11,
        C.white,
        Enum.Font.GothamBold
    )

    local btn=B(
        card,
        "",
        UDim2.fromOffset(134,28),
        UDim2.new(1,-148,.5,-14)
    )

    btn.BackgroundColor3=C.hover
    btn.TextColor3=C.blue
    btn.TextSize=10

    local idx=default

    local function render()
        btn.Text=options[idx][1]
    end

    btn.Activated:Connect(function()
        idx=idx%#options+1
        render()
        SafeCallback(label,onChange,options[idx][2])
    end)

    render()
end


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

local function TargetModels()
    local output = {}
    local alreadyAdded = {}

    local function AddModel(model)
        if model
            and model:IsA("Model")
            and not alreadyAdded[model] then

            alreadyAdded[model] = true
            table.insert(output, model)
        end
    end

    local folder = workspace:FindFirstChild("Targets")

    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            AddModel(model)
        end
    end

    for _, model in ipairs(
        CollectionService:GetTagged("Target")
    ) do
        AddModel(model)
    end

    return output
end

local full=false
local noFog=false
local noShadows=false
local hourOn=false
local hourVal=14
local lightActive=false

local function ApplyLighting()
    local active=full or noFog or noShadows or hourOn

    if not active and not lightActive then
        return
    end

    lightActive=active

    Lighting.Brightness=full and 3 or origLight.Brightness

    Lighting.FogEnd=(full or noFog)
        and 100000
        or origLight.FogEnd

    if noShadows then
        Lighting.GlobalShadows=false
    else
        Lighting.GlobalShadows=origLight.GlobalShadows
    end

    if hourOn then
        Lighting.ClockTime=hourVal
    elseif full then
        Lighting.ClockTime=14
    else
        Lighting.ClockTime=origLight.ClockTime
    end
end


local xrayOn=false
local hlOn=false
local xrayFill=.55
local xrayStore={}
local hlStore={}

local function SyncHighlights(store,enabled,fill,fillColor,outlineColor)
    local want={}

    if enabled then
        for _,model in ipairs(TargetModels()) do
            want[model]=true
        end
    end

    for model,h in pairs(store) do
        if not want[model] or not h.Parent then
            h:Destroy()
            store[model]=nil
        end
    end

    for model in pairs(want) do
        if not store[model] then
            store[model]=N("Highlight",{
                Adornee=model,
                FillColor=fillColor,
                OutlineColor=outlineColor,
                FillTransparency=fill,
                DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
                Parent=model
            })
        end
    end

    for _,h in pairs(store) do
        h.FillTransparency=fill
    end
end

local function SyncHL()
    SyncHighlights(xrayStore,xrayOn,xrayFill,C.blue,C.white)
    SyncHighlights(hlStore,hlOn and not xrayOn,1,C.green,C.green)
end

task.spawn(function()
    while Gui.Parent do
        SyncHL()
        ApplyLighting()
        task.wait(.5)
    end
end)


local espCfg={
    boxes=false,
    names=false,
    dist=false,
    health=false,
    tracers=false,
    hpColor=true,
    range=500
}

local espEntries={}

local function NewEntry()
    local e={}

    e.box=N("Frame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Visible=false,
        Parent=EspLayer
    })

    e.stroke=N("UIStroke",{
        Color=C.blue,
        Thickness=1.5,
        Parent=e.box
    })

    e.name=T(
        EspLayer,
        "",
        UDim2.fromOffset(150,14),
        nil,
        11,
        C.white,
        Enum.Font.GothamBold
    )

    e.name.TextXAlignment=Enum.TextXAlignment.Center
    e.name.TextStrokeTransparency=.4
    e.name.Visible=false

    e.dist=T(
        EspLayer,
        "",
        UDim2.fromOffset(150,14),
        nil,
        10,
        C.gray,
        Enum.Font.GothamBold
    )

    e.dist.TextXAlignment=Enum.TextXAlignment.Center
    e.dist.TextStrokeTransparency=.4
    e.dist.Visible=false

    e.hpBack=N("Frame",{
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=.4,
        BorderSizePixel=0,
        Visible=false,
        Parent=EspLayer
    })

    e.hpFill=N("Frame",{
        AnchorPoint=Vector2.new(0,1),
        Position=UDim2.fromScale(0,1),
        Size=UDim2.fromScale(1,1),
        BorderSizePixel=0,
        Parent=e.hpBack
    })

    e.tracer=N("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        BorderSizePixel=0,
        Visible=false,
        Parent=EspLayer
    })

    return e
end

local function HideEntry(e)
    e.box.Visible=false
    e.name.Visible=false
    e.dist.Visible=false
    e.hpBack.Visible=false
    e.tracer.Visible=false
end

local function DestroyEntry(e)
    for _,v in ipairs({e.box,e.name,e.dist,e.hpBack,e.tracer}) do
        if v and v.Parent then
            v:Destroy()
        end
    end
end

local function EspStep()
    local cam=workspace.CurrentCamera

    local anyOn=espCfg.boxes
        or espCfg.names
        or espCfg.dist
        or espCfg.health
        or espCfg.tracers

    local models={}

    if anyOn and cam then
        for _,m in ipairs(TargetModels()) do
            models[m]=true
        end
    end

    for m,e in pairs(espEntries) do
        if not models[m] or not m.Parent then
            DestroyEntry(e)
            espEntries[m]=nil
        end
    end

    if not anyOn or not cam then
        return
    end

    local vp=cam.ViewportSize
    local root=Root()

    local origin=root
        and root.Position
        or cam.CFrame.Position

    for m in pairs(models) do
        local e=espEntries[m]

        if not e then
            e=NewEntry()
            espEntries[m]=e
        end

        local hum=m:FindFirstChildOfClass("Humanoid")
        local alive=not hum or hum.Health>0
        local ok,cf,size=pcall(m.GetBoundingBox,m)
        local shown=false

        if alive and ok then
            local d=(cf.Position-origin).Magnitude

            if d<=espCfg.range then
                local minX,minY=math.huge,math.huge
                local maxX,maxY=-math.huge,-math.huge
                local front=true

                for ix=-1,1,2 do
                    for iy=-1,1,2 do
                        for iz=-1,1,2 do
                            local w=cf:PointToWorldSpace(
                                Vector3.new(
                                    size.X*ix,
                                    size.Y*iy,
                                    size.Z*iz
                                )/2
                            )

                            local v=cam:WorldToViewportPoint(w)

                            if v.Z<=0 then
                                front=false
                            end

                            minX=math.min(minX,v.X)
                            minY=math.min(minY,v.Y)
                            maxX=math.max(maxX,v.X)
                            maxY=math.max(maxY,v.Y)
                        end
                    end
                end

                if front then
                    shown=true

                    local w=math.max(maxX-minX,4)
                    local h=math.max(maxY-minY,4)
                    local cx=minX+w/2

                    local frac=hum
                        and math.clamp(
                            hum.Health/math.max(hum.MaxHealth,1),
                            0,
                            1
                        )
                        or 1

                    local col=(espCfg.hpColor and hum)
                        and Color3.fromHSV(frac*.33,.9,1)
                        or C.blue

                    e.box.Position=UDim2.fromOffset(minX,minY)
                    e.box.Size=UDim2.fromOffset(w,h)
                    e.box.Visible=espCfg.boxes
                    e.stroke.Color=col

                    e.name.Text=m.Name
                    e.name.Position=UDim2.fromOffset(cx-75,minY-17)
                    e.name.Visible=espCfg.names

                    e.dist.Text=string.format("%d studs",d)
                    e.dist.Position=UDim2.fromOffset(cx-75,maxY+2)
                    e.dist.Visible=espCfg.dist

                    e.hpBack.Position=UDim2.fromOffset(minX-7,minY)
                    e.hpBack.Size=UDim2.fromOffset(3,h)
                    e.hpFill.Size=UDim2.fromScale(1,frac)
                    e.hpFill.BackgroundColor3=col
                    e.hpBack.Visible=espCfg.health

                    local a=Vector2.new(vp.X/2,vp.Y)
                    local b=Vector2.new(cx,maxY)
                    local dv=b-a
                    local mid=(a+b)/2

                    e.tracer.Size=UDim2.fromOffset(dv.Magnitude,1.5)
                    e.tracer.Position=UDim2.fromOffset(mid.X,mid.Y)
                    e.tracer.Rotation=math.deg(math.atan2(dv.Y,dv.X))
                    e.tracer.BackgroundColor3=col
                    e.tracer.Visible=espCfg.tracers
                end
            end
        end

        if not shown then
            HideEntry(e)
        end
    end
end


local aimOn=false
local showFov=true
local showMarker=true
local AIM_FOV=150
local AIM_RANGE=250
local AIM_STRENGTH=.06
local AIM_PART="Head"

local _currentTarget=nil
local aimMarker=nil
local markerTarget=nil

local function UpdateFov()
    FovCircle.Size=UDim2.fromOffset(AIM_FOV*2,AIM_FOV*2)
    FovCircle.Visible=aimOn and showFov
end

local function SetMarker(part)
    if part==markerTarget then
        return
    end

    markerTarget=part

    if aimMarker then
        aimMarker:Destroy()
        aimMarker=nil
    end

    if part then
        aimMarker=N("BillboardGui",{
            Adornee=part,
            Size=UDim2.fromOffset(150,45),
            AlwaysOnTop=true,
            Parent=part
        })

        N("TextLabel",{
            Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            Text="AIM",
            TextColor3=C.white,
            TextStrokeTransparency=.2,
            Font=Enum.Font.GothamBold,
            TextSize=14,
            Parent=aimMarker
        })
    end
end

local function GetTarget()
    local character=LP.Character
    local root=Root()
    local cam=workspace.CurrentCamera

    if not root or not cam then
        return nil
    end

    local center=cam.ViewportSize/2
    local nearest,nearestPos=nil,nil
    local best=AIM_FOV

    for _,model in ipairs(TargetModels()) do
        if model~=character then
            local hum=model:FindFirstChildOfClass("Humanoid")
            local head=model:FindFirstChild("Head")

            local torso=model:FindFirstChild("UpperTorso")
                or model:FindFirstChild("Torso")
                or model:FindFirstChild("HumanoidRootPart")
                or model.PrimaryPart

            local part

            if AIM_PART=="Chest" then
                part=torso or head
            else
                part=head or torso
            end

            if part and (not hum or hum.Health>0) then
                local pos=part.Position

                if AIM_PART=="Neck" and part==head then
                    pos=pos-Vector3.new(0,head.Size.Y*.5,0)
                end

                if (pos-root.Position).Magnitude<=AIM_RANGE then
                    local v,onScreen=cam:WorldToViewportPoint(pos)

                    if onScreen then
                        local d=(Vector2.new(v.X,v.Y)-center).Magnitude

                        if d<=best then
                            best=d
                            nearest=part
                            nearestPos=pos
                        end
                    end
                end
            end
        end
    end

    return nearest,nearestPos
end


local speedOn=false
local speedVal=32
local origSpeed=nil

local jumpOn=false
local jumpVal=100
local origJump=nil
local origUseJP=nil

local flyOn=false
local flySpeed=60
local flyActive=false

local noclipOn=false
local ncStore={}

local infJump=false
local gravityOn=false
local gravityVal=100
local camFovOn=false
local camFovVal=90
local camFovActive=false
local zoomOn=false
local spinOn=false
local spinSpeed=360
local antiAfk=false
local clickTp=false

local function ApplySpeed()
    local hum=Hum()

    if not hum then
        return
    end

    if speedOn then
        if not origSpeed then
            origSpeed=hum.WalkSpeed
        end

        if hum.WalkSpeed~=speedVal then
            hum.WalkSpeed=speedVal
        end
    elseif origSpeed then
        hum.WalkSpeed=origSpeed
        origSpeed=nil
    end
end

local function ApplyJump()
    local hum=Hum()

    if not hum then
        return
    end

    if jumpOn then
        if not origJump then
            origJump=hum.JumpPower
            origUseJP=hum.UseJumpPower
        end

        hum.UseJumpPower=true
        hum.JumpPower=jumpVal
    elseif origJump then
        hum.UseJumpPower=origUseJP
        hum.JumpPower=origJump
        origJump=nil
    end
end

local function ApplyGravity()
    workspace.Gravity=gravityOn and gravityVal or origGravity
end

local function ApplyZoom()
    LP.CameraMaxZoomDistance=zoomOn and 1000 or origZoom
end

local function DoFly()
    local root=Root()
    local hum=Hum()
    local camera=workspace.CurrentCamera

    if flyOn and root and hum and camera then
        flyActive=true
        hum.PlatformStand=true

        local cf=camera.CFrame
        local dir=Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            dir=dir+cf.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            dir=dir-cf.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            dir=dir+cf.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            dir=dir-cf.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir=dir+Vector3.yAxis
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir=dir-Vector3.yAxis
        end

        if dir.Magnitude>0 then
            dir=dir.Unit
        end

        root.AssemblyLinearVelocity=dir*flySpeed

        local look=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)

        if look.Magnitude>0 then
            root.CFrame=CFrame.lookAt(
                root.Position,
                root.Position+look
            )
        end
    elseif flyActive then
        flyActive=false

        if hum then
            hum.PlatformStand=false
        end

        if root then
            root.AssemblyLinearVelocity=Vector3.zero
        end
    end
end

local function TpTarget()
    local root=Root()

    if not root then
        return
    end

    local best=nil
    local bd=math.huge

    for _,m in ipairs(TargetModels()) do
        local p=m:FindFirstChild("HumanoidRootPart")
            or m.PrimaryPart
            or m:FindFirstChildWhichIsA("BasePart")

        if p then
            local d=(p.Position-root.Position).Magnitude

            if d<bd then
                bd=d
                best=p
            end
        end
    end

    if best then
        root.CFrame=CFrame.new(
            best.Position+Vector3.new(0,3,6)
        )
    end
end

local function ResetChar()
    local hum=Hum()

    if hum then
        hum.Health=0
    end
end

Track(RunService.Stepped:Connect(function()
    local ch=LP.Character

    if noclipOn and ch then
        for _,d in ipairs(ch:GetDescendants()) do
            if d:IsA("BasePart") and d.CanCollide then
                ncStore[d]=true
                d.CanCollide=false
            end
        end
    elseif next(ncStore) then
        for part in pairs(ncStore) do
            if part.Parent then
                part.CanCollide=true
            end
        end

        table.clear(ncStore)
    end
end))

Track(UIS.JumpRequest:Connect(function()
    if infJump then
        local hum=Hum()

        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

Track(LP.Idled:Connect(function()
    if antiAfk and VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

local menuOpen=false
local menuBusy=false
local menuTweenInfo=TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

local function SetMenuOpen(open)
    if menuBusy or not Gui.Parent then
        return
    end

    menuBusy=true
    menuOpen=open and true or false

    if menuOpen then
        Launcher.Visible=false
        Main.Visible=true
        Main.Position=UDim2.fromScale(.5,.56)
        local tween=TweenService:Create(Main,menuTweenInfo,{
            Position=UDim2.fromScale(.5,.5)
        })
        tween.Completed:Connect(function()
            menuBusy=false
        end)
        tween:Play()
    else
        local tween=TweenService:Create(Main,menuTweenInfo,{
            Position=UDim2.fromScale(.5,.56)
        })
        tween.Completed:Connect(function()
            if Gui.Parent and not menuOpen then
                Main.Visible=false
                Launcher.Visible=true
            end
            menuBusy=false
        end)
        tween:Play()
    end
end

Launcher.Activated:Connect(function()
    SetMenuOpen(not menuOpen)
end)

LauncherAction.Activated:Connect(function()
    SetMenuOpen(true)
end)

Track(UIS.InputBegan:Connect(function(input,gp)
    if gp or not clickTp then
        return
    end

    if input.UserInputType==Enum.UserInputType.MouseButton1
        and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then

        local root=Root()
        local mouse=LP:GetMouse()

        if root and mouse.Hit then
            root.CFrame=CFrame.new(
                mouse.Hit.Position+Vector3.new(0,3,0)
            )
        end
    end
end))

pcall(function()
    RunService:UnbindFromRenderStep("09Step")
    RunService:UnbindFromRenderStep("09EspStep")
end)

pcall(function()
    RunService:BindToRenderStep(
        "09Step",
        Enum.RenderPriority.Camera.Value+1,
        function(dt)
            local ok,err=pcall(function()
                local cam=workspace.CurrentCamera
                if aimOn and cam then
                    local t,pos=GetTarget()
                    _currentTarget=t
                    if t and pos then
                        cam.CFrame=cam.CFrame:Lerp(
                            CFrame.lookAt(cam.CFrame.Position,pos),
                            AIM_STRENGTH
                        )
                    end
                    SetMarker(showMarker and t or nil)
                else
                    _currentTarget=nil
                    SetMarker(nil)
                end
                if cam then
                    if camFovOn then
                        camFovActive=true
                        cam.FieldOfView=camFovVal
                    elseif camFovActive then
                        camFovActive=false
                        cam.FieldOfView=origFov
                    end
                end
                ApplySpeed()
                ApplyJump()
                DoFly()
                if spinOn then
                    local root=Root()
                    if root then
                        root.CFrame=root.CFrame
                            *CFrame.Angles(0,math.rad(spinSpeed)*dt,0)
                    end
                end
            end)
            if not ok then
                warn("[09] Motor original pausado en este frame: "..tostring(err))
            end
        end
    )
end)

pcall(function()
    RunService:BindToRenderStep(
        "09EspStep",
        Enum.RenderPriority.Camera.Value+2,
        function()
            local ok,err=pcall(EspStep)
            if not ok then
                warn("[09] ESP original pausada: "..tostring(err))
            end
        end
    )
end)

local StirlaxCleanup
do

local STIRLAX_CFG={
    esp={
        enabled=false,
        boxes=true,
        corners=true,
        names=true,
        distance=true,
        health=true,
        tracers=false,
        arrows=true,
        wall=false,
        onlyAlive=true,
        hpColor=true,
        range=1500,
        thickness=1.5
    },
    aim={
        enabled=false,
        wall=false,
        alwaysOn=false,
        showFov=true,
        showMarker=true,
        fov=140,
        strength=.22,
        range=650,
        bone="Head",
        priority="Center"
    },
    fly={
        enabled=false,
        speed=95,
        vertical=70,
        acceleration=.22,
        deceleration=.28
    },
    worldFade={
        enabled=false,
        amount=.52
    },
    tool={
        enabled=false,
        cooldown=.08
    }
}

local STIRLAX_LAYER=N("Frame",{
    Name="StirlaxEspLayer",
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    ZIndex=0,
    Parent=Gui
})

local STIRLAX_FOV=N("Frame",{
    Name="StirlaxFovCircle",
    Size=UDim2.fromOffset(STIRLAX_CFG.aim.fov*2,STIRLAX_CFG.aim.fov*2),
    Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),
    BackgroundTransparency=1,
    Visible=false,
    ZIndex=2,
    Parent=Gui
})

R(STIRLAX_FOV,300)
S(STIRLAX_FOV,C.gold,1.5)

local STIRLAX_STATUS=T(
    Pages.STIRLAX,
    "STIRLAX: standby · motor original 09 intacto",
    UDim2.new(1,-40,0,14),
    UDim2.fromOffset(20,53),
    9,
    C.gray,
    Enum.Font.GothamMedium
)

local stEspEntries={}
local stAimMarker=nil
local stAimMarkerTarget=nil
local stWorldParts={}
local stWorldConnection=nil
local stFlyConnection=nil
local stFlyAttachment=nil
local stLinearVelocity=nil
local stAlignOrientation=nil
local stToolConnection=nil
local stToolLast=0
local stSavedPreset=nil

local function StirlaxStatus(text,color)
    if STIRLAX_STATUS and STIRLAX_STATUS.Parent then
        STIRLAX_STATUS.Text="STIRLAX: "..text
        STIRLAX_STATUS.TextColor3=color or C.gray
        Notify("STIRLAX",text,color or C.gray)
    end
end

local function StirlaxTargetPart(model,bone)
    if not model then
        return nil,nil
    end

    local head=model:FindFirstChild("Head")
    local torso=model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
    local lower=model:FindFirstChild("LowerTorso") or torso
    local part=bone=="Head" and (head or torso)
        or bone=="Neck" and (head or torso)
        or bone=="Chest" and (torso or head)
        or (lower or torso or head)

    if not part or not part:IsA("BasePart") then
        return nil,nil
    end

    local offset=Vector3.zero
    if bone=="Neck" and head then
        part=head
        offset=Vector3.new(0,-head.Size.Y*.42,0)
    elseif bone=="Hip" and part==lower then
        offset=Vector3.new(0,-math.max(lower.Size.Y*.18,.05),0)
    end

    return part,part.CFrame:PointToWorldSpace(offset)
end

local function StirlaxVisible(camera,model,point,forAim)
    local check=forAim and STIRLAX_CFG.aim.wall or STIRLAX_CFG.esp.wall
    if not check then
        return true
    end

    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    local filter={model}
    if LP.Character then
        table.insert(filter,LP.Character)
    end
    params.FilterDescendantsInstances=filter
    local hit=workspace:Raycast(camera.CFrame.Position,point-camera.CFrame.Position,params)
    return hit==nil
end

local function StirlaxNewEspEntry()
    local e={}

    e.box=N("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Visible=false,
        ZIndex=3,
        Parent=STIRLAX_LAYER
    })

    e.stroke=N("UIStroke",{
        Color=C.blue,
        Thickness=1.5,
        Transparency=.15,
        Parent=e.box
    })

    e.corners={}
    for i=1,8 do
        e.corners[i]=N("Frame",{
            BackgroundColor3=C.blue,
            BorderSizePixel=0,
            Visible=false,
            ZIndex=4,
            Parent=e.box
        })
    end

    e.name=T(STIRLAX_LAYER,"",UDim2.fromOffset(220,16),nil,11,C.white,Enum.Font.GothamBold)
    e.name.AnchorPoint=Vector2.new(.5,1)
    e.name.TextXAlignment=Enum.TextXAlignment.Center
    e.name.TextStrokeColor3=C.black
    e.name.TextStrokeTransparency=.12
    e.name.Visible=false
    e.name.ZIndex=5

    e.dist=T(STIRLAX_LAYER,"",UDim2.fromOffset(220,15),nil,10,C.gray,Enum.Font.GothamBold)
    e.dist.AnchorPoint=Vector2.new(.5,0)
    e.dist.TextXAlignment=Enum.TextXAlignment.Center
    e.dist.TextStrokeColor3=C.black
    e.dist.TextStrokeTransparency=.12
    e.dist.Visible=false
    e.dist.ZIndex=5

    e.healthBack=N("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=.28,
        BorderSizePixel=0,
        Visible=false,
        ZIndex=4,
        Parent=STIRLAX_LAYER
    })
    R(e.healthBack,2)

    e.health=N("Frame",{
        AnchorPoint=Vector2.new(0,1),
        Position=UDim2.new(0,1,1,-1),
        Size=UDim2.new(1,-2,1),
        BackgroundColor3=C.green,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=e.healthBack
    })
    R(e.health,2)

    e.tracer=N("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=C.blue,
        BorderSizePixel=0,
        Visible=false,
        ZIndex=2,
        Parent=STIRLAX_LAYER
    })
    R(e.tracer,3)

    e.arrow=T(STIRLAX_LAYER,"◆",UDim2.fromOffset(30,30),nil,18,C.gold,Enum.Font.GothamBlack)
    e.arrow.AnchorPoint=Vector2.new(.5,.5)
    e.arrow.TextXAlignment=Enum.TextXAlignment.Center
    e.arrow.TextStrokeColor3=C.black
    e.arrow.TextStrokeTransparency=.15
    e.arrow.Visible=false
    e.arrow.ZIndex=6

    return e
end

local function StirlaxHideEsp(e)
    e.box.Visible=false
    e.name.Visible=false
    e.dist.Visible=false
    e.healthBack.Visible=false
    e.tracer.Visible=false
    e.arrow.Visible=false
    for _,corner in ipairs(e.corners) do
        corner.Visible=false
    end
end

local function StirlaxDestroyEsp(e)
    for _,object in ipairs({e.box,e.name,e.dist,e.healthBack,e.tracer,e.arrow}) do
        if object and object.Parent then
            object:Destroy()
        end
    end
end

local function StirlaxCornerLayout(e,width,height,thickness,color)
    local length=math.clamp(math.min(width,height)*.28,6,20)
    local data={
        {UDim2.fromOffset(0,0),UDim2.fromOffset(length,thickness)},
        {UDim2.fromOffset(0,0),UDim2.fromOffset(thickness,length)},
        {UDim2.new(1,-length,0,0),UDim2.fromOffset(length,thickness)},
        {UDim2.new(1,-thickness,0,0),UDim2.fromOffset(thickness,length)},
        {UDim2.new(0,0,1,-length),UDim2.fromOffset(thickness,length)},
        {UDim2.new(0,0,1,-thickness),UDim2.fromOffset(length,thickness)},
        {UDim2.new(1,-thickness,1,-length),UDim2.fromOffset(thickness,length)},
        {UDim2.new(1,-length,1,-thickness),UDim2.fromOffset(length,thickness)}
    }

    for i,corner in ipairs(e.corners) do
        corner.Position=data[i][1]
        corner.Size=data[i][2]
        corner.BackgroundColor3=color
        corner.Visible=STIRLAX_CFG.esp.corners and STIRLAX_CFG.esp.boxes
    end
end

local function StirlaxWorldPointBox(camera,model)
    local ok,cf,size=pcall(model.GetBoundingBox,model)
    if not ok or not cf or not size then
        return nil
    end

    local minX,minY=math.huge,math.huge
    local maxX,maxY=-math.huge,-math.huge
    local front=true

    for ix=-1,1,2 do
        for iy=-1,1,2 do
            for iz=-1,1,2 do
                local point=cf:PointToWorldSpace(Vector3.new(size.X*ix,size.Y*iy,size.Z*iz)/2)
                local view=camera:WorldToViewportPoint(point)
                if view.Z<=0 then front=false end
                minX=math.min(minX,view.X)
                minY=math.min(minY,view.Y)
                maxX=math.max(maxX,view.X)
                maxY=math.max(maxY,view.Y)
            end
        end
    end

    return {
        minX=minX,
        minY=minY,
        maxX=maxX,
        maxY=maxY,
        front=front,
        center=cf.Position
    }
end

local function StirlaxEspStep()
    local camera=workspace.CurrentCamera
    local cfg=STIRLAX_CFG.esp
    local any=cfg.enabled and (cfg.boxes or cfg.names or cfg.distance or cfg.health or cfg.tracers or cfg.arrows)
    local models={}

    if any and camera then
        for _,model in ipairs(TargetModels()) do
            models[model]=true
        end
    end

    for model,entry in pairs(stEspEntries) do
        if not models[model] or not model.Parent then
            StirlaxDestroyEsp(entry)
            stEspEntries[model]=nil
        end
    end

    if not any or not camera then
        return
    end

    local viewport=camera.ViewportSize
    local root=Root()
    local origin=root and root.Position or camera.CFrame.Position

    for model in pairs(models) do
        local entry=stEspEntries[model]
        if not entry then
            entry=StirlaxNewEspEntry()
            stEspEntries[model]=entry
        end

        local hum=model:FindFirstChildOfClass("Humanoid")
        local alive=not hum or hum.Health>0
        local box=StirlaxWorldPointBox(camera,model)
        local shown=false

        if alive and (not cfg.onlyAlive or alive) and box then
            local minX=box.minX
            local minY=box.minY
            local maxX=box.maxX
            local maxY=box.maxY
            local front=box.front
            local center=box.center
            local distance=(center-origin).Magnitude

            if distance<=cfg.range and front and (not cfg.wall or StirlaxVisible(camera,model,center,false)) then
                local width=math.max(maxX-minX,6)
                local height=math.max(maxY-minY,8)
                local centerX=(minX+maxX)/2
                local centerY=(minY+maxY)/2
                local frac=hum and math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1) or 1
                local color=(cfg.hpColor and hum) and Color3.fromHSV(frac*.33,.9,1) or C.blue
                local thickness=math.clamp(cfg.thickness,1,4)
                shown=true

                entry.box.Position=UDim2.fromOffset(centerX,centerY)
                entry.box.Size=UDim2.fromOffset(width,height)
                entry.stroke.Color=color
                entry.stroke.Thickness=thickness
                entry.stroke.Transparency=cfg.corners and 1 or .12
                entry.box.Visible=cfg.boxes
                StirlaxCornerLayout(entry,width,height,thickness,color)

                entry.name.Text=model.Name
                entry.name.Position=UDim2.fromOffset(centerX,minY-3)
                entry.name.Visible=cfg.names

                entry.dist.Text=string.format("%d studs",math.floor(distance+.5))
                entry.dist.Position=UDim2.fromOffset(centerX,maxY+3)
                entry.dist.Visible=cfg.distance

                entry.healthBack.Position=UDim2.fromOffset(minX-8,centerY)
                entry.healthBack.Size=UDim2.fromOffset(4,math.clamp(height*.72,10,72))
                entry.health.Size=UDim2.new(1,-2,frac,-1)
                entry.health.BackgroundColor3=color
                entry.healthBack.Visible=cfg.health and hum~=nil

                local start=Vector2.new(viewport.X/2,viewport.Y-18)
                local finish=Vector2.new(centerX,maxY)
                local delta=finish-start
                entry.tracer.Position=UDim2.fromOffset((start.X+finish.X)/2,(start.Y+finish.Y)/2)
                entry.tracer.Size=UDim2.fromOffset(delta.Magnitude,thickness)
                entry.tracer.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                entry.tracer.BackgroundColor3=color
                entry.tracer.Visible=cfg.tracers
            end
        end

        if not shown then
            StirlaxHideEsp(entry)
        end

        if cfg.arrows and any and box and not shown then
            local view=camera:WorldToViewportPoint(box.center)
            local screenCenter=Vector2.new(viewport.X/2,viewport.Y/2)
            local direction=Vector2.new(view.X,view.Y)-screenCenter
            if direction.Magnitude<.01 then direction=Vector2.new(0,-1) end
            if view.Z<0 then direction=-direction end
            local radius=math.max(24,math.min(viewport.X,viewport.Y)/2-30)
            local point=screenCenter+direction.Unit*radius
            entry.arrow.Position=UDim2.fromOffset(math.clamp(point.X,18,viewport.X-18),math.clamp(point.Y,18,viewport.Y-18))
            entry.arrow.Rotation=math.deg(math.atan2(direction.Y,direction.X))+90
            entry.arrow.TextColor3=C.gold
            entry.arrow.Visible=true
        end
    end
end

local function StirlaxUpdateFov()
    STIRLAX_FOV.Size=UDim2.fromOffset(STIRLAX_CFG.aim.fov*2,STIRLAX_CFG.aim.fov*2)
    STIRLAX_FOV.Visible=STIRLAX_CFG.aim.enabled and STIRLAX_CFG.aim.showFov
end

local function StirlaxSetMarker(part)
    if part==stAimMarkerTarget then
        if part==nil then
            return
        end
        if STIRLAX_CFG.aim.showMarker and stAimMarker then
            return
        end
        if not STIRLAX_CFG.aim.showMarker and not stAimMarker then
            return
        end
    end

    if stAimMarker then
        stAimMarker:Destroy()
        stAimMarker=nil
    end
    stAimMarkerTarget=part

    if part and STIRLAX_CFG.aim.showMarker then
        stAimMarker=N("BillboardGui",{
            Adornee=part,
            Size=UDim2.fromOffset(150,34),
            AlwaysOnTop=true,
            Parent=part
        })
        T(stAimMarker,"STIRLAX AIM",UDim2.fromScale(1,1),nil,12,C.gold,Enum.Font.GothamBold).TextXAlignment=Enum.TextXAlignment.Center
    end
end

local function StirlaxAimHeld()
    return STIRLAX_CFG.aim.alwaysOn
        or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

local function StirlaxAimTarget()
    local camera=workspace.CurrentCamera
    local root=Root()
    if not camera or not root then
        return nil,nil
    end

    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    local best=STIRLAX_CFG.aim.priority=="Distance" and math.huge or STIRLAX_CFG.aim.fov
    local bestPart,bestPosition=nil,nil

    for _,model in ipairs(TargetModels()) do
        local hum=model:FindFirstChildOfClass("Humanoid")
        local part,position=StirlaxTargetPart(model,STIRLAX_CFG.aim.bone)
        if part and position and (not hum or hum.Health>0) then
            local distance=(position-root.Position).Magnitude
            if distance<=STIRLAX_CFG.aim.range then
                local view,onScreen=camera:WorldToViewportPoint(position)
                if onScreen and view.Z>0 then
                    local screenDistance=(Vector2.new(view.X,view.Y)-center).Magnitude
                    local candidate=STIRLAX_CFG.aim.priority=="Distance" and distance or screenDistance
                    if screenDistance<=STIRLAX_CFG.aim.fov and candidate<=best and StirlaxVisible(camera,model,position,true) then
                        best=candidate
                        bestPart=part
                        bestPosition=position
                    end
                end
            end
        end
    end

    return bestPart,bestPosition
end

local function StirlaxAimStep()
    local camera=workspace.CurrentCamera
    if not STIRLAX_CFG.aim.enabled or not camera or not StirlaxAimHeld() then
        StirlaxSetMarker(nil)
        return
    end

    local part,position=StirlaxAimTarget()
    if part and position then
        local strength=math.clamp(STIRLAX_CFG.aim.strength,.01,1)
        camera.CFrame=camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position,position),strength)
        StirlaxSetMarker(part)
    else
        StirlaxSetMarker(nil)
    end
end

local function StirlaxStopFly()
    STIRLAX_CFG.fly.enabled=false
    if stFlyConnection then
        SafeDisconnect(stFlyConnection)
        stFlyConnection=nil
    end
    if stLinearVelocity then stLinearVelocity:Destroy(); stLinearVelocity=nil end
    if stAlignOrientation then stAlignOrientation:Destroy(); stAlignOrientation=nil end
    if stFlyAttachment then stFlyAttachment:Destroy(); stFlyAttachment=nil end

    local hum=Hum()
    local root=Root()
    if hum then
        hum.PlatformStand=false
        hum.AutoRotate=true
        if hum.Health>0 then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    if root then root.AssemblyLinearVelocity=Vector3.zero end
end

local function StirlaxStartFly()
    if flyOn then
        StirlaxStatus("fly avanzado bloqueado: apaga FLY original",C.red)
        return false
    end

    local root=Root()
    local hum=Hum()
    if not root or not hum or hum.Health<=0 then
        StirlaxStatus("fly esperando personaje",C.red)
        return false
    end

    StirlaxStopFly()
    STIRLAX_CFG.fly.enabled=true
    hum.PlatformStand=true
    hum.AutoRotate=false
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    stFlyAttachment=N("Attachment",{Name="StirlaxFlyAttachment",Parent=root})
    stLinearVelocity=N("LinearVelocity",{
        Name="StirlaxLinearVelocity",
        Attachment0=stFlyAttachment,
        RelativeTo=Enum.ActuatorRelativeTo.World,
        VelocityConstraintMode=Enum.VelocityConstraintMode.Vector,
        ForceLimitsEnabled=false,
        VectorVelocity=Vector3.zero,
        Parent=root
    })
    stAlignOrientation=N("AlignOrientation",{
        Name="StirlaxAlignOrientation",
        Attachment0=stFlyAttachment,
        Mode=Enum.OrientationAlignmentMode.OneAttachment,
        RigidityEnabled=false,
        Responsiveness=35,
        MaxTorque=1000000,
        Parent=root
    })

    stFlyConnection=RunService.RenderStepped:Connect(function()
        local ok,err=pcall(function()
        if not STIRLAX_CFG.fly.enabled or not root.Parent or hum.Health<=0 then
            StirlaxStopFly()
            return
        end

        local camera=workspace.CurrentCamera
        if not camera or not stLinearVelocity or not stAlignOrientation then
            return
        end

        local look=camera.CFrame.LookVector
        local right=camera.CFrame.RightVector
        local flatLook=Vector3.new(look.X,0,look.Z)
        local flatRight=Vector3.new(right.X,0,right.Z)
        flatLook=flatLook.Magnitude>.001 and flatLook.Unit or Vector3.new(0,0,-1)
        flatRight=flatRight.Magnitude>.001 and flatRight.Unit or Vector3.new(1,0,0)

        local direction=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then direction+=flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then direction-=flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then direction-=flatRight end
        if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then direction+=flatRight end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift) then direction-=Vector3.yAxis end
        if direction.Magnitude<.001 and hum.MoveDirection.Magnitude>.05 then
            direction=Vector3.new(hum.MoveDirection.X,0,hum.MoveDirection.Z)
        end
        if direction.Magnitude>1 then direction=direction.Unit end

        local horizontal=Vector3.new(direction.X,0,direction.Z)
        local target=(horizontal.Magnitude>.001 and horizontal.Unit*STIRLAX_CFG.fly.speed or Vector3.zero)
            +Vector3.new(0,direction.Y*STIRLAX_CFG.fly.vertical,0)
        local blend=direction.Magnitude>.001 and STIRLAX_CFG.fly.acceleration or STIRLAX_CFG.fly.deceleration
        stLinearVelocity.VectorVelocity=stLinearVelocity.VectorVelocity:Lerp(target,math.clamp(blend,.02,1))

        local facing=Vector3.new(look.X,0,look.Z)
        if facing.Magnitude>.001 then
            stAlignOrientation.CFrame=CFrame.lookAt(root.Position,root.Position+facing.Unit)
        end
        end)
        if not ok then
            warn("[09] Fly STIRLAX pausado en este frame: "..tostring(err))
            StirlaxStopFly()
        end
    end)

    StirlaxStatus("fly avanzado activo · WASD / espacio / shift",C.green)
    return true
end

local function StirlaxSetFly(on)
    if on then
        if not StirlaxStartFly() then
            STIRLAX_CFG.fly.enabled=false
        end
    else
        StirlaxStopFly()
        StirlaxStatus("fly avanzado apagado",C.gray)
    end
end

local function StirlaxAuthorizedDescendant(object)
    local folder=workspace:FindFirstChild("Targets")
    if folder and object:IsDescendantOf(folder) then
        return true
    end
    for _,model in ipairs(CollectionService:GetTagged("Target")) do
        if object:IsDescendantOf(model) then
            return true
        end
    end
    return false
end

local function StirlaxApplyFade(object)
    if object:IsA("BasePart") and not (LP.Character and object:IsDescendantOf(LP.Character)) and not StirlaxAuthorizedDescendant(object) then
        if stWorldParts[object]==nil then
            stWorldParts[object]=object.LocalTransparencyModifier
        end
        object.LocalTransparencyModifier=math.max(object.LocalTransparencyModifier,STIRLAX_CFG.worldFade.amount)
    end
end

local function StirlaxSetWorldFade(on)
    if stWorldConnection then
        SafeDisconnect(stWorldConnection)
        stWorldConnection=nil
    end

    STIRLAX_CFG.worldFade.enabled=on and true or false
    if on then
        for _,object in ipairs(workspace:GetDescendants()) do
            StirlaxApplyFade(object)
        end
        stWorldConnection=workspace.DescendantAdded:Connect(StirlaxApplyFade)
        StirlaxStatus("world fade activo",C.green)
    else
        for object,transparency in pairs(stWorldParts) do
            if object and object.Parent then
                object.LocalTransparencyModifier=transparency
            end
        end
        table.clear(stWorldParts)
        StirlaxStatus("world fade restaurado",C.gray)
    end
end

local function StirlaxSetToolAssist(on)
    if stToolConnection then
        SafeDisconnect(stToolConnection)
        stToolConnection=nil
    end

    STIRLAX_CFG.tool.enabled=on and true or false
    if on then
        stToolConnection=RunService.RenderStepped:Connect(function()
            local ok,err=pcall(function()
            local character=LP.Character
            local tool=character and character:FindFirstChildOfClass("Tool")
            if tool and (tool:GetAttribute("STIRLAXToolAssist")==true or tool:GetAttribute("FXRapidFire")==true)
                and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local now=os.clock()
                if now-stToolLast>=STIRLAX_CFG.tool.cooldown then
                    stToolLast=now
                    pcall(function() tool:Activate() end)
                end
            end
            end)
            if not ok then
                warn("[09] Tool Assist STIRLAX pausado en este frame: "..tostring(err))
            end
        end)
        StirlaxStatus("tool assist activo · solo herramientas autorizadas",C.green)
    else
        StirlaxStatus("tool assist apagado",C.gray)
    end
end

local function StirlaxSavePreset()
    stSavedPreset={
        esp={enabled=STIRLAX_CFG.esp.enabled,boxes=STIRLAX_CFG.esp.boxes,corners=STIRLAX_CFG.esp.corners,names=STIRLAX_CFG.esp.names,distance=STIRLAX_CFG.esp.distance,health=STIRLAX_CFG.esp.health,tracers=STIRLAX_CFG.esp.tracers,arrows=STIRLAX_CFG.esp.arrows,range=STIRLAX_CFG.esp.range},
        aim={enabled=STIRLAX_CFG.aim.enabled,alwaysOn=STIRLAX_CFG.aim.alwaysOn,showFov=STIRLAX_CFG.aim.showFov,wall=STIRLAX_CFG.aim.wall,fov=STIRLAX_CFG.aim.fov,strength=STIRLAX_CFG.aim.strength,bone=STIRLAX_CFG.aim.bone},
        fly={speed=STIRLAX_CFG.fly.speed,vertical=STIRLAX_CFG.fly.vertical},
        worldFade={enabled=STIRLAX_CFG.worldFade.enabled,amount=STIRLAX_CFG.worldFade.amount},
        tool={enabled=STIRLAX_CFG.tool.enabled,cooldown=STIRLAX_CFG.tool.cooldown}
    }
    StirlaxStatus("preset guardado en esta sesión",C.gold)
end

local function StirlaxLoadPreset()
    if not stSavedPreset then
        StirlaxStatus("no hay preset guardado",C.red)
        return
    end

    for section,data in pairs(stSavedPreset) do
        for key,value in pairs(data) do
            STIRLAX_CFG[section][key]=value
        end
    end

    StirlaxUpdateFov()
    StirlaxSetWorldFade(STIRLAX_CFG.worldFade.enabled)
    StirlaxSetToolAssist(STIRLAX_CFG.tool.enabled)
    if not STIRLAX_CFG.fly.enabled then
        StirlaxStopFly()
    end
    StirlaxStatus("preset cargado; revisa los interruptores visuales",C.gold)
end

StirlaxCleanup=function()
    StirlaxStopFly()
    StirlaxSetWorldFade(false)
    StirlaxSetToolAssist(false)
    StirlaxSetMarker(nil)
    STIRLAX_FOV.Visible=false
    pcall(function() RunService:UnbindFromRenderStep("09StirlaxStep") end)
    for model,entry in pairs(stEspEntries) do
        StirlaxDestroyEsp(entry)
        stEspEntries[model]=nil
    end
end

pcall(function() RunService:UnbindFromRenderStep("09StirlaxStep") end)
pcall(function()
    RunService:BindToRenderStep("09StirlaxStep",Enum.RenderPriority.Camera.Value+3,function()
        local ok,err=pcall(function()
            StirlaxEspStep()
            StirlaxAimStep()
        end)
        if not ok then
            warn("[09] Motor STIRLAX pausado en este frame: "..tostring(err))
        end
    end)
end)

local StirlaxContent=Content(Pages.STIRLAX,392,54,66)
local stOrder=0
local function ST()
    stOrder+=1
    return stOrder
end
local stControls={}

stControls.esp=MakeToggle(StirlaxContent,ST(),"STIRLAX ESP MOTOR",false,function(v)
    STIRLAX_CFG.esp.enabled=v
end)
MakeToggle(StirlaxContent,ST(),"CAJAS PREMIUM",true,function(v)
    STIRLAX_CFG.esp.boxes=v
end)
MakeToggle(StirlaxContent,ST(),"ESQUINAS DE CAJA",true,function(v)
    STIRLAX_CFG.esp.corners=v
end)
MakeToggle(StirlaxContent,ST(),"NOMBRES Y DISTANCIA",true,function(v)
    STIRLAX_CFG.esp.names=v
    STIRLAX_CFG.esp.distance=v
end)
MakeToggle(StirlaxContent,ST(),"BARRA DE VIDA PROPORCIONAL",true,function(v)
    STIRLAX_CFG.esp.health=v
end)
MakeToggle(StirlaxContent,ST(),"TRAZADORES STIRLAX",false,function(v)
    STIRLAX_CFG.esp.tracers=v
end)
MakeToggle(StirlaxContent,ST(),"FLECHAS FUERA DE PANTALLA",true,function(v)
    STIRLAX_CFG.esp.arrows=v
end)
MakeToggle(StirlaxContent,ST(),"WALL CHECK ESP",false,function(v)
    STIRLAX_CFG.esp.wall=v
end)
MakeToggle(StirlaxContent,ST(),"COLOR DE VIDA",true,function(v)
    STIRLAX_CFG.esp.hpColor=v
end)
MakeSlider(StirlaxContent,ST(),"RANGO ESP STIRLAX",50,3000,STIRLAX_CFG.esp.range,0," studs",function(v)
    STIRLAX_CFG.esp.range=v
end)
MakeSlider(StirlaxContent,ST(),"GROSOR DE LINEA",1,4,STIRLAX_CFG.esp.thickness,1," px",function(v)
    STIRLAX_CFG.esp.thickness=v
end)
MakeSelector(StirlaxContent,ST(),"TIPO DE CAJA",{
    {"ESQUINAS","Corners"},
    {"COMPLETA","Full"}
},1,function(v)
    STIRLAX_CFG.esp.corners=v=="Corners"
end)

stControls.aim=MakeToggle(StirlaxContent,ST(),"STIRLAX AIM ASSIST",false,function(v)
    STIRLAX_CFG.aim.enabled=v
    StirlaxUpdateFov()
end)
MakeToggle(StirlaxContent,ST(),"AIM SIEMPRE ACTIVO",false,function(v)
    STIRLAX_CFG.aim.alwaysOn=v
end)
MakeToggle(StirlaxContent,ST(),"MOSTRAR FOV STIRLAX",true,function(v)
    STIRLAX_CFG.aim.showFov=v
    StirlaxUpdateFov()
end)
MakeToggle(StirlaxContent,ST(),"MARCADOR DEL OBJETIVO",true,function(v)
    STIRLAX_CFG.aim.showMarker=v
end)
MakeToggle(StirlaxContent,ST(),"WALL CHECK AIM",false,function(v)
    STIRLAX_CFG.aim.wall=v
end)
MakeSlider(StirlaxContent,ST(),"AIM FOV STIRLAX",20,500,STIRLAX_CFG.aim.fov,0," px",function(v)
    STIRLAX_CFG.aim.fov=v
    StirlaxUpdateFov()
end)
MakeSlider(StirlaxContent,ST(),"RESPUESTA AIM",.02,1,STIRLAX_CFG.aim.strength,2,"",function(v)
    STIRLAX_CFG.aim.strength=v
end)
MakeSlider(StirlaxContent,ST(),"RANGO AIM STIRLAX",50,1500,STIRLAX_CFG.aim.range,0," studs",function(v)
    STIRLAX_CFG.aim.range=v
end)
MakeSelector(StirlaxContent,ST(),"HUESO AIM",{
    {"CABEZA","Head"},
    {"CUELLO","Neck"},
    {"PECHO","Chest"},
    {"CADERA","Hip"}
},1,function(v)
    STIRLAX_CFG.aim.bone=v
end)
MakeSelector(StirlaxContent,ST(),"PRIORIDAD AIM",{
    {"CENTRO","Center"},
    {"DISTANCIA","Distance"}
},1,function(v)
    STIRLAX_CFG.aim.priority=v
end)

local stFlyToggle=MakeToggle(StirlaxContent,ST(),"STIRLAX FLY ESTABLE",false,function(v)
    if v then
        StirlaxSetFly(true)
    else
        StirlaxSetFly(false)
    end
end)
stControls.fly=stFlyToggle
MakeSlider(StirlaxContent,ST(),"VELOCIDAD FLY STIRLAX",30,220,STIRLAX_CFG.fly.speed,0," u/s",function(v)
    STIRLAX_CFG.fly.speed=v
end)
MakeSlider(StirlaxContent,ST(),"VELOCIDAD VERTICAL",20,160,STIRLAX_CFG.fly.vertical,0," u/s",function(v)
    STIRLAX_CFG.fly.vertical=v
end)

MakeToggle(StirlaxContent,ST(),"STIRLAX WORLD FADE",false,function(v)
    StirlaxSetWorldFade(v)
end)
MakeSlider(StirlaxContent,ST(),"INTENSIDAD WORLD FADE",10,90,STIRLAX_CFG.worldFade.amount*100,0,"%",function(v)
    STIRLAX_CFG.worldFade.amount=v/100
    if STIRLAX_CFG.worldFade.enabled then
        StirlaxSetWorldFade(true)
    end
end)
MakeToggle(StirlaxContent,ST(),"STIRLAX TOOL ASSIST",false,function(v)
    StirlaxSetToolAssist(v)
end)
MakeSlider(StirlaxContent,ST(),"COOLDOWN TOOL ASSIST",1,30,STIRLAX_CFG.tool.cooldown*100,0," x10 ms",function(v)
    STIRLAX_CFG.tool.cooldown=v/1000
end)
MakeButton(StirlaxContent,ST(),"GUARDAR PRESET STIRLAX",StirlaxSavePreset)
MakeButton(StirlaxContent,ST(),"CARGAR PRESET STIRLAX",StirlaxLoadPreset)

StirlaxUpdateFov()
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


local MiscContent=Content(Pages.MISC,392,54,66)
local mo=0

local function M()
    mo=mo+1
    return mo
end

local strengthSlider

MakeToggle(MiscContent,M(),"AIM",false,function(v)
    aimOn=v
    UpdateFov()
end)

MakeToggle(MiscContent,M(),"MARCADOR AIM",true,function(v)
    showMarker=v
end)

MakeToggle(MiscContent,M(),"MOSTRAR CIRCULO FOV",true,function(v)
    showFov=v
    UpdateFov()
end)

MakeSlider(MiscContent,M(),"AIM FOV",20,600,AIM_FOV,0," px",function(v)
    AIM_FOV=v
    UpdateFov()
end)

MakeSlider(MiscContent,M(),"AIM RANGO",50,1000,AIM_RANGE,0," studs",function(v)
    AIM_RANGE=v
end)

MakeSelector(MiscContent,M(),"MODO DE AIM",{
    {"LEGIT (SUAVE)",.06},
    {"MEDIO",.25},
    {"RAPIDO",.8}
},1,function(v)
    AIM_STRENGTH=v

    if strengthSlider then
        strengthSlider.Set(v,true)
    end
end)

MakeSelector(MiscContent,M(),"OBJETIVO",{
    {"CABEZA","Head"},
    {"CUELLO","Neck"},
    {"PECHO","Chest"}
},1,function(v)
    AIM_PART=v
end)

strengthSlider=MakeSlider(MiscContent,M(),"AIM FUERZA",.02,1,AIM_STRENGTH,2,"",function(v)
    AIM_STRENGTH=v
end)

MakeToggle(MiscContent,M(),"SPEED",false,function(v)
    speedOn=v
end)

MakeSlider(MiscContent,M(),"VELOCIDAD",16,200,speedVal,0,"",function(v)
    speedVal=v
end)

MakeToggle(MiscContent,M(),"FLY (WASD + ESPACIO/SHIFT)",false,function(v)
    flyOn=v
end)

MakeSlider(MiscContent,M(),"VELOCIDAD DE FLY",20,300,flySpeed,0,"",function(v)
    flySpeed=v
end)

MakeToggle(MiscContent,M(),"NOCLIP",false,function(v)
    noclipOn=v
end)

MakeToggle(MiscContent,M(),"SALTO INFINITO",false,function(v)
    infJump=v
end)

MakeToggle(MiscContent,M(),"SALTO ALTO",false,function(v)
    jumpOn=v
end)

MakeSlider(MiscContent,M(),"POTENCIA DE SALTO",50,300,jumpVal,0,"",function(v)
    jumpVal=v
end)

MakeToggle(MiscContent,M(),"GRAVEDAD PERSONALIZADA",false,function(v)
    gravityOn=v
    ApplyGravity()
end)

MakeSlider(MiscContent,M(),"GRAVEDAD",20,400,gravityVal,0,"",function(v)
    gravityVal=v
    ApplyGravity()
end)

MakeToggle(MiscContent,M(),"CAMARA FOV",false,function(v)
    camFovOn=v
end)

MakeSlider(MiscContent,M(),"CAMARA FOV VALOR",30,120,camFovVal,0,"°",function(v)
    camFovVal=v
end)

MakeToggle(MiscContent,M(),"ZOOM LIBRE",false,function(v)
    zoomOn=v
    ApplyZoom()
end)

MakeToggle(MiscContent,M(),"GIRAR PERSONAJE",false,function(v)
    spinOn=v
end)

MakeSlider(MiscContent,M(),"VELOCIDAD DE GIRO",30,1440,spinSpeed,0,"°/s",function(v)
    spinSpeed=v
end)

MakeToggle(MiscContent,M(),"ANTI AFK",false,function(v)
    antiAfk=v
end)

MakeToggle(MiscContent,M(),"CLICK TP (CTRL + CLIC)",false,function(v)
    clickTp=v
end)

MakeButton(MiscContent,M(),"TP AL OBJETIVO CERCANO",TpTarget)

MakeButton(MiscContent,M(),"REINICIAR PERSONAJE",ResetChar)


local EspContent=Content(Pages.ESP,392,54,66)
local eo=0

local function E()
    eo=eo+1
    return eo
end

MakeToggle(EspContent,E(),"CAJAS",false,function(v)
    espCfg.boxes=v
end)

MakeToggle(EspContent,E(),"NOMBRES",false,function(v)
    espCfg.names=v
end)

MakeToggle(EspContent,E(),"DISTANCIA",false,function(v)
    espCfg.dist=v
end)

MakeToggle(EspContent,E(),"BARRA DE VIDA",false,function(v)
    espCfg.health=v
end)

MakeToggle(EspContent,E(),"TRAZADORES",false,function(v)
    espCfg.tracers=v
end)

MakeToggle(EspContent,E(),"COLOR SEGUN VIDA",true,function(v)
    espCfg.hpColor=v
end)

MakeSlider(EspContent,E(),"RANGO DEL ESP",50,2000,espCfg.range,0," studs",function(v)
    espCfg.range=v
end)

MakeToggle(EspContent,E(),"X-RAY",false,function(v)
    xrayOn=v
    SyncHL()
end)

MakeSlider(EspContent,E(),"X-RAY RELLENO",0,1,xrayFill,2,"",function(v)
    xrayFill=v
    SyncHL()
end)

MakeToggle(EspContent,E(),"HIGHLIGHT AUTORIZADOS",false,function(v)
    hlOn=v
    SyncHL()
end)

MakeToggle(EspContent,E(),"FULLBRIGHT",false,function(v)
    full=v
    ApplyLighting()
end)

MakeToggle(EspContent,E(),"SIN NIEBLA",false,function(v)
    noFog=v
    ApplyLighting()
end)

MakeToggle(EspContent,E(),"SIN SOMBRAS",false,function(v)
    noShadows=v
    ApplyLighting()
end)

MakeToggle(EspContent,E(),"HORA FIJA",false,function(v)
    hourOn=v
    ApplyLighting()
end)

MakeSlider(EspContent,E(),"HORA DEL DIA",0,24,hourVal,1,"h",function(v)
    hourVal=v
    ApplyLighting()
end)


local SkinPage=Pages.SKINS

MakeToggle(
    SkinPage,
    0,
    "APLICAR SKIN A MI PERSONAJE",
    true,
    function(v)
        ownSkinOn=v
        ApplyOwn()
    end,
    UDim2.fromOffset(20,66)
)

local SkinGrid=Content(SkinPage,190,46,130)
local skinCards={}

local function SelectSkin(key)
    skin=key

    for k,c in pairs(skinCards) do
        local sel=k==key

        c.stroke.Thickness=sel and 2 or 1
        c.stroke.Transparency=sel and 0 or .75
        c.stroke.Color=sel and C.white or C.blue
    end

    ApplySkin()
end

for i,s in ipairs(SKIN_LIST) do
    local key,label=s[1],s[2]

    local btn=N("TextButton",{
        Text="",
        AutoButtonColor=false,
        BackgroundColor3=C.card,
        BorderSizePixel=0,
        LayoutOrder=i,
        Parent=SkinGrid
    })

    R(btn,12)

    local stroke=N("UIStroke",{
        Color=C.blue,
        Thickness=1,
        Transparency=.75,
        Parent=btn
    })

    local swatch=N("Frame",{
        Size=UDim2.fromOffset(24,24),
        Position=UDim2.new(0,12,.5,-12),
        BackgroundColor3=AMONG[key]
            or (key=="neon" and NEON_COLOR)
            or (key=="freefire" and FF_ORANGE)
            or C.gray,
        BorderSizePixel=0,
        Parent=btn
    })

    R(swatch,12)

    T(
        btn,
        label,
        UDim2.new(1,-54,1,0),
        UDim2.fromOffset(46,0),
        11,
        C.white,
        Enum.Font.GothamBold
    )

    btn.Activated:Connect(function()
        SelectSkin(key)
    end)

    skinCards[key]={stroke=stroke}
end


local function Page(name)
    local peopleActive=name=="PEOPLE"
    People.Visible=peopleActive
    People.Active=peopleActive

    for pageName,page in pairs(Pages) do
        local active=pageName==name
        page.Visible=active
        page.Active=active
        page.ZIndex=active and 10 or 1
    end

    for tabName,tab in pairs(tabs) do
        tab.BackgroundColor3=
            tabName==name and C.hover or C.card
    end
end

for name,tab in pairs(tabs) do
    tab.Activated:Connect(function()
        Page(name)
    end)
end


Track(UIS.InputBegan:Connect(function(input,gp)
    if input.UserInputType~=Enum.UserInputType.Keyboard then
        return
    end

    local k=input.KeyCode

    if listening then
        local t=listening
        listening=nil

        if k==Enum.KeyCode.Escape or k==Enum.KeyCode.Backspace then
            t.SetKey(nil)
        elseif k~=Enum.KeyCode.RightShift
            and k~=Enum.KeyCode.Unknown then

            for _,o in ipairs(Toggles) do
                if o.Key==k then
                    o.SetKey(nil)
                end
            end

            t.SetKey(k)
        else
            t.SetKey(t.Key)
        end

        return
    end

    if gp then
        return
    end

    if k==Enum.KeyCode.RightShift then
        SetMenuOpen(not menuOpen)
        return
    end

    for _,o in ipairs(Toggles) do
        if o.Key==k then
            o.Trigger()
        end
    end
end))


View.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        drag=true
        last=input.Position
    end
end)

View.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        drag=false
        last=nil
    end
end)

View.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseWheel then
        distance=math.clamp(
            distance-input.Position.Z*.7,
            4.5,
            12
        )

        Cam()
    end
end)

Track(UIS.InputChanged:Connect(function(input)
    if drag
        and last
        and (
            input.UserInputType==Enum.UserInputType.MouseMovement
            or input.UserInputType==Enum.UserInputType.Touch
        ) then

        local delta=input.Position-last

        last=input.Position
        yaw=yaw+delta.X*.012
        pitch=math.clamp(
            pitch+delta.Y*.006,
            -.75,
            .75
        )

        if Model then
            Model:PivotTo(
                CFrame.new(0,BaseY,0)
                * CFrame.Angles(pitch,yaw,0)
            )

            Cam()
        end
    end
end))

Track(Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if player==Selected and player~=LP then
            task.wait(.5)
            Show(player)
        end
    end)

    Update()
end))

Track(Players.PlayerRemoving:Connect(function(player)
    if player==Selected then
        Show(LP)
    end

    Update()
end))

Track(LP.CharacterAdded:Connect(function()
    table.clear(ownStore)
    table.clear(ncStore)
    origSpeed=nil
    origJump=nil
    flyActive=false

    task.wait(.5)

    ApplyOwn()

    if Selected==LP then
        Show(LP)
    end
end))


Gui.Destroying:Connect(function()
    menuOpen=false
    menuBusy=false
    for _,c in ipairs(conns) do
        SafeDisconnect(c)
    end

    pcall(function()
        RunService:UnbindFromRenderStep("09Step")
        RunService:UnbindFromRenderStep("09EspStep")
    end)

    aimOn=false
    SetMarker(nil)

    for _,store in ipairs({xrayStore,hlStore}) do
        for _,h in pairs(store) do
            h:Destroy()
        end
    end

    full=false
    noFog=false
    noShadows=false
    hourOn=false
    ApplyLighting()

    gravityOn=false
    ApplyGravity()

    zoomOn=false
    ApplyZoom()

    local cam=workspace.CurrentCamera

    if cam and camFovActive then
        cam.FieldOfView=origFov
    end

    speedOn=false
    ApplySpeed()

    jumpOn=false
    ApplyJump()

    flyOn=false
    DoFly()

    for part in pairs(ncStore) do
        if part.Parent then
            part.CanCollide=true
        end
    end

    Restore(ownStore)
    StirlaxCleanup()
end)

kill.Activated:Connect(function()
    Gui:Destroy()
end)


SafeCallback("inicio: página",function()
    Page("PEOPLE")
end)
SafeCallback("inicio: perfil",function()
    Show(LP)
end)
SafeCallback("inicio: lista",function()
    Update()
end)
SafeCallback("inicio: skin",function()
    SelectSkin("normal")
end)
SafeCallback("inicio: fov",function()
    UpdateFov()
end)
