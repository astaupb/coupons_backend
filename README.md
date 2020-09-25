# coupons_backend

## Dependencies

- Postgresql >=9.8

## Generate Database Layout

Create the asta_coupon database with the following command:
```
sudo -u postgres psql -f sql/create_db.sql
```

Let aqueduct generate the first database migration:
```
aqueduct db generate
```

Apply the generated models to database:
```
aqueduct db upgrade --connect postgres://asta_coupon_user:test_password@localhost:5432/asta_coupon
```

Database credentials should be placed inside config.yaml

## Running the Application Locally

Run `aqueduct serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run `aqueduct document client`.

## Running Application Tests

To run all tests for this application, run the following in this directory:

```
pub run test
```

The default configuration file used when testing is `config.src.yaml`. This file should be checked into version control. It also the template for configuration files used in deployment.

ToDo: Add tests