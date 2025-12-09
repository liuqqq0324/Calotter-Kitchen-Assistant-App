DROP TABLE IF EXISTS sous_chef_rms.rms_recipe;
CREATE TABLE sous_chef_rms.rms_recipe(
    id BIGSERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    cuisine_type VARCHAR(50),
    difficulty_level INT2 DEFAULT 1,
    serving_size INT2 DEFAULT 1,
    prep_time_minutes INT2,
    cook_time_minutes INT2,
    total_time_minutes INT2,
    calories_per_serving INT2,
    tags JSONB,
    instructions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe.id IS 'Recipe id;Recipe ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.name IS 'Recipe name;Recipe name';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.description IS 'A brief description of recipe;Recipe description (e.g., scrambled eggs with tomatoes)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.image_url IS 'Finish product image url;URL of finished product image';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.cuisine_type IS 'The cuisine type of recipe;Cuisine type (e.g., Sichuan dishes, Italian noodles)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.difficulty_level IS 'The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.serving_size IS 'The standard serving size;Standard serving size (e.g., for 2 people)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.prep_time_minutes IS 'The time cost for preparation;The time cost of preparation process';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.cook_time_minutes IS 'The time cost for cooking;The time cost of cooking process';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.total_time_minutes IS 'The time cost in total;The time cost in total';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.calories_per_serving IS 'The estimated calories per one serving size;The estimated calories per one serving size';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.tags IS 'The tags of recipe;Tags of recipe';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.instructions IS 'The detailed steps for cooking;Cooking steps';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.created_at IS 'The time of creation;Created time';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.updated_at IS 'The time of update;Updated time';
COMMENT ON TABLE sous_chef_rms.rms_recipe IS 'rms_recipe;Stores all recipes and the corresponding ingredients.';

CREATE INDEX gk_recipe_cuisine_type ON sous_chef_rms.rms_recipe (
    cuisine_type ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_cuisine_type IS 'Recipe cuisine type;Cuisine type general index';
CREATE INDEX gk_recipe_tags ON sous_chef_rms.rms_recipe (
    tags ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_tags IS 'Recipe tag;GIN supports searching specific tags';