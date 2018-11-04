# Access

WIP: Query MS Access files via JDBC and UCanAccess.

## Example

´´´
using Access

fn = "C:\\temp\\TestDatabase.accdb"
df = Access.querydb(fn,"SELECT * FROM Person WHERE BirthYear > 1980")
´´´

