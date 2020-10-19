#!/usr/bin/env bash

set -ex

# Create test user client
aqueduct auth add-client \
    --id test.user \
    --secret test \
    --allowed-scopes 'user coupon' \
    --connect postgres://asta_coupon_user:test_password@localhost:5432/asta_coupon 

# Create test admin client
aqueduct auth add-client \
    --id test \
    --secret test \
    --allowed-scopes 'admin user coupon' \
    --connect postgres://asta_coupon_user:test_password@localhost:5432/asta_coupon
