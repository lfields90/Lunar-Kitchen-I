
require_relative "ingredient"
class Recipe

  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @name = name
    @id = id
    @instructions = instructions
    @description = description
  end

  def ingredients
    ingredient = self.class.db_connection do |conn|
      conn.exec("SELECT ingredients.name FROM ingredients
                JOIN recipes ON (recipe_id = recipes.id)
                WHERE #{@id} = recipes.id")
    end.to_a

    stuff = []
    ingredient.each do |name|
      stuff << Ingredient.new(name['name'])
    end
    stuff
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    recipes = db_connection do |conn|
      conn.exec("SELECT * FROM recipes")
    end.to_a

    recipes.map! { |recipe| Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"]) }
    recipes
  end

  def self.find(recipe_id)
    #this is not returning anything that can be iterated through
    #that is why it cannot find the text in the object, bc it is empty
    #we have to find a way to connect the id to the (name?)

    recipe = db_connection do |conn|
      conn.exec("SELECT * FROM recipes WHERE id = #{recipe_id.to_i}")
    end.to_a.first
    Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"])
  end

end
