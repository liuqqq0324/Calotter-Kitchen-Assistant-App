DROP TABLE IF EXISTS sous_chef_rms.rms_recipe_kitchenware;
CREATE TABLE sous_chef_rms.rms_recipe_kitchenware(
    id SERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    kitchenware_id INT8 NOT NULL,
    note VARCHAR(50),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.id IS 'Recipe kitchenware id;Recipe kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.recipe_id IS 'Recipe id;Recipe ID (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.kitchenware_id IS 'Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.note IS 'Note;Note (e.g., "pre-heat to 200 degree centigrade)';
COMMENT ON TABLE sous_chef_rms.rms_recipe_kitchenware IS 'rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.';

CREATE INDEX gk_recipe_kitchenware_recipe_id ON sous_chef_rms.rms_recipe_kitchenware (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_kitchenware_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_kitchenware_kitchenware_id ON sous_chef_rms.rms_recipe_kitchenware (
    kitchenware_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_kitchenware_kitchenware_id IS 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenware table';