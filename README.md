# Access

Query MS Access files via [JDBC](https://github.com/JuliaDatabases/JDBC.jl) and [UCanAccess](http://ucanaccess.sourceforge.net).

## Example

Read data from Access database

```julia
using Access

fn = "C:\\temp\\TestDatabase.accdb"
df = Access.query(fn,"SELECT * FROM Person WHERE BirthYear > 1980")
```

Modify data in Access database

```julia
# Read table content to DataFrame
StoredValues = Access.query(fn,"SELECT * FROM StoredValues;");

# Delete everything in table
Access.query!(fn,"DELETE * FROM StoredValues;")

# Re-insert data from DataFrame (inserting into table with same name as DataFrame)
Access.@insertdf(fn,StoredValues)

# Alternatively, specify table explicitly:
Access.insertdf(fn,StoredValues,"StoredValues")

```