DROP TABLE IF EXISTS sous_chef_rms.rms_recipe_ingredient;
CREATE TABLE sous_chef_rms.rms_recipe_ingredient(
    id SERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    processing_note VARCHAR(50),
    optional BOOLEAN DEFAULT FALSE,
    garnish BOOLEAN DEFAULT FALSE,
    sort INT2,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.id IS 'Recipe ingredient id;Recipe ingredient ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.recipe_id IS 'Recipe id;Recipe id (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.ingredient_id IS 'Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.quantity IS 'Quantity of ingredient;Estimated quantity of ingredients used';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.unit IS 'Unit of ingredients;Unit of ingredients';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.processing_note IS 'Processing note;Processing note (e.g., "cut into slices", "remove skins")';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.optional IS 'Is optional;Whether this ingredient is optional';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.garnish IS 'Is garnish;Whether this ingredient is garnish';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.sort IS 'Sort of process;Display order';
COMMENT ON TABLE sous_chef_rms.rms_recipe_ingredient IS 'rms_recipe_ingredient;Store the ingredient compositions of recipes.';

CREATE INDEX gk_recipe_ingredient_recipe_id ON sous_chef_rms.rms_recipe_ingredient (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_ingredient_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_ingredient_ingredient_id ON sous_chef_rms.rms_recipe_ingredient (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_ingredient_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';