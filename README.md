# coupons_backend

Backend used in production since 2020!

## Dependencies

- Postgresql >=9.8
- Dart 2.8.4-1
- aqueduct 4.0.0-b1 
(analyzer is breaking compiling as of 03.02.2021. Use https://github.com/igotyou/aqueduct/ 
than activate with ```pub global activate --source path ./aqueduct```)

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

Standard keys to be used in data for the properties columns (of for example vendor table) are documented in properties.md

## Running the Application Locally

Run `aqueduct serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run `aqueduct document client`.

## Running in production

A systemd service template can be found under scripts for production deployment. There is also a script to create OAuth testclients and a keygen to insert new coupon codes.

## API-Endpoints
All routes are described in openapi.json . Not all responses are correctly described!
