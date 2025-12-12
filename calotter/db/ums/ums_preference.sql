DROP TABLE IF EXISTS sous_chef_ums.ums_preference;
CREATE TABLE sous_chef_ums.ums_preference(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    default_shown BOOLEAN,
    sort INT2 DEFAULT 0,
    create_time TIMESTAMP,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_preference.id IS 'Preference id;Preference ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_preference.name IS 'Preference name;Preference name';
COMMENT ON COLUMN sous_chef_ums.ums_preference.description IS 'Preference description;Preference description';
COMMENT ON COLUMN sous_chef_ums.ums_preference.default_shown IS 'Whether is shown by default;Whether the Preference is shown by default';
COMMENT ON COLUMN sous_chef_ums.ums_preference.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON COLUMN sous_chef_ums.ums_preference.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_preference.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_preference IS 'ums_preference;The global dietary preference of dining roles';

CREATE  UNIQUE INDEX uk_preference_name ON sous_chef_ums.ums_preference (
    name ASC
);
COMMENT ON INDEX sous_chef_ums.uk_preference_name IS 'Unique index of name;The unique index of name field in preference table';