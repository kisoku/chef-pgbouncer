#!/usr/bin/env bats

setup() {
  echo 'localhost:6432:pgbouncer_test:test:reallybadpassword' > /root/.pgpass
  chmod 600 /root/.pgpass
}

@test "connect to pgbouncer via psql" {
    psql -p 6432 -U test -tc 'SELECT pg_postmaster_start_time();' pgbouncer_test
}
