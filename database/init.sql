-- ===============================
-- RMS: Recipe Management schema
-- ===============================

-- 1. schema
create schema if not exists sous_chef_rms;

-- 2. 清理旧表（先删子表，再删父表）
drop table if exists sous_chef_rms.rms_recipe_kitchenware;
drop table if exists sous_chef_rms.rms_recipe_ingredient;
drop table if exists sous_chef_rms.rms_recipe;
drop table if exists sous_chef_rms.rms_ingredient;

-- 3. 建表：rms_ingredient
create table sous_chef_rms.rms_ingredient(
                                             id             serial        not null,
                                             name           varchar(100)  not null,
                                             category       varchar(50),
                                             standard_unit  varchar(20),
                                             nutrition_info jsonb,
                                             storage_advice text,
                                             image_url      varchar(255),
                                             primary key (id)
);

comment on column sous_chef_rms.rms_ingredient.id             is 'Ingredient id;Ingredient ID (PK)';
comment on column sous_chef_rms.rms_ingredient.name           is 'Ingredient name;Ingredient name (e.g., "tomato")';
comment on column sous_chef_rms.rms_ingredient.category       is 'Category;Ingredient category (e.g., "vegetable")';
comment on column sous_chef_rms.rms_ingredient.standard_unit  is 'Standard unit;Standard unit (e.g., "gram/g")';
comment on column sous_chef_rms.rms_ingredient.nutrition_info is 'Nutrition information;Nutrition value (e.g., { "protein": "xxx g/kg", "carbohydrates": "xxx g/kg" })';
comment on column sous_chef_rms.rms_ingredient.storage_advice is 'Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., "Store in the refrigerator or in a cool, dark place.")';
comment on column sous_chef_rms.rms_ingredient.image_url      is 'Standard image;Standard image URL for ingredient image';
comment on table  sous_chef_rms.rms_ingredient                is 'rms_ingredient;Stores all ingredients could be used in a recipe.';

-- 4. 建表：rms_recipe
create table sous_chef_rms.rms_recipe(
                                         id                  serial       not null,
                                         name                varchar(100) not null,
                                         description         text,
                                         image_url           varchar(255),
                                         cuisine_type        varchar(50),
                                         difficulty_level    int2 default 1,
                                         serving_size        int2 default 1,
                                         prep_time_minutes   int2,
                                         cook_time_minutes   int2,
                                         total_time_minutes  int2,
                                         calories_per_serving int2,
                                         tags                jsonb,
                                         instructions        jsonb,
                                         created_at          timestamp default current_timestamp,
                                         updated_at          timestamp default current_timestamp,
                                         primary key (id)
);

comment on column sous_chef_rms.rms_recipe.id                  is 'Recipe id;Recipe ID (PK)';
comment on column sous_chef_rms.rms_recipe.name                is 'Recipe name;Recipe name';
comment on column sous_chef_rms.rms_recipe.description         is 'A brief description of recipe;Recipe description (e.g., "scrambled eggs with tomatoes")';
comment on column sous_chef_rms.rms_recipe.image_url           is 'Finish product image url;URL of finished product image';
comment on column sous_chef_rms.rms_recipe.cuisine_type        is 'The cuisine type of recipe;Cuisine type (e.g., "Sichuan dishes", "Italian noodles")';
comment on column sous_chef_rms.rms_recipe.difficulty_level    is 'The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]';
comment on column sous_chef_rms.rms_recipe.serving_size        is 'The standard serving size;Standard serving size (e.g., for 2 people)';
comment on column sous_chef_rms.rms_recipe.prep_time_minutes   is 'The time cost for preparation;The time cost of preparation process';
comment on column sous_chef_rms.rms_recipe.cook_time_minutes   is 'The time cost for cooking;The time cost of cooking process';
comment on column sous_chef_rms.rms_recipe.total_time_minutes  is 'The time cost in total;The time cost in total';
comment on column sous_chef_rms.rms_recipe.calories_per_serving is 'The estimated calories per one serving size;The estimated calories per one serving size';
comment on column sous_chef_rms.rms_recipe.tags                is 'The tags of recipe;Tags of recipe (e.g., { "tags" : [ "spicy", "low fat" ] })';
comment on column sous_chef_rms.rms_recipe.instructions        is 'The detailed steps for cooking;Cooking steps (e.g., { "steps": [{"step": 1, "text": "cut tomato", "timer_seconds": 0}, {"step": 2, "text": "simmering", "timer_seconds": 300}] })';
comment on column sous_chef_rms.rms_recipe.created_at          is 'The time of creation;Created time';
comment on column sous_chef_rms.rms_recipe.updated_at          is 'The time of update;Updated time';
comment on table  sous_chef_rms.rms_recipe                     is 'rms_recipe;Stores all recipes and the corresponding ingredients.';

