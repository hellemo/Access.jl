# Access

WIP: Query MS Access files via [JDBC](https://github.com/JuliaDatabases/JDBC.jl) and [UCanAccess](http://ucanaccess.sourceforge.net).

## Example

```
using Access

fn = "C:\\temp\\TestDatabase.accdb"
df = Access.querydb(fn,"SELECT * FROM Person WHERE BirthYear > 1980")
```

