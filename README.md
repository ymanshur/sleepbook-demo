# Sleepbook

SleepBook allows users to log/book their sleep, follow friends, and view ranked sleep sessions within their circle.

## TL;DR

This project is designed to demonstrate clean RESTful backend architecture with  Ruby on Rails best practices, including models, database migrations, schema, data aggregation, and JSON API. And this application must efficiently handle a **growing user base**, managing **high data volumes** and **concurrent requests**.

The strategy that comes to mind is written in the [Strategies to Enhance Performance and Scalability](#strategies-to-enhance-performance-and-scalability) section

### Teck Stack

- **Backend**: Ruby on Rails 8+
- **Database**: PostgreSQL

### Featured (used Gems)

#### Production

- [Puma](https://github.com/puma/puma) for the web server

#### Development

- [Dotenv](https://github.com/bkeepers/dotenv) for handling environment variables
- [SolarGraph](https://github.com/castwide/solargraph) for supporting Go To Definition

## Getting Started

### Prerequisites

- Ruby `3.4.4`
- Rails `8+`
- PostgreSQL `14`
- Bundler  `2.6.9`

### Running the application

#### Clone the repository

```bash
git clone https://github.com/ymanshur/sleepbook-demo.git
cd sleepbook-demo
```

#### Install dependencies

```bash
bundle install
```

#### Setup database

```bash
rails db:create db:migrate
```

#### Start the server

```bash
rails s
```

The server will run by default on <http://localhost:3000>

## RESTful API Endpoints

The basic approach to implement RESTful APIs is to group endpoints based on main resources to at least fulfill the required business processes as MVPs to perform the necessary [functions](#functional-requirement).

API design can be improved later according to the needs or best practices of RESTful API. It can be considered to apply [nested resources](https://guides.rubyonrails.org/routing.html#nested-resources) to emphasize domain context or describe user behavior.

### Functional Requirement

1. Track when you go to bed and wake up.
2. Connect with friends to build your sleep network.
3. View and compare the past week’s sleep duration of all users you follow, ranked by sleep length.

### Resources

<!-- For more complete API documentation, please visit the page -->

1. **User**

    | Method | URL | Description |
    | --- | --- | --- |
    | **POST** | `/api/v1/users` | Create a user |

2. **User Sleep**

    | Method | URL | Description |
    | --- | --- | --- |
    | **POST** | `/api/v1/user_sleeps`  | Create a sleep |
    | **PATCH** | `/api/v1/user_sleeps/:id` | Update the sleep data to complete the session |

3. **User Follow**

    | Method | URL | Description |
    | --- | --- | --- |
    | **POST** | `/api/v1/user_follows`  | Create a following relationship |
    | **DELETE** | `/api/v1/user_follows/:id` | Update the following data to break the relationship |

4. **Follow Sleep**

    | Method | URL | Description |
    | --- | --- | --- |
    | **GET** | `/api/v1/follow_sleeps` | Get recent sleep sessions of all followed users, ranked by sleep duration |

### Roadmap

One way to encourage CONTRIBUTION to this project is to create TODO notes. To view the notes in the codebase, you can run the command `bin/rails notes`

- [ ]  User cannot have more than one sleep session in a concurrent situation
- [ ]  Add pagination in returning user, sleeps, and follow sleeps data
- [ ]  Add API synced documentation (Swagger / Rswag)
- [ ]  Add observability for benchmark and load test

## Database Schema

Through this project, I emphasize that maintaining data integrity is the first thing that comes first. Starting from determining the master entity and followed by entities that have relationships with it.

As for a more comprehensive design, including indexing that will be made, can be seen on the following [page](https://dbdocs.io/ymanshur/Sleepbook)

<img width="60%" alt="Sleepbook ERD" src="https://github.com/user-attachments/assets/e59176d7-d31c-434c-9720-5cf87eac37ee" />

### Recommendations

#### Primary-key type

- For the sake of simplicity and since the API design is intended for RESTful API implementation, I intentionally use a big integer data type with auto increment or serial type as the primary key in each table.

    Please note that when the PK sequential number reaches its maximum (see [Datatype SERIAL](https://www.postgresql.org/docs/8.1/datatype.html#DATATYPE-SERIAL)), it will be a difficult challenge.

- For further needs, if the application grows so that it needs an even-sourcing approach, it is necessary to consider using suitable identifiers for sharded databases, such as UUID, to satisfy scalability requirements.
- One of the reasons I believe this application will evolve towards even-sourcing is that if the traffic received is no longer just read-heavy but also write-heavy, then the current schema must be transformed in such a way that it is immutable and reduces the lock during query writes.
- For additional info, to make UUID a PK column type in Rails, you can follow the following [UUID Primary Keys](https://guides.rubyonrails.org/v5.0/active_record_postgresql.html#uuid-primary-keys), being one of the reasons I consider PostgreSQL database over the others.

#### Time-zone aware

- Rails automatically adapts datetime data to the local time zone in the application layer (see [Configuring Location](https://guides.rubyonrails.org/configuring.html#locations-for-initialization-code)) and always keeps it in UTC in the database (see [ActiveRecord Timestamp](https://api.rubyonrails.org/classes/ActiveRecord/Timestamp.html))

#### Database indexing

- FK reference will trigger Rails to index the key without the need to explicitly add it to the migration file. For example, Rails migration will add an index to the `user_id` column because it references the `id` column in the users table, and it will appear in the db/schema.rb file as explained in the [Creating Associations](https://guides.rubyonrails.org/active_record_migrations.html#creating-associations).
- Other index databases will be added as columns or combinations of columns that are frequently used in queries. For example, an index on the combination of `user_id`, `start_time`, and `duration` columns will be needed to improve query performance to retrieve a list of sleep users followed since last week and sorted from the longest by sleep duration as [Functional Requirement](#functional-requirement)  No. 3.

    Why add `start_time` instead of `created_at` to the index? Because their values will be the same since the sleep session was created, but there is a potential for them to be different if the `start_time` value is changed. Therefore, if I were to filter data by date range, I would take `start_time` as the parameter instead of created at for the same reason.

- Consider including `end_time` column to cover the (`user_id`, `start_time`, `duration`) index, because the value will always be sent as a response body, and only index the session where the `end_time` is not null.

## Strategies to Enhance Performance and Scalability

After understanding the objective value of this application through functional requirements, the next step is to determine non-functional requirements that will affect how much throughput will or want to be achieved in terms of growing user base, high data volumes, and concurrent requests.

And what strategies or approaches should be taken for the infrastructure, database, and application layers?

### Traffic Estimation

Most importantly, we must determine whether the incoming traffic will be write or read heavy. To find out, the following calculation is needed;

- Targeted number of active users or DAU is **1 million** every day.
- It can be estimated that the number of users sleeping in a day is at most 3 times, so there are a total of **5 write requests every day** (wake up on different days)..
- Then, if the average user sees the sleep sessions of the followed user, it is **5 times** as well (as many as the number of users who  open the application to log sleep)
- And the estimated number of users who slept in the last 2 weeks is 3 x 14, or which is **about 30**
- If it is targeted that each user follows up to **100 friends** on average, then further calculations follow the following table:

    |  | **Writes/day** | **Reads/day** |
    | --- | --- | --- |
    | **Average RPS** | 1000000 x 5 ÷ 86,400 ~= 50 | 1000000 x 5 x 30 x 100 ÷ 86,400 ~= 150000 |
    | **Peak RPS (rule of thumb)** | ~2 × 50 ~= 100 | ~2 × 150000 ~= 300000 |

Based on the assumptions and calculations above, we can conclude that the application **handles more read requests** and must be able to retrieve and send data at least **300000 data** for approximately **50 requests** or **10 concurrent users** every second.

### **Database Optimizations**

There are two things that can be done to optimize the throughput of a single-node database like PostgreSQL: data indexing and partitioning.

**Data Indexing:**

- Since Rails 3 and above, there is a feature that automatically prints out a warning if the query search takes longer than 0.5 seconds. That might mean it would be a good time to use add index.
- What data or tables and columns should be indexed will be explained, and then we will look at the form of query used, especially for data retrieval.
- Can refer to the previous [recommendation](#database-indexing) regarding what services columns can potentially be stored in the index
- It should be noted that the order of the columns in the key of each index is crucial, and we shouldn't create indexes that haven't even been used in any query.

**Data Partitioning:**

- Database effort can be minimized by deleting or separating irrelevant data in the primary database every day using a scheduler.
- Another option is to maintain a persistent view that only stores relevant data to the query. That's why I chose to use PostgreSQL, which provides a physical view table that can be used for this option, the Materialized View. A Materialized view can wrap the last 2 weeks of data only, then updated every day leveraging low traffic times such as at bedtime..
- Another approach that can be made is to store data in Redis as a cache

### **Performance Features**

Efforts that can be made at the application layer are as follows

- **Pagination:** Pulling massive amounts of data will burden the database and application because the serialization process consumes a lot of memory and bandwidth especially if it needs to pass through several network hops.
- **Eager loading** with `includes()` to prevent N+1 queries

<!-- This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ... -->
