#!/usr/bin/env bats

@test "verify service status" {
    /etc/init.d/pgbouncer status 
}
