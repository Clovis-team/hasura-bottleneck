# Setup

1. Run Hasura + Postgres database
```bash
docker-compose up
```

2. Seed org_roles to database

```bash
cd ./hasura/
hasura seed apply --file 1625474781277_org_roles_seed.sql
```

3. Seed some fake data

load a tiny amount of data
```bash
cd ./hasura/
hasura seed apply --file 1625483292341_small_tables_seeds.sql
```

load a bigger amount of data (bench test)
```bash
cd ./hasura/
hasura seed apply --file 1625484922825_bigger_tables_seeds.sql
```


# Reproduce bottleneck

Choose a user with an org, and then into hasura console run the follwing graphql query using:

- x-hasura-role: user
- x-hasura-user-id: <USER_UUID>

This query should be very fast
```gql
{
    projects {
        __typename
    }
}
```

This one way less:
```gql
{
    projects {
        address {
            __typename
        }
    }
}
```

This one should also be slow:

```gql
{
    address {
        project {
            __typename
        }
    }
}
```

If you remove the permissions on the "project_address" tables, the requests should speed up. 