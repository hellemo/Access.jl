using Downloads
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

const UCANACCESS_VERSION = "5.2.0"
const UCANACCESS_JAR = "ucanaccess-$(UCANACCESS_VERSION)-uber.jar"

artifact_toml = realpath(joinpath(@__DIR__, "..", "Artifacts.toml"))
chmod(artifact_toml, 0o644)
ucanaccess_hash = artifact_hash("ucanaccess", artifact_toml)

# Download and unzip to Artifact if not already existing (or bound to another version)
if ucanaccess_hash === nothing ||
    !artifact_exists(ucanaccess_hash) ||
    !isfile(joinpath(artifact_path(ucanaccess_hash), UCANACCESS_JAR))
    ucanaccess_hash = create_artifact() do artifact_dir
        tmp_file = Downloads.download(
            "https://repo1.maven.org/maven2/io/github/spannm/ucanaccess/$(UCANACCESS_VERSION)/ucanaccess-$(UCANACCESS_VERSION)-distrib.zip",
        )
        unzip(tmp_file, artifact_dir) # Unpack to artifact_dir
    end
    bind_artifact!(artifact_toml, "ucanaccess", ucanaccess_hash; force=true)
end
