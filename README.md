# Plataquery

## Debugging extension locally on macos
1. `brew install osquery`
1. `osqueryi`
1. `select * from osquery_extensions;`
```
osquery> select * from osquery_extensions;
+------+------+---------+-------------+---------------------------------------+------+
| uuid | name | version | sdk_version | path                                  | type |
+------+------+---------+-------------+---------------------------------------+------+
| 0    | core | 5.0.1   | 0.0.0       | /Users/testuser/.osquery/shell.em     | core |
+------+------+---------+-------------+---------------------------------------+------+
```
1. `go build -o osq-ext-s3.ext main.go`
1. `./osq-ext-s3.ext --socket /Users/testuser/.osquery/shell.em`

## References
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()