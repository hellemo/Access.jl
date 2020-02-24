using Test
using Access

@testset "Read data from db" begin
   
fn = joinpath(@__DIR__,"TestDatabase.accdb")
df = Access.querydb(fn,"SELECT * FROM Person WHERE BirthYear > 1980")

@test size(df,1) == 1 # One Row
@test df.FirstName[1] == "Slim"
@test df.LastName[1] == "Shady"
@test df.ID[1] == 3
end