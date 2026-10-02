local URL="https://raw.githubusercontent.com/arthurns6666-ctrl/stirlax-09/c3fc0f19795fc3f100ca30196f36111aa024ba4c/STIRLAX_09_REMOTE.lua"

local function report(message)
    if type(warn)=="function" then
        warn("[STIRLAX] "..tostring(message))
    else
        print("[STIRLAX] "..tostring(message))
    end
end

local function fetch()
    local ok,body=pcall(function()
        return game:HttpGet(URL)
    end)

    if ok and type(body)=="string" and #body>0 then
        return body
    end

    local environment=(type(getgenv)=="function" and getgenv()) or _G
    local requestFunction=environment and (environment.request or environment.http_request)
    if not requestFunction and environment and environment.syn then
        requestFunction=environment.syn.request
    end

    if type(requestFunction)=="function" then
        local response=requestFunction({
            Url=URL,
            Method="GET"
        })
        if type(response)=="table" and type(response.Body)=="string" and #response.Body>0 then
            return response.Body
        end
    end

    error("no se pudo descargar la fuente remota")
end

local ok,source=pcall(fetch)
if not ok then
    report(source)
    return
end

local compiler=loadstring or load
if type(compiler)~="function" then
    report("este executor no expone loadstring ni load")
    return
end

local compiled,chunk=pcall(compiler,source,"STIRLAX_09_REMOTE.lua")
if not compiled or type(chunk)~="function" then
    compiled,chunk=pcall(compiler,source)
end

if not compiled or type(chunk)~="function" then
    report(chunk or "la fuente remota no pudo compilarse")
    return
end

local executed,err=pcall(chunk)
if not executed then
    report(err)
    return
end

print("[STIRLAX] fuente remota ejecutada")
