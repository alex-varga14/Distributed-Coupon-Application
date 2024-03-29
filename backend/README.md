## Developer information

There are four REST API processes hosted on 3.129.250.41. Each process hosts a gRPC server and is connected to
a corresponding MySQL server as follows:

Name: REST API server port, MySQL port, gRPC server port
* Instance 1: port 8000, 5000, 50000
* Instance 2: port 8001, 5001, 50001
* Instance 3: port 8002, 5002, 50002
* Instance 4: port 8003, 5003, 50003

The database name is cpsc559, and the login credentials are as follows:
* username: `root`
* password: `coupons1001`

The EC2 server has 8GiB of storage and 1GB of RAM.
Due to the limited RAM size, 1GB of swap memory has been allocated. In the situation where the
RAM is accidentally maxed out (noticable by having a frozen terminal and unresponsive HTTP requests), the server
must be forcefully shutdown via the AWS console and started again.

# Demo 4 Notes - Consistency and Synchronization
Our choice of passive replication and adoption of a leader algorithm results in the system maintaining consistency in almost all cases. However, there are a handful of cases that require additional mechanisms to mantain consistency.

## Cons/Sync - Event in which a replica dies
In order to recover from such a case, the mechanism below was implemented. All requests/operations forwarded from the AWS Lambda functions to any django instance on the EC2 will be logged into a file. Each operations has an associated global timestamp. The logger configuration is currently set as:
```
LOGGING = {
    'version': 1,
    'formatters': {
        'timestamp': {
            'format': '{asctime} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'timestamp',
        },
        'file': {
            'class': 'logging.FileHandler',
            'formatter': 'timestamp',
            'filename': '/home/ubuntu/Distributed-Coupon-Application/backend/backendapp/django-query.log',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
        },
    }
}
```
Each django instance stores its last executed operation on AWS Systems Manager Parameter Store For backup replicas, this value is updated each time a request is successfully propogated from leader to backups. For the leader, each time it successfully transmits a request. It is also updated when a replica reboots. This occurs when a dead replica reboots, in which it follows the procedure below:
1. Iterate through log file, determine if last executed operations is up to date or behind. If up to date skip the rest.
2. If behind, begin executing operations from the last executed timestamp till the most up-to-date.
3. Update corresponding instance's last executed operation in the Parameter store.

Within each lambda function, before the request is sent to the leader replica, there is a heartbeat check that occurs by pinging the following endpoint `GET /`. If the server responds with HTTP 200 it is alive and will receive the request, any other response and it needs a reboot.

## Issues with this approach

There are few issues with this approach:
1. All four instances operations are logged resulting in large overhead and therefore increased latency with time as well as inability to scale. Furthermore, in its current state, an issue that arises from this is that duplicate sql operations are ignored and not inserted into the table; however, these queries still trigger the auto increment property which results in gaps in id ranges when a replica reboots therefore inconsistency between row id's amongst the instances. TOFIX
2. In the case all replicas go down, there is no recovery mechanism. Also, none in the case a database goes down.

...

## Sync - Contention Over Coupon Access
In order to manage concurrent access on coupons, we use a django Redis cache to manage distributed locking across the four replicas. The Redis cache can be checked to see if a corresponding key exists when a user proceeds with redemption, if the key exists, it means the current coupon is locked and the user cannot redeem it. The Redis cache server is hosted on the EC2 instance at port 6379. To view the locking in action, one can access the servers redis cache as follows:

```
redis-cli -h 3.129.250.41
```
Once in redis console, one can view keys, ie all locked coupons, by using the following command:

```
KEYS *
```
For our system, we use the `myapp_cache:1:coupon_lock_{}` keys, where the last segment is the coupon ID. To view the key, or locked coupon, run (ex: where couponID = 1):

```
GET myapp_cache:1:coupon_lock_1
```

...

# Demo 3 Notes - Fault Tolerance

## Model
The data model returned from the election process is as follows:

```
[ProcLeader]
{
    "is_leader": <Bool>,
    "leader_host": <String>
}
```

## Re-election process
It is up to the front end to detect dead servers and perform a new leader election. A re-election can be requested
by performing a `POST /proc/leader`. This returns a ProcLeader data model containing two values:
* `is_leader` indicating whether the replica (that received the POST request) is a leader
* `leader_host` containing the host of the leader replica (in the format of `http://1.2.3.4:1234`).

## Determining the leader

To determine the leader, create a `GET /proc/leader` request to obtain a ProcLeader model. By default, if `GET /proc/leader`
is requested with no active leader, it will automatically perform leader election.


## Leader election implementation

The leader (re-)election is implemented using the Bully Algorithm.
This is implemented by creating a public endpoint `POST /proc/leader` to initiate the election with a non-public
endpoint `GET /proc/leader/<id>` to compare process IDs. The process with the highest PID will win the election.

The steps are as follows:

Assuming `P` is the replica receiving a `POST` request, `pid` is the process ID of `P`, and `o_pid` is the
process ID of other replicas (`pid` != `o_pid`), then, when `P` receives a `POST /proc/leader`,
1. Send to all replicas (other than itself) a `GET /proc/leader/<id>`, where `<id>` is the current replica's PID
2. Receive all responses with either a `True` (YES) or a `False` (NO):
    * `True` indicates that the replica **can** become a leader (`o_pid` &lt;= `pid`)
    * `False` indicates that the replica **cannot** become a leader (`o_pid` &gt; `pid`)
