ANlib = {}

function ANlib.Benchmark(func, ...)

    MsgC(Color(255,0,255), "[ANlib] ", Color(255,255,255), "Benchmarking function ", Color(255,255,255),"on ", CLIENT and Color(255, 255, 0) or Color(0, 238, 255), CLIENT and "client" or "server", Color(255,255,255), "-side...\n")

    local time = SysTime()

    func(unpack({...}))

    local endtime = SysTime()
    local total = string.sub(tostring((endtime - time) * 1000), 1, 5)

    MsgC(Color(255,0,255), "[ANlib] ", Color(255,255,255), "Time taken: ", Color(255,255,0), total .. " miliseconds\n")

end