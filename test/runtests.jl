using Test
using Access

fn = cp(joinpath(@__DIR__,"TestDatabase.accdb"),joinpath(mktempdir(;cleanup=false),"Test.accdb"))

@testset "Read data from db" begin
   
# fn = joinpath(@__DIR__,"TestDatabase.accdb")
@test isfile(fn)
df = Access.query(fn,"SELECT * FROM Person WHERE BirthYear > 1980")   

@test size(df,1) == 1 # One Row
@test df.FirstName[1] == "Slim"
@test df.LastName[1] == "Shady"
@test df.ID[1] == 3
end



@testset "Modify db data" begin

# Read table content to DataFrame
StoredValues = Access.query(fn,"SELECT * FROM StoredValues;");

# Delete everything in table
Access.query!(fn,"DELETE * FROM StoredValues;")

# Check table empty?
shouldbeemtpy = Access.query(fn,"SELECT * FROM StoredValues;");
@test size(shouldbeemtpy,1) == 0

# Re-insert data from DataFrame
Access.@insertdf(fn,StoredValues)
shouldnotbeemtpy = Access.query(fn,"SELECT * FROM StoredValues;");
@test size(shouldnotbeemtpy,1) > 0

# Check table content
@test shouldnotbeemtpy[6,4] == "Mashall Mathers"
@test shouldnotbeemtpy[2,3] ≈ 3.3

# Alternatively, specify table explicitly:
Access.query!(fn,"DELETE * FROM StoredValues;")
Access.insertdf(fn,StoredValues,"StoredValues")
shouldnotbeemtpy = Access.query(fn,"SELECT * FROM StoredValues;");
@test shouldnotbeemtpy[2,3] ≈ 3.3
end

# TODO: Figure out why this (and cleanup) fails
# rm(dirname(fn);recursive=true)