create index gk_recipe_cuisine on sous_chef_rms.rms_recipe (cuisine_type asc);
comment on index sous_chef_rms.gk_recipe_cuisine is 'Recipe cuisine type;Cuisine type general index';
create index gk_recipe_tags on sous_chef_rms.rms_recipe (tags asc);
comment on index sous_chef_rms.gk_recipe_tags is 'Recipe tag;GIN supports searching specific tags';

-- 5. 建表：rms_recipe_ingredient
create table sous_chef_rms.rms_recipe_ingredient(
                                                    id             serial      not null,
                                                    recipe_id      int8        not null,
                                                    ingredient_id  int8        not null,
                                                    quantity       decimal(10,2) not null,
                                                    unit           varchar(20) not null,
                                                    processing_note varchar(50),
                                                    optional       boolean default false,
                                                    garnish        boolean default false,
                                                    sort           int2,
                                                    primary key (id)
);

comment on column sous_chef_rms.rms_recipe_ingredient.id            is 'Recipe ingredient id;Recipe ingredient ID (PK)';
comment on column sous_chef_rms.rms_recipe_ingredient.recipe_id     is 'Recipe id;Recipe id (FK, recipe_id -> recipe.id)';
comment on column sous_chef_rms.rms_recipe_ingredient.ingredient_id is 'Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)';
comment on column sous_chef_rms.rms_recipe_ingredient.quantity      is 'Quantity of ingredient;Estimated quantity of ingredients used';
comment on column sous_chef_rms.rms_recipe_ingredient.unit          is 'Unit of ingredients;Unit of ingredients';
comment on column sous_chef_rms.rms_recipe_ingredient.processing_note is 'Processing note;Processing note (e.g., "cut into slices", "remove skins")';
comment on column sous_chef_rms.rms_recipe_ingredient.optional      is 'Is optional;Whether this ingredient is optional';
comment on column sous_chef_rms.rms_recipe_ingredient.garnish       is 'Is garnish;Whether this ingredient is garnish';
comment on column sous_chef_rms.rms_recipe_ingredient.sort          is 'Sort of process;Display order';
comment on table  sous_chef_rms.rms_recipe_ingredient               is 'rms_recipe_ingredient;Store the ingredient compositions of recipes.';

create index gk_recipe_ingredient_recipe_id on sous_chef_rms.rms_recipe_ingredient (recipe_id asc);
comment on index sous_chef_rms.gk_recipe_ingredient_recipe_id is 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
create index gk_recipe_ingredient_ingredient_id on sous_chef_rms.rms_recipe_ingredient (ingredient_id asc);
comment on index sous_chef_rms.gk_recipe_ingredient_ingredient_id is 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';

-- 6. 建表：rms_recipe_kitchenware
create table sous_chef_rms.rms_recipe_kitchenware(
                                                     id            serial      not null,
                                                     recipe_id     int8        not null,
                                                     kitchenware_id int8       not null,
                                                     note          varchar(50),
                                                     primary key (id)
);

comment on column sous_chef_rms.rms_recipe_kitchenware.id            is 'Recipe kitchenware id;Recipe kitchenware ID (PK)';
comment on column sous_chef_rms.rms_recipe_kitchenware.recipe_id     is 'Recipe id;Recipe ID (FK, recipe_id -> recipe.id)';
comment on column sous_chef_rms.rms_recipe_kitchenware.kitchenware_id is 'Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)';
comment on column sous_chef_rms.rms_recipe_kitchenware.note          is 'Note;Note (e.g., "pre-heat to 200 degree centigrade)';
comment on table  sous_chef_rms.rms_recipe_kitchenware               is 'rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.';

create index gk_recipe_kitchenware_recipe_id on sous_chef_rms.rms_recipe_kitchenware (recipe_id asc);
comment on index sous_chef_rms.gk_recipe_kitchenware_recipe_id is 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
create index gk_recipe_kitchenware_kitchenware_id on sous_chef_rms.rms_recipe_kitchenware (kitchenware_id asc);
comment on index sous_chef_rms.gk_recipe_kitchenware_kitchenware_id is 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenware table';

-- ===============================
-- RMS seed data: ingredients
-- ===============================

