-- Associate org members to the projects where a member of this project is in the org
CREATE MATERIALIZED VIEW orgs_projects_users AS
SELECT
	project_id,
	user_id
	FROM (
		SELECT
		org_members.org_id,
		projects_to_users.project_id,
		-- Create a line for each user for each org/project to make it available for hasura permissions
		unnest(org_members.org_privileged_user_ids) as user_id
	FROM projects_to_users
	INNER JOIN (
        SELECT
            orgs_to_users.org_id,
            array_agg(DISTINCT orgs_to_users.user_id) as org_user_ids,
            array_agg(DISTINCT orgs_to_users.user_id) FILTER (
                WHERE orgs_to_users.role_id IN (
                    -- standard
                    '4e77cfa2-a5b4-4dc2-a2d9-ddab3bb651e4',
                    -- owner
                    '378608b0-7c10-40d9-934e-7c634f860787',
                    -- administrator
                    '71010263-8077-45d7-a522-3396e55ec889'
                )
            ) as org_privileged_user_ids
        FROM orgs_to_users
        GROUP BY orgs_to_users.org_id
	) AS org_members ON projects_to_users.user_id=ANY(org_members.org_user_ids)
	GROUP BY org_members.org_id, projects_to_users.project_id, org_members.org_privileged_user_ids
) AS orgs_privileged_project_members
-- DEDUP user_id -> project_id if an user is in multiples orgs to get an unique indexable user_id -> project_id
GROUP BY orgs_privileged_project_members.project_id, orgs_privileged_project_members.user_id;
-- Create an UNIQUE INDEX to refresh concurently and speed up search
CREATE UNIQUE INDEX org_project_user_idx ON public.orgs_projects_users (project_id, user_id);
-- Create UNIQUE INDEX into projects_to_users table to speed up search
CREATE UNIQUE INDEX projects_to_users_idx ON projects_to_users (project_id, user_id);
-- Create UNIQUE INDEX into orgs_to_users table to speed up search
CREATE UNIQUE INDEX orgs_to_users_idx ON orgs_to_users (org_id, user_id);
-- Create a procedure to refresh the view
CREATE FUNCTION refresh_orgs_projects_users_materialized_view()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY orgs_projects_users;
    RETURN null;
end $$;
-- Refresh the view every time orgs_to_users changes (someone is added / removed of an org, or his role change in it)
CREATE TRIGGER refresh_orgs_projects_users_materialized_view
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON orgs_to_users FOR EACH STATEMENT 
EXECUTE PROCEDURE refresh_orgs_projects_users_materialized_view();
-- Refresh the view every time someone is added / removed from a project
CREATE TRIGGER refresh_orgs_projects_users_materialized_view
AFTER INSERT OR DELETE OR TRUNCATE
ON projects_to_users FOR EACH STATEMENT 
EXECUTE PROCEDURE refresh_orgs_projects_users_materialized_view();


SELECT
 *
FROM (
	SELECT
		orgs_to_users.org_id,
		array_agg(DISTINCT orgs_to_users.user_id) as org_user_ids,
		array_agg(DISTINCT orgs_to_users.user_id) FILTER (
			WHERE orgs_to_users.role_id IN (
				'4e77cfa2-a5b4-4dc2-a2d9-ddab3bb651e4',
				'378608b0-7c10-40d9-934e-7c634f860787',
				'71010263-8077-45d7-a522-3396e55ec889'
			)
		) as org_privileged_user_ids
	FROM orgs_to_users
	GROUP BY orgs_to_users.org_id
) AS org_members WHERE org_members.org_user_ids != org_members.org_privileged_user_ids