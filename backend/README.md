## Developer information

There are four REST API processes hosted on 3.145.15.144. Each process hosts a gRPC server and is connected to
a corresponding MySQL server as follows:

Name: REST API server port, MySQL port, gRPC server port
* Instance 1: port 8000, 5000, 50000
* Instance 2: port 8001, 5001, 50001
* Instance 3: port 8002, 5002, 50002
* Instance 4: port 8003, 5003, 50003

The database name is cpsc559, and the login credentials are as follows:
* username: `root`
* password: `coupons1001`

## Architecture
Each Django instance is run as a Linux service with names `django{n}`.

## Running the application
There are four settings configured for each replica. Choosing a setting can be done as follows:
`python manage.py runserver 8000 --settings=settings.instance-x`

All the setting files can be seen under the settings/ directory.

## Modifying the data model

Whenever a data model is modified, the following commands should be run:
`python manage.py makemigrations --settings=settings.instance-x`
`python manage.py migrate --settings=settings.instance-x`

In addition, verify that the table has AUTO_INCREMENT for vendor.id and coupons.id. To apply it, first log in into
the MySQL server with the command
`mysql -h 3.145.15.144 -u root -P 5000 -pcoupons1001`

Then, use the database by invoking the command
`use cpsc559;`

Tables can be viewed by typing in `show tables;`. To see the properties of a table, type in
`describe TABLENAME`

The id column for our tables should have AUTO_INCREMENT. If this is not the case, type in
`ALTER TABLE tablename CHANGE id id INT NOT NULL AUTO_INCREMENT`