insert into sous_chef_rms.rms_ingredient
(id, name, category, standard_unit, nutrition_info, storage_advice, image_url)
values
    (1, 'tomato', 'vegetable', 'g',
     '{"calories_per_100g":18, "protein_g":0.9, "carbs_g":3.9, "fat_g":0.2}'::jsonb,
     'Store in the refrigerator crisper; keep away from direct sunlight.',
     null),
    (2, 'egg', 'protein', 'piece',
     '{"calories_per_100g":155, "protein_g":13.0, "carbs_g":1.1, "fat_g":11.0}'::jsonb,
     'Store in the refrigerator; use before expiry date.',
     null),
    (3, 'spring onion', 'vegetable', 'g',
     '{"calories_per_100g":32, "protein_g":1.8, "carbs_g":7.3, "fat_g":0.2}'::jsonb,
     'Keep in the refrigerator, wrapped lightly to avoid drying out.',
     null),
    (4, 'garlic', 'vegetable', 'g',
     '{"calories_per_100g":149, "protein_g":6.4, "carbs_g":33.1, "fat_g":0.5}'::jsonb,
     'Store in a cool, dry and ventilated place; do not refrigerate whole bulbs.',
     null),
    (5, 'spaghetti', 'grain', 'g',
     '{"calories_per_100g":350, "protein_g":12.0, "carbs_g":72.0, "fat_g":1.5}'::jsonb,
     'Store in a dry place at room temperature.',
     null),
    (6, 'olive oil', 'fat', 'ml',
     '{"calories_per_100g":884, "protein_g":0.0, "carbs_g":0.0, "fat_g":100.0}'::jsonb,
     'Keep in a cool, dark place away from heat.',
     null),
    (7, 'parmesan cheese', 'dairy', 'g',
     '{"calories_per_100g":431, "protein_g":38.0, "carbs_g":4.1, "fat_g":29.0}'::jsonb,
     'Refrigerate in an airtight container after opening.',
     null);

-- ===============================
-- RMS seed data: recipes
-- ===============================

insert into sous_chef_rms.rms_recipe
(id, name, description, image_url, cuisine_type,
 difficulty_level, serving_size,
 prep_time_minutes, cook_time_minutes, total_time_minutes,
 calories_per_serving, tags, instructions)
values
    (
        1,
        'Tomato and Egg Stir-fry',
        'Simple Chinese home-style dish with scrambled eggs and juicy tomatoes.',
        null,
        'Chinese',
        1,
        2,
        5, 10, 15,
        320,
        '{"tags":["quick","home_style","budget_friendly"]}'::jsonb,
        '{
          "steps": [
            {"step": 1, "text": "Beat the eggs with a pinch of salt.", "timer_seconds": 0},
            {"step": 2, "text": "Heat oil and scramble the eggs until just set, then remove from the pan.", "timer_seconds": 180},
            {"step": 3, "text": "Stir-fry garlic and tomato until soft and saucy.", "timer_seconds": 240},
            {"step": 4, "text": "Return eggs to the pan, season with salt and sugar, mix well and serve.", "timer_seconds": 60}
          ]
        }'::jsonb
    ),
    (
        2,
        'Garlic Butter Spaghetti',
        'Quick pasta tossed with garlicky butter and parmesan cheese.',
        null,
        'Italian',
        1,
        1,
        10, 12, 22,
        550,
        '{"tags":["quick","comfort_food"]}'::jsonb,
        '{
          "steps": [
            {"step": 1, "text": "Boil spaghetti in salted water until al dente.", "timer_seconds": 600},
            {"step": 2, "text": "In a pan, gently cook minced garlic in butter and olive oil.", "timer_seconds": 240},
            {"step": 3, "text": "Add a splash of pasta water, then toss in the drained spaghetti.", "timer_seconds": 120},
            {"step": 4, "text": "Season with salt, pepper and parmesan, toss and serve immediately.", "timer_seconds": 60}
          ]
        }'::jsonb
    );

-- ===============================
-- RMS seed data: recipe_ingredient
-- ===============================

insert into sous_chef_rms.rms_recipe_ingredient
(id, recipe_id, ingredient_id, quantity, unit,
 processing_note, optional, garnish, sort)
values
    -- Tomato & egg stir-fry
    (1, 1, 2, 3.00, 'piece', 'beaten', false, false, 1),   -- eggs
    (2, 1, 1, 200.00, 'g', 'cut into wedges', false, false, 2), -- tomato
    (3, 1, 3, 10.00, 'g', 'chopped', true, false, 3),      -- spring onion (optional garnish)
    (4, 1, 4, 5.00, 'g', 'minced', true, false, 4),        -- garlic (optional)

    -- Garlic butter spaghetti
    (5, 2, 5, 80.00, 'g', null, false, false, 1),          -- spaghetti
    (6, 2, 4, 4.00, 'g', 'minced', false, false, 2),       -- garlic
    (7, 2, 6, 10.00, 'ml', null, false, false, 3),         -- olive oil
    (8, 2, 7, 15.00, 'g', 'grated', false, true, 4);       -- parmesan as garnish

-- ===============================
-- RMS seed data: recipe_kitchenware
-- 这里 kitchenware_id 先用 1 / 2 占位，
-- 后面可以让负责 IMS 的同学在 ims_kitchenware 里插对应的记录。
-- ===============================

insert into sous_chef_rms.rms_recipe_kitchenware
(id, recipe_id, kitchenware_id, note)
values
    (1, 1, 1, 'Medium non-stick frying pan'),
    (2, 2, 2, 'Pot for boiling pasta'),
    (3, 2, 3, 'Large skillet for tossing pasta');