3. Filter the list of hosts, keeping only hosts that reject `P`'s request (in other words, we have a list of
    hosts that responded `False`
4. Two cases:
    * **Case 1** - The filtered list is empty (no server replied with `NO`): `P` is the leader and returns a ProcLeader
    model of `{"is_leader": True, "leader_host": "1.2.3.4"}`
    * **Case 2** - The filtered list is non-empty (at least one server replied with `NO`): Create a `POST /proc/leader`
    request to the first server in the filtered list and pass in the filtered list as
    a key-value pair of `{"host": "1.2.3.4,2.3.4.5,..."}`; `P` waits until this recursive call is finished, then returns
    a ProcLeader model of `{"is_leader": False, "leader_host": "2.3.4.5"}`

## Issues with this approach

There are few non-critical issues (specific to CPSC 559) with this approach:
1. Concurrent leader election: the code is not handled to receive another `POST /proc/leader` request while an election is in progress
    * Possible solution: implement a Python-equivalent C++ mutex in the function that performs the leader election.
2. O(n^2) messages: in the worst-case scenario, we will have (n-1)(n-2)(...)(2)(1) `GET /proc/leader/<pid>` requests being made.
    * Possible solution: modify the return type of `GET /proc/leader/<pid>` to also return the PID, and, instead of picking the
        first host in the filtered list, pick the host with the highest PID; ultimately, this solution will give O(n) messages.
3. O(n) active HTTP connections during (re-)election: each connection will wait for a response until all of the recursive election process
        created are complete.
    * Possible solution: by applying the solution in issue 2, the number of active connections reduces to O(1).

# Demo 2 Notes - Replication

## Setting up the application
Some Python dependencies must be installed first prior to running the application.
To install the dependencies, run
`pip install -r requirements.txt`

## Running the application
There are four settings configured for each replica. Choosing a setting can be done as follows:
`python manage.py runserver 8000 --settings=settings.instance-x`

When running on the EC2 server, make sure `--settings=settings.instance-x` is specified.
All the setting files can be seen under the settings/ directory.

When running locally, omitting the `--settings` option will default to the original config in settings.py. This
default setting has a hardcoded EC2 IP, allowing personal computers to connect to coupons-db-1 on EC2. Alternatively, `-settings=settings.local-instance-2` can
be used to connect to coupons-db-2 on EC2. This is useful when trying to test replication.

Please note that when testing locally, the databases will no longer be synchronized and will require a reset.
This can be done by running `./clear_all_db` on the EC2 server.

## Connecting to the server
Connections to the server can be made by accessing the AWS console and clicking on the "Connect" button. Password-based authentication is disabled for the server.
To be able to connect to the server without using the AWS console, an ssh
public-key must be copied into `~/.ssh/authorized_keys` in the server.

Connections to the DB can be made with the `mysql` command. This client is not bundled in the
computer by default, so it must be installed. An example usage of the command
to connect from a personal computer to the server is the following:
```
mysql -h 3.129.250.41 -u root -P 5000 -pcoupons1001
```
There are multiple DB instances. The top of the README file contains port numbers for each instance.


## Architecture
Each Django instance is run as a Linux service with names `django{n}`. Each service automatically starts a Django server with specific settings for each instance.
Docker is used to install multiple MySQL instances. TCP routing is used to route port 500x to port 3306 of each Docker instance.

## Modifying the data model

Whenever a data model is modified, the following commands should be run:
```
python manage.py makemigrations --settings=settings.instance-x
python manage.py migrate --settings=settings.instance-x
```

In addition, verify that the table has AUTO_INCREMENT for vendor.id and coupons.id. To apply it, first log in into
the MySQL server with the command
`mysql -h 3.129.250.41 -u root -P 5000 -pcoupons1001`.

Then, use the database by invoking the command
`use cpsc559;`.

Tables can be viewed by typing in `show tables;`. To see the properties of a table, type in
`describe TABLENAME;`.

The id column for our tables should have AUTO_INCREMENT. If this is not the case, type in
`ALTER TABLE tablename CHANGE id id INT NOT NULL AUTO_INCREMENT;`.

## Restarting the server
When the server is restarted, all services and all Docker instances will stop. The services are currently not starting
by default. To start a service, run
`sudo service django{n} start`

To start a Docker instance, run
`docker start DOCKER_NAME`.

There is a helper script that will automatically start all services. No script was
created to automatically start all instances, so that will need to be done manually.

Docker instances can be listed by running `docker container ls -a`.

There are a total of four services and four Docker instances that need to run.

## Server modifications

### Setting up a new DB
When setting up a new DB, the MySQL server may respond that the user is not allowed to access the DB. This is because
the MySQL server only permits connections from localhost. This
can be fixed by accessing the Docker instance with the command
`docker -it DOCKER_INSTANCE_NAME bash`.

In the shell, connect to MySQL by running `mysql -u root -pcoupons1001`. Then, execute the following commands:
```
CREATE USER 'root'@'%' IDENTIFIED BY 'coupons1001';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```
to allow all source IPs. (Not good from a security standpoint, but it's the fastest way to get it working.)

As well, MySQL must be configured to have a bind-address of `0.0.0.0` instead of
`127.0.0.1`. If the above queries have been executed, and that accessing from
localhost is allowed but from an external IP is not allowed, then the bind-address
must be configured.

## Scripts
There are helper scripts in the home directory on EC2. These can be used to quickly restart multiple processes at
once.

