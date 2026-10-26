module Access

using DataFrames
using Downloads
using JavaCall
using JDBC
using Pkg.Artifacts
using ZipFile

const UCANACCESS_VERSION = "5.2.0"

function __init__()
    # The uber jar bundles UCanAccess with its dependencies (HSQLDB, Jackcess)
    jar = joinpath(artifact"ucanaccess", "ucanaccess-$(UCANACCESS_VERSION)-uber.jar")

    JDBC.usedriver(jar)
    JDBC.init()

    return nothing
end

function filecursor(fn; immediaterelease=false, noinactivitytimeout=false)
    fn = replace(fn, "\\" => "/")
    timeout = ""
    if noinactivitytimeout
        timeout = ";inactivityTimeout=0"
    end

    return cursor(
        "jdbc:ucanaccess://$fn;immediatelyReleaseResources=$(string(immediaterelease))$(timeout)",
    )
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

# Insert all rows from a DataFrames into table with same name as DataFrame
macro insertdf(fn, df)
    return quote
        tn = $(string(df))
        insertdf($(esc(fn)), $(esc(df)), tn)
    end
end

end # module
