module Access

using JavaCall
using JDBC, DataFrames

function __init__()

    libs = ["commons-lang3-3.8.1.jar","commons-logging-1.2.jar","hsqldb-2.5.0.jar","jackcess-3.0.1.jar"]
    for l in libs
        fn = joinpath(@__DIR__,"..","UCanAccess","lib",l)
        JavaCall.addClassPath(fn)
    end
    
    fn = joinpath(@__DIR__,"..","UCanAccess","ucanaccess-5.0.0.jar")
    fn = replace(fn,"\\" => "/")
    
    JDBC.usedriver(joinpath(@__DIR__,"..","UCanAccess","ucanaccess-5.0.0.jar"))
    JDBC.init()
    
    return nothing
end
    

function querydb(fn,qstr)
    fn = replace(fn,"\\" => "/")    
    df = JDBC.load(DataFrame,cursor("jdbc:ucanaccess://$fn"), qstr)
    return df
end




end # module
