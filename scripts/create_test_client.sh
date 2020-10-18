#!/usr/bin/env bash

set -ex

# Create test user client
aqueduct auth add-client \
    --id com.app.test.user \
    --secret mytestsecret \
    --allowed-scopes 'user coupon' \
    --connect postgres://asta_coupon_user:test_password@localhost:5432/asta_coupon 

# Create test admin client
aqueduct auth add-client \
    --id com.app.test.admin \
    --secret mytestsecretsecret \
    --allowed-scopes 'admin user coupon' \
    --connect postgres://asta_coupon_user:test_password@localhost:5432/asta_coupon
