module Access

using DataFrames
using JavaCall
using JDBC
using Pkg.Artifacts

function __init__()
    basepath = joinpath(artifact"ucanaccess", "UCanAccess-5.0.0-bin")

    libs = [
        "commons-lang3-3.8.1.jar",
        "commons-logging-1.2.jar",
        "hsqldb-2.5.0.jar",
        "jackcess-3.0.1.jar",
    ]

    for l in libs
        fn = joinpath(basepath, "lib", l)
        JavaCall.addClassPath(fn)
    end

    fn = joinpath(basepath, "ucanaccess-5.0.0.jar")

    JDBC.usedriver(joinpath(basepath, "ucanaccess-5.0.0.jar"))
    JDBC.init()

    return nothing
end

function filecursor(fn; immediaterelease=false, noinactivitytimeout=false)
    fn = replace(fn, "\\" => "/")
    timeout = ""
    if noinactivitytimeout
        timeout = ";inactivityTimeout=0"
    end

    return cursor("jdbc:ucanaccess://$fn;immediatelyReleaseResources=$(string(immediaterelease))$(timeout)")
end

function query(fn, qstr; imrelease=false, notimeout=true)
    fn = replace(fn, "\\" => "/")
    df = JDBC.load(
        DataFrame,
        filecursor(fn; immediaterelease=imrelease, noinactivitytimeout=notimeout),
        qstr,
    )
    return df
end

# TODO Quote strings
function createInsert(df, tablename)
    function qstring(s)
        return s
    end
    function qstring(s::String)
        return "\"" * s * "\""
    end
    function qkey(s)
        return "[" * string(s) * "]"
    end

    ns = names(df)
    SQLquery = String[]
    for r in eachrow(df)
        keys = join((qkey(n) for n in ns), ", ")
        vals = join((qstring(r[n]) for n in ns), ", ")
        push!(SQLquery, "INSERT INTO $tablename ($keys) VALUES ($vals);")
    end
    return SQLquery
end

function query!(fn, SQLQuery; imrelease=false, notimeout=false)
    csr = filecursor(fn; immediaterelease=imrelease, noinactivitytimeout=notimeout)
    return execute!(csr, SQLQuery)
end

# Insert all rows from a DataFrame into table"
function insertdf(fn, df::DataFrame, tablename::String; imrelease=false, notimeout=true)
    csr = filecursor(fn; immediaterelease=imrelease, noinactivitytimeout=notimeout)
    ns = names(df)
    SQLquery = createInsert(df, tablename)
    for q in SQLquery
        execute!(csr, q)
    end
end

# Insert all rows from a DataFram into table with same name as DataFrame
macro insertdf(fn, df)
    return quote
        tn = $(string(df))
        insertdf($(esc(fn)), $(esc(df)), tn)
    end
end

end # module
