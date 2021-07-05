# Use case

This simply demostrate the following rules:

An user can have multiples projects.
An user can be in multiples orgs with different roles ("standard" | "admin" | "owner" | "limited")
A project can have multiples members.
An org can have multiples members.

An user have access to a project global infos in two cases:

1. The user is a direct member of the project.
2. A member of the project share an organization with the "user", and in this organization, the user is not "limited".

Of courses, the same condition apply for "public" project associtation fields (eg: the address of a project is considered as a public information)


## The issue

When querying nested associations, the check conditions reapply every time (we check if you have access to the project, then we check if you have access to the address). Making queries to significantly slow down.

## Tried solution:

1. Using an intermediate materialized view to try to create a "hard link" between orgMembers(with allowed roles) -> project_id. When this method was working well for a tiny amount of data, the "view creation" time grow with the number of rows in the DB. The implementation can be found here: https://github.com/Clovis-team/hasura-bottleneck/pull/1


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

## Some analyse of the queries

- Query projects -> address without permissions on address:
[without_permission_on_address.pdf](https://github.com/Clovis-team/hasura-bottleneck/files/6764125/without_permission_on_address.pdf)



- Query projects -> address with permissions on addresse:
[query_with_address_permissions.pdf](https://github.com/Clovis-team/hasura-bottleneck/files/6764126/query_with_address_permissions.pdf)



