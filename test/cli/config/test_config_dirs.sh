
res=$(lifecap config | grep $test_tempdir | wc -l)

__assert "$res" -eq "3"

