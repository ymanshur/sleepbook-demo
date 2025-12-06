# Sleepbook

SleepBook allows users to log/book their sleep, follow friends, and view ranked sleep sessions within their circle.

## TL;DR

This project is designed to demonstrate clean RESTful backend architecture with Ruby on Rails best practices, including models, database migrations, schema, data aggregation, and JSON API. And this application must efficiently handle a **growing user base**, managing **high data volumes** and **concurrent requests**.

The strategies that comes to mind have written in the [Strategies to Enhance Performance and Scalability](#strategies-to-enhance-performance-and-scalability) sections

### Teck Stack

- **Backend**: Ruby on Rails
- **Database**: PostgreSQL
- **Pub/Sub**: Redis

### Featured (used Gems)

#### Production

- [Puma](https://github.com/puma/puma) for highly parallel web server
- [Pagy](https://github.com/ddnexus/pagy) for the [best](https://ddnexus.github.io/pagination-comparison/gems.html) response data pagination
- [ActiveModelSerializer](https://github.com/rails-api/active_model_serializers/tree/0-10-stable) for JSON response formating
- [Scenic](https://github.com/scenic-views/scenic) for database/table materialized view versioning
- [Sidekiq-cron](https://github.com/sidekiq-cron/sidekiq-cron) for safe scheduling jobs at specified times using Redis sorted set

#### Development, Test

- [Dotenv](https://github.com/bkeepers/dotenv) for handling environment variables
- [SolarGraph](https://github.com/castwide/solargraph) for supporting Go To Definition
- [Bullet](https://github.com/flyerhzm/bullet) for alerting you when to use eager loading
- [Faker](https://github.com/faker-ruby/faker) for generating realistic-looking fake data

## Getting Started

### Prerequisites

- Ruby `3.4.4`
- Rails `8+`
- Bundler  `2.6.9`

### Running the application locally

#### Clone the repository

```bash
git clone https://github.com/ymanshur/sleepbook-demo.git
cd sleepbook-demo
```

#### Install dependencies

```bash
bundle install
```

#### Set up environment variable

```bash
echo "DATABASE_URL=postgres://myuser:mypass@localhost:5432" > .env
```

#### Setup database

```bash
rails db:create db:migrate
```

#### Start the server

```bash
# HTTP server

rails server
```

The server will run by default on <http://localhost:3000>

#### Start the background jobs processor

The background job has determined to refresh materialized view table periodically.

```bash
# Run the consumers

bundle exec sidekiq
```

Note: Make sure the Redis available

```bash
# Add following command to specify the correct URL in a .env file

echo "REDIS_URL=redis://localhost:6379/0" >> .env
```

#### Change the refresh materialized view scheduling

I used Materialized View to perform followee sleeps retrieval data according to denormalization in [Data Partitioning](#data-partitioning) strategy.

Schedule the job every 5 minutes

```yml
# config/schedule.yml
refresh_user_recent_followee_sleeps_job:
  cron: "*/5 * * * *"
  class: "RefreshUserRecentFolloweeSleepsJob"
```

To run the scheduled job immediately

```bash
rails runner "RefreshUserRecentFolloweeSleepsJob.perform_now"
```

### Testing

#### Setup database test

```bash
rails db:create db:migrate RAILS_ENV=test
```

#### Run all tests

```bash
rails test
```

#### Run the specific test file

```bash
rails test test/models/user_test.rb
```

## RESTful API Endpoints

The basic approach to implement RESTful APIs is to group endpoints based on main resources to at least fulfill the required business processes as MVPs to perform the necessary functions.

API design can be improved later according to the needs or best practices of RESTful API. It can be considered to apply [nested resources](https://guides.rubyonrails.org/routing.html#nested-resources) to emphasize domain context or describe user behavior.

### Functional Requirement

1. Track when you go to sleep and wake up. Book your sleep and complete it later
2. Connect with followees to build your sleep journaling circle. And you cannot follow yourself
3. View and compare the past week’s sleep of all your followees, ranked by sleep duration.

### Roadmap

One way to encourage CONTRIBUTION to this project is to create TODO notes. To view the notes in the codebase, you can run the following command

```bash
bin/rails notes
```

#### Funtions

- [x] Add pagination in the returning list of data
- [ ] User cannot have more than one sleep session in a concurrent or overlapping situation
- [ ] Once a sleep session is done, it's going to be immutable
- [ ] Show the global ranked sleeps (not just from followees)

#### Documentation and Testing

- [ ] Add API synced documentation (Swagger / Rswag)
- [ ] Provide test coverage
- [ ] Script to scenario tests

#### Performance

- [ ] Add observability for benchmark and load test

#### Deployment

- [ ] Docker Compose to simulate the production environment

### Resources

You can import the endpoint collection from [Postman artifact](doc/Sleepbook_demo.postman_collection.json) and generate the OpenAPI specification from it.

<!-- For more complete API documentation, please visit the page -->

Below are the available endpoints and their uses to fulfill the [functional requirements](#functional-requirement):

#### 1. User

| Method | Path | Description |
| --- | --- | --- |
| **GET** | `/api/v1/users` | List users |
| **GET** | `/api/v1/users/:id` | Get a user |
| **POST** | `/api/v1/users` | Create a user |
| **PUT/PATCH** | `/api/v1/users/:id` | Update a user name |
| **DELETE** | `/api/v1/users/:id` | Delete a user |

#### 2. User Sleep

| Method | Path | Description |
| --- | --- | --- |
| **GET** | `/api/v1/users/:user_id/sleeps`  | Create a sleep |
| **GET** | `/api/v1/users/:user_id/sleeps/:id`  | Get a sleep |
| **POST** | `/api/v1/users/:user_id/sleeps`  | Start a sleep |
| **PATCH** | `/api/v1/users/:user_id/sleeps/:id`  | Update the sleep end_time to complete the session |
| **DELETE** | `/api/v1/users/:user_id/sleeps/:id`  | Delete a sleep |

#### 3. Follow

| Method | Path | Description |
| --- | --- | --- |
| **GET** | `/api/v1/users/:user_id/followees`  | List following users |
| **GET** | `/api/v1/users/:user_id/followees/:id`  | Get a following user |
| **POST** | `/api/v1/users/:user_id/followees`  | Follow another user |
| **DELETE** | `/api/v1/users/:user_id/followees/:id` | Un-follow another user |

#### 4. Followee Sleep

| Method | Path | Description |
| --- | --- | --- |
| **GET** | `/api/v1/users/:user_id/followee_sleeps` | List recent sleep sessions of all following users, ranked by sleep duration |
| **GET** | `/api/v1/users/:user_id/followee_sleeps/:id` | Get a sleep session of a followed user|

## Database Schema

Through this project, I emphasize that maintaining data integrity is the first thing that comes first. Starting from determining the master entity and followed by entities that have relationships with it.

<img width="50%" alt="Sleepbook ERD" src="https://github.com/user-attachments/assets/e59176d7-d31c-434c-9720-5cf87eac37ee" />

As for a more comprehensive design, including indexing that will be made, can be seen on the following [page](https://dbdocs.io/ymanshur/Sleepbook)

### Recommendations

#### Primary-key type

- For the sake of simplicity and since the API design is intended for RESTful API implementation, I intentionally use a big integer data type with auto increment or serial type as the primary key in each table.

    Please note that when the PK sequential number reaches its maximum (see [Datatype SERIAL](https://www.postgresql.org/docs/8.1/datatype.html#DATATYPE-SERIAL)), it will be a difficult challenge.

- For further needs, if the application grows so that it needs an _even-sourcing_ approach, it is necessary to consider using suitable identifiers for sharded databases, such as UUID, to satisfy scalability requirements.
- One of the reasons I believe this application will evolve towards even-sourcing is that if the traffic received is no longer just read-heavy but also write-heavy, then the current schema must be transformed in such a way that it is immutable and reduces the lock during query writes.
- For additional info, to make UUID a PK column type in Rails, you can follow the following [UUID Primary Keys](https://guides.rubyonrails.org/v5.0/active_record_postgresql.html#uuid-primary-keys), being one of the reasons I consider PostgreSQL database over the others.

#### Time-zone aware

- Rails automatically adapts datetime data to the local time zone in the application layer (see [Configuring Location](https://guides.rubyonrails.org/configuring.html#locations-for-initialization-code)) and always keeps it in UTC in the database (see [ActiveRecord Timestamp](https://api.rubyonrails.org/classes/ActiveRecord/Timestamp.html))

#### Database index

- FK reference will trigger Rails to index the key without the need to explicitly add it within the migration file. For example, Rails [migration](db/migrate/20250919133939_create_user_sleeps.rb) will add an index to the `user_id` column on the `user_sleeps` table because it references the `id` column in the users table, and it will appear in the [db/schema.rb](db/schema.rb) file as explained in the [Creating Associations](https://guides.rubyonrails.org/active_record_migrations.html#creating-associations).

- Other database indexes are added as columns or combinations of columns that are frequently used in queries. For example, an index on the combination of `user_id`, `start_time`, and `duration` columns will be needed to improve query performance to retrieve a list of a user sleeps from last week and sorted from the longest by sleep duration.

    Why add `start_time` instead of `created_at` to be indexed? Because their values will be the same since the sleep session was created, but there is a potential for them to be different if the `start_time` value is changed. Therefore, if I were to filter data by date range, I would take `start_time` as the parameter instead of created at for the same reason.

    However, it will require more than just database indexing to ensure the feature [No. 3](#functional-requirement) can handle compound data from many users massively.

- It should be noted that the order of the columns in the key of each index is crucial, and we shouldn't create indexes that haven't even been used in any query.

## Strategies to Enhance Performance and Scalability

After understanding the objective value of this application through functional requirements, the next step is to determine non-functional requirements that will affect how much throughput will or want to be achieved in terms of growing user base, high data volumes, and concurrent requests.

And what strategies or approaches should be taken for the **infrastructure**, **database**, and **application** layers?

### Traffic Estimation

Most importantly, we must determine whether the incoming traffic will be write or read heavy. To find out, the following calculation is needed;

- Targeted number of daily active users or DAU is **1 million**.
- It can be estimated that the number of users sleeping in a day is at most 3 times, so there are a total of **5 write requests every day** (assuming wake up on different days).
- Then, if the average user sees the sleep sessions of their followees, it is **10 times** as well.
- And the estimated number of users who slept in the last 2 weeks is 3 x 14, which is **about 40**
- If the targeted number of each user follows, up to **500 friends** on average, then further calculations as follows:

    |  | **Writes/day** | **Reads/day** |
    | --- | --- | --- |
    | **Average RPS** | 1000000 x 5 ÷ 86,400 ~= 50 | 1000000 x 10 ÷ 86,400 ~= 100 |
    | **Peak RPS (rule of thumb)** | 2 × ~50 ~= 100 | 2 × ~100 ~= 200 |

Based on the assumptions and calculations above, we can conclude that the application **handles more read requests** and must be able to retrieve and send data at least **20000 data** for approximately **100/200 write/read requests** in peak second and **10-20 concurrent users** every second.

### Performance Features

As the number of users increases, the data likely received, especially from the server, will also grow. So, there are at least two things to consider:

- **Pagination:** Pulling massive amounts of data will burden the database and application because the serialization process and transferring consume a lot of memory and bandwidth, especially if it needs to pass through several network hops.

    Pagination is enough to reduce latency between networks and also reduce database and application memory usage. However, a maximum limit of data that can be achieved must be set, considering the query `COUNT(id)` and `OFFSET` allows full scan execution of retrieval queries if paging overflow occurs.

- **Eager loading** with `includes()` to prevent N+1 queries might be the join table alternative and acquisition of unnecessary pool connections.

### Database Optimizations

There are two things that optimizing the throughput of a single-node database like PostgreSQL: Data _Indexing_ and _Partitioning_.

#### Data Indexing

- The columns that have been indexed with B-Tree data structure are composite consisting of `user_id`, `start_time`, and `duration` columns in sequence on the `user_sleeps` table, by the version [20250921155004](db/migrate/20250921155004_add_composite_index_to_user_sleeps.rb) of database migration.

- Establishing the composite index (`user_id`, `start_time`, `duration`) will resolve the pagination overflow issue. Every time the page arrives the last page, then a full scan will not occur, even though data has accumulated over the years, queries will always have limits, returning only to recent data supported with data filters based on the indexed `start_time` column.

    Note that `user_id` is in front of the composite index because the current query only displays data from each user, so it must use this column and it will remove the most of rows at the first execution. The `duration` column was added to the composite index in anticipation of the duration-based sorting feature.

- Adding a [Partial index](db/migrate/20250921174246_add_composite_partial_index_to_user_sleeps.rb) is to prevent nil `end_time` data included within the indexing data structure. Which might reduce the filtering step, especially for returning completed sleep with calculated duration.

    I also demonstrated how to add the updated combosite partial index to a existing table with **zero down-time** using concurrent feature and disabling transaction during te migration.

- Covering index also was added once the `end_time` value is no longer nil, then the data will always be sent as a response.

- In addition, I also added the [unique index](db/migrate/20250921000404_add_unique_index_to_follows.rb) on the (`follower_id`, `followed_id`) column because every time a followee is added, there will always be a check to prevent data duplication.

- The list sleeps with time range-based filtering is enhanced by the specific composite index that only consists of (`start_time`, `duration`) which has been added by the version [20250924232720](db/migrate/20250924232720_add_split_composite_partial_index_to_user_sleeps.rb) of database migration.

#### Data Partitioning

- Database effort can be minimized by deleting or separating irrelevant data from the primary database or source table periodically through a scheduling mechanism.

- Another option is to maintain a persistent view that only stores relevant data to the query. That's why I chose to use PostgreSQL, which provides a physical view table that can be used for this option, called a **Materialized View**.

    As I predicted [earlier](#database-index), data access that involves complex queries cannot only be solved by database indexing, as my analysis below shows.

    Data that I have seeded:

    | Table_Name | Row_Count |
    | ---------------------- | ------------------- |
    | user_recent_followee_sleeps | 6037199 |
    | follows                     |  399583 |
    | user_sleeps                 |   90047 |
    | users                       |    1000 |

    | Follower_ID | Total_Followees | Total_User_Recent_Followee_Sleeps |
    | --- | --- | ----- |
    | 929 | 799 | 12087 |

    and the related query execution planning result shows:

    ```bash
    EXPLAIN (ANALYZE, VERBOSE) SELECT "user_sleeps".* FROM "user_sleeps" INNER JOIN "users" ON "user_sleeps"."user_id" = "users"."id" INNER JOIN "follows" ON "users"."id" = "follows"."followed_id" WHERE "follows"."follower_id" = 929 AND "user_sleeps"."start_time" >= '2025-09-14 17:00:00' AND "user_sleeps"."end_time" IS NOT NULL ORDER BY "user_sleeps"."duration" DESC, "user_sleeps"."id" ASC /*application='SleepbookDemo'*/
                                                                                                QUERY PLAN
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Sort  (cost=3148.91..3183.26 rows=13738 width=52) (actual time=15.245..16.546 rows=12435 loops=1)
    Output: user_sleeps.id, user_sleeps.user_id, user_sleeps.start_time, user_sleeps.end_time, user_sleeps.duration, user_sleeps.created_at, user_sleeps.updated_at
    Sort Key: user_sleeps.duration DESC, user_sleeps.id
    Sort Method: quicksort  Memory: 2133kB
    ->  Hash Join  (cost=73.17..2204.71 rows=13738 width=52) (actual time=0.380..10.291 rows=12435 loops=1)
            Output: user_sleeps.id, user_sleeps.user_id, user_sleeps.start_time, user_sleeps.end_time, user_sleeps.duration, user_sleeps.created_at, user_sleeps.updated_at
            Inner Unique: true
            Hash Cond: (user_sleeps.user_id = users.id)
            ->  Hash Join  (cost=41.67..2137.47 rows=13556 width=60) (actual time=0.198..8.302 rows=12435 loops=1)
                Output: user_sleeps.id, user_sleeps.user_id, user_sleeps.start_time, user_sleeps.end_time, user_sleeps.duration, user_sleeps.created_at, user_sleeps.updated_at, follows.followed_id
                Inner Unique: true
                Hash Cond: (user_sleeps.user_id = follows.followed_id)
                ->  Seq Scan on public.user_sleeps  (cost=0.00..2054.59 rows=15629 width=52) (actual time=0.003..
    5.905 rows=15547 loops=1)
                        Output: user_sleeps.id, user_sleeps.user_id, user_sleeps.start_time, user_sleeps.end_time,
    user_sleeps.duration, user_sleeps.created_at, user_sleeps.updated_at
                        Filter: ((user_sleeps.end_time IS NOT NULL) AND (user_sleeps.start_time >= '2025-09-14 17:0
    0:00'::timestamp without time zone))
                        Rows Removed by Filter: 74500
                ->  Hash  (cost=30.68..30.68 rows=879 width=8) (actual time=0.181..0.183 rows=799 loops=1)
                        Output: follows.followed_id
                        Buckets: 1024  Batches: 1  Memory Usage: 40kB
                        ->  Index Scan using index_follows_on_follower_id on public.follows  (cost=0.30..30.68 rows
    =879 width=8) (actual time=0.016..0.098 rows=799 loops=1)
                            Output: follows.followed_id
                            Index Cond: (follows.follower_id = 929)
            ->  Hash  (cost=19.00..19.00 rows=1000 width=8) (actual time=0.174..0.175 rows=1000 loops=1)
                Output: users.id
                Buckets: 1024  Batches: 1  Memory Usage: 48kB
                ->  Seq Scan on public.users  (cost=0.00..19.00 rows=1000 width=8) (actual time=0.006..0.068 rows
    =1000 loops=1)
                        Output: users.id
    Planning Time: 0.759 ms
    Execution Time: 17.076 ms
    ```

    From the analysis, I have known that as the number of followers increases, it becomes less important to index `user_id` column that correlating to followed ids on the `user_sleeps` table, because the database always prefer to avoid accessing index repeatedly to retrieve compound data.

    That's why I have added the materialized view table with the intention of optimizing the index usage and reducing the nested joins query that overloads the database every time the user accesses the followee's sleeps data. Through the view table, query retrieval can be done without extensive table joins because it already stores the required data in a precomputed view. This strategy is called **Denormalization**.

    An overview of this table is shown in the figure below.

    <img width="50%" alt="Sleepbook MV" src="https://github.com/user-attachments/assets/5382b0d1-fdc9-42f4-b2ca-bc81911e6be5" />

    By setting the materialized view to only wrap the last 2 weeks of data, then all that's left is to filter by `follower_id` and sort by the `duration` column. The results of the analysis with the same data set are shown below

    ```shell
    EXPLAIN (ANALYZE, VERBOSE) SELECT "user_recent_followee_sleeps".* FROM "user_recent_followee_sleeps" WHERE "user_recent_followee_sleeps"."follower_id" = 929 ORDER BY "user_recent_followee_sleeps"."duration" DESC, "user_recent_followee_sleeps"."sleep_id" ASC /*application='SleepbookDemo'*/
                                                                                    QUERY PLAN
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Sort  (cost=33408.37..33440.07 rows=12678 width=60) (actual time=12.119..12.464 rows=12087 loops=1)
    Output: id, follower_id, sleep_id, user_id, start_time, end_time, duration
    Sort Key: user_recent_followee_sleeps.duration DESC, user_recent_followee_sleeps.sleep_id
    Sort Method: quicksort  Memory: 2084kB
    ->  Bitmap Heap Scan on public.user_recent_followee_sleeps  (cost=282.69..32544.36 rows=12678 width=60) (actual time=2.889..9.217 rows=12087 loops=1)
            Output: id, follower_id, sleep_id, user_id, start_time, end_time, duration
            Recheck Cond: (user_recent_followee_sleeps.follower_id = 929)
            Heap Blocks: exact=10915
            ->  Bitmap Index Scan on index_user_recent_followee_sleeps_on_follower_id_and_duration  (cost=0.00..279.52 rows=12678 width=0) (actual time=1.738..1.739 rows=12087 loops=1)
                Index Cond: (user_recent_followee_sleeps.follower_id = 929)
    Planning Time: 0.076 ms
    Execution Time: 12.912 ms
    ```

    This approach enables server to handle significantly larger amounts of data with decreasing response latency, which would substantially increase throughput (to be confirmed through [performance tests](#performnace-testing)).

    | State | Total | Views | ActiveRecord | GC |
    | ------ | ---- | ------ | ---------------------------- | ----- |
    | Before | 97ms | 33.9ms | 55.6ms (4 queries, 0 cached) | 11.0ms |
    | After (MV)  | 35ms | 15.4ms | 15.9ms (4 queries, 0 cached) | 0.0ms |

    It should also be noted that I have added indexing to the materialized view table, including a composite index on unique (`follower_id`, `sleep_id`) and an ordered index on (`follower_id`, `duration`), so that performance will be more effective even if there is more data.

    However, this approach still has trade-offs. Depending on the SLA, the data will not always be consistent with the source table; scheduling can be organized based on this. For now, I set the scheduling every 5 minutes, assuming about 7000 incoming data in that period, following the calculation [previously](#traffic-estimation)

- Another approach that can be made is to store data in Redis as a cache. Especially if the system needs to provide leaderboard data of sleep duration for all users. The list of top users can be stored in Sorted Sets Redis as the fastest source of truth through an event-sourcing architecture.

## Performnace Testing

### Scenarions

Setup 10 created users with zero followee

#### User Followings

Run 10 VUs to create and follow a user with ID 1 - 500

#### User Recent Followee Sleeps

Run 10 VUs to hit followee sleeps endpoint

#### Followee sleeps

Run 500 VUs to create completed sleeps

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
