
### [Dynamically Viewing Columns of table ](https://github.com/egasimov/sql-scripts/blob/master/viewing/dynamically-viewing-columns.sql)
- use of DBMS_SQL package
- Determining colums of table - which is passed as argument to function.
- full text of sql scripts will be known during runtime
- Input params: view or table name
- Output params: CLOB which contains the result of query

--------------------------------------------------------

### [Query the Paginated Data ](https://github.com/egasimov/sql-scripts/tree/master/pagination)
- use of DBMS_SQL package
- Pagination of data by the predifined colums
- Input params: table name, page size, page number, sort data(column_name, sort_type)
- Output param: REF Cursor which can be consumed by other functions or client apps
- Test scripts can also be found here(https://github.com/egasimov/sql-scripts/tree/master/pagination/test)

--------------------------------------------------------
**PL/SQL | Dynamic SQL ** [Further Information](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/dynamic.htm#LNPLS011)

