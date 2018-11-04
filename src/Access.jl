module Access

using JavaCall
using JDBC, DataFrames

function __init__()

    libs = ["commons-lang-2.6.jar","commons-logging-1.1.3.jar","hsqldb.jar","jackcess-2.1.11.jar"]
    for l in libs
        fn = joinpath(@__DIR__,"..","UCanAccess","lib",l)
        JavaCall.addClassPath(fn)
    end
    
    fn = joinpath(@__DIR__,"..","UCanAccess","ucanaccess-4.0.4.jar")
    fn = replace(fn,"\\" => "/")
    
    JDBC.usedriver(joinpath(@__DIR__,"..","UCanAccess","ucanaccess-4.0.4.jar"))
    JDBC.init()
    
    return nothing
end
    

function querydb(fn,qstr)
    fn = replace(fn,"\\" => "/")    
    df = JDBC.load(DataFrame,cursor("jdbc:ucanaccess://$fn"), qstr)
    return df
end




end # module
