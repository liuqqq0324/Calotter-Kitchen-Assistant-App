DROP TABLE IF EXISTS sous_chef_ums.ums_restriction;
CREATE TABLE sous_chef_ums.ums_restriction(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    default_shown BOOLEAN,
    sort INT2 DEFAULT 0,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_restriction.id IS 'Restriction id;Restriction ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.name IS 'Restriction name;Restriction name';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.description IS 'Restriction description;The description of the restriction';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.default_shown IS 'Whether is default shown;Whether the dietary restriction is shown by default';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON TABLE sous_chef_ums.ums_restriction IS 'ums_restriction;The global dietary restrictions of dining roles';