SET check_function_bodies = false;
CREATE TABLE public.org_roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.orgs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text
);
COMMENT ON TABLE public.orgs IS 'Orgs table';
CREATE TABLE public.orgs_to_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL
);
COMMENT ON TABLE public.orgs_to_users IS 'Orgs to users relations';
CREATE TABLE public.project_address (
    project_id uuid NOT NULL,
    street text NOT NULL
);
COMMENT ON TABLE public.project_address IS 'Project address infos';
CREATE TABLE public.projects (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text
);
COMMENT ON TABLE public.projects IS 'Projects table';
CREATE TABLE public.projects_to_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL
);
COMMENT ON TABLE public.projects_to_users IS 'Project users relation table';
CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text
);
COMMENT ON TABLE public.users IS 'Users table';
ALTER TABLE ONLY public.org_roles
    ADD CONSTRAINT org_roles_name_key UNIQUE (name);
ALTER TABLE ONLY public.org_roles
    ADD CONSTRAINT org_roles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orgs
    ADD CONSTRAINT orgs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orgs_to_users
    ADD CONSTRAINT orgs_to_users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.project_address
    ADD CONSTRAINT project_address_pkey PRIMARY KEY (project_id);
ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.projects_to_users
    ADD CONSTRAINT projects_to_users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orgs_to_users
    ADD CONSTRAINT orgs_to_users_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.orgs(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.orgs_to_users
    ADD CONSTRAINT orgs_to_users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.org_roles(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.orgs_to_users
    ADD CONSTRAINT orgs_to_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.project_address
    ADD CONSTRAINT project_address_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.projects_to_users
    ADD CONSTRAINT projects_to_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.projects_to_users
    ADD CONSTRAINT projects_to_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE CASCADE;
