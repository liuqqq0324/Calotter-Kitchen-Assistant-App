DROP TABLE IF EXISTS sous_chef_rms.rms_kitchenware;
CREATE TABLE sous_chef_rms.rms_kitchenware(
    id BIGSERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    category VARCHAR(50),
    electronic BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    default_shown BOOLEAN,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.id IS 'Kitchenware id;Kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.name IS 'Kitchenware name;Name of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.description IS 'Kitchenware description;Description of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.image_url IS 'Kitchenware image url;Image URL of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.category IS 'Kitchenware category;Category of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.electronic IS 'Whether is electronic;Whether the kitchenware is electronic';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.created_at IS 'Create time;Create time';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.updated_at IS 'Update time;Update time';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.default_shown IS 'Whether is shown by default;Whether the kitchenware is shown by default';
COMMENT ON TABLE sous_chef_rms.rms_kitchenware IS 'rms_kitchenware;Global kitchenware table';

CREATE  UNIQUE INDEX uk_kitchenware_name ON sous_chef_rms.rms_kitchenware (
    name ASC
);
COMMENT ON INDEX sous_chef_rms.uk_kitchenware_name IS 'Unique index of kitchenware;The unique index of name field in kitchenware table';