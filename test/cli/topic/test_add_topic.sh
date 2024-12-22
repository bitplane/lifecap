lifecap topic add test-topic

find $test_tempdir*

__assert "$(lifecap topic ls)" "=" "test-topic"
