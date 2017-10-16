#!/bin/bash
cat > /tmp/abc << end
\$database_type = "mysql";
\$database_default = "cacti";
\$database_hostname = "localhost";
\$database_username = "cactidb";
\$database_password = "123456";
\$database_port = "3306";
\$database_ssl = false;
end

