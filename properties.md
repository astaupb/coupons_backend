# List of Property Keys

| Key           | Value                                                         | Scope                 |
|---------------|---------------------------------------------------------------|-----------------------|
| address       | Street and number (eg 'Westernstraße 4')                      | Store                 |
| city          | City and zip code (eg '33098 Paderborn)                       | Store                 |
| image         | Promotional image in base64 encoding                          | Vendor, Store         |
| image_uid     | Promotional image uid under assets/                           | Vendor, Store         |
| logo          | Logo image in base64 encoding                                 | Vendor                |
| logo_uid      | Logo image uid under assets/                                  | Vendor                |
| description   | Short text describing the object                              | Vendor, Store, Coupon |
| telephone     | Telephone number in text format                               | Vendor, Store         |
| latlng        | Comma-seperated latitude longitude values (eg. '51.706,8.745')| Vendor, Store         |
| code          | Optional permanent code string                                | Coupon                |
| product       | product image for display on vendor page                      | Vendor                |
| product_uid   | product uid under assets/ for display on vendor page          | Vendor                |
| website       | URL of vendor's website                                       | Vendor                | 
| disabled      | boolean flag to hide vendor in client list                    | Vendor                | 
| email         | email adress for vendor or specific store                     | Vendor, Store         | 
| hours         | opening hours of a store                                      | Store                 | 
