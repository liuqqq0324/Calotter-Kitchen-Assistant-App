-- Homepage Recipe Nutrition Table
-- 存储菜谱的详细营养成分（如果Recipe表中没有详细营养成分，可以使用此表）

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS sous_chef_hp;

DROP TABLE IF EXISTS sous_chef_hp.hp_recipe_nutrition;
CREATE TABLE sous_chef_hp.hp_recipe_nutrition(
    id SERIAL NOT NULL,
    recipe_id INT4 NOT NULL,
    energy DECIMAL(10, 2) NOT NULL, -- Energy in kcal per serving
    fat DECIMAL(10, 2) NOT NULL, -- Fat in grams per serving
    carbohydrates DECIMAL(10, 2) NOT NULL, -- Carbohydrates in grams per serving
    protein DECIMAL(10, 2) NOT NULL, -- Protein in grams per serving
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE (recipe_id)
);

COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.id IS 'Recipe nutrition id;Recipe nutrition ID (PK)';
COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.recipe_id IS 'Recipe id;Recipe ID (FK, recipe_id -> rms_recipe.id)';
COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.energy IS 'Energy;Energy in kcal per serving';
COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.fat IS 'Fat;Fat in grams per serving';
COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.carbohydrates IS 'Carbohydrates;Carbohydrates in grams per serving';
COMMENT ON COLUMN sous_chef_hp.hp_recipe_nutrition.protein IS 'Protein;Protein in grams per serving';
COMMENT ON TABLE sous_chef_hp.hp_recipe_nutrition IS 'hp_recipe_nutrition;This table stores detailed nutrition information for recipes.';

CREATE INDEX idx_recipe_nutrition_recipe_id ON sous_chef_hp.hp_recipe_nutrition (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_hp.idx_recipe_nutrition_recipe_id IS 'Index on recipe_id;Index for efficient querying by recipe';
