DROP TABLE IF EXISTS sous_chef_rms.rms_cuisine_type;
CREATE TABLE sous_chef_rms.rms_cuisine_type(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    icon_url VARCHAR(255),
    sort INT2 DEFAULT 0,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.id IS 'Cuisine id;Cuisine ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.name IS 'Cuisine name;Cuisine name';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.icon_url IS 'Cuisine icon url;Icon URL of the cuisine';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON TABLE sous_chef_rms.rms_cuisine_type IS 'rms_cuisine_type;The cuisine types of recipes';

CREATE  UNIQUE INDEX uk_cuisine_type_name ON sous_chef_rms.rms_cuisine_type (
    name ASC
);
COMMENT ON INDEX sous_chef_rms.uk_cuisine_type_name IS 'Unique index of name;The unique index of name field in cuisine type table';