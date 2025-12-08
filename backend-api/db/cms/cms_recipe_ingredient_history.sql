DROP TABLE IF EXISTS sous_chef_cms.cms_recipe_ingredient_history;
CREATE TABLE sous_chef_cms.cms_recipe_ingredient_history(
    id BIGSERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity_used DECIMAL(10,2),
    unit VARCHAR(20),
    substitution BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.id IS 'Session ingredient usage id;Session ingredient usage ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.recipe_id IS 'Recipe id;History recipe ID (FK, recipe_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.ingredient_id IS 'Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.quantity_used IS 'Quantity used;Quantity used for the dish';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.unit IS 'Unit of ingredient used;Unit for the used ingredient';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.substitution IS 'Is a substitution ingredient;Whether is a substitution ingredient (e.g., the recipe is beef, but I used pork)';
COMMENT ON TABLE sous_chef_cms.cms_recipe_ingredient_history IS 'cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.';

CREATE INDEX gk_recipe_ingredient_history_recipe_id ON sous_chef_cms.cms_recipe_ingredient_history (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_recipe_ingredient_history_recipe_id IS 'General index of history dish id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_ingredient_history_ingredient_id ON sous_chef_cms.cms_recipe_ingredient_history (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_recipe_ingredient_history_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';