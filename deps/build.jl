using Pkg.Artifacts
using ZipFile

""" unzip(file,exdir)
    From https://discourse.julialang.org/t/how-to-extract-a-file-in-a-zip-archive-without-using-os-specific-tools/34585/5?u=hellemo
"""
function unzip(file, exdir="")
    fileFullPath = isabspath(file) ? file : joinpath(pwd(), file)
    basePath = dirname(fileFullPath)
    outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(), exdir)))
    isdir(outPath) ? "" : mkdir(outPath)
    zarchive = ZipFile.Reader(fileFullPath)
    for f in zarchive.files
        fullFilePath = joinpath(outPath, f.name)
        if (endswith(f.name, "/") || endswith(f.name, "\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    return close(zarchive)
end

artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
ucanaccess_hash = artifact_hash("ucanaccess", artifact_toml)

# Download and unzip to Artifact if not already existing
if ucanaccess_hash === nothing || !artifact_exists(ucanaccess_hash)
    ucanaccess_hash = create_artifact() do artifact_dir
        tmp_file = download("https://sourceforge.net/projects/ucanaccess/files/UCanAccess-5.0.0-bin.zip/download")
        unzip(tmp_file, artifact_dir) # Unpack to artifact_dir
    end
    bind_artifact!(artifact_toml, "ucanaccess", ucanaccess_hash; force=true)
end
