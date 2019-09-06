class Dog
    attr_reader :id
    attr_accessor :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
        self
    end

    def self.create(attributes)
        Dog.new(attributes).save
    end

    def self.new_from_db(row)
        Dog.new(
            id: row[0],
            name: row[1],
            breed: row[2]
        )
    end

    def self.find_by_id(id)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first)
    end

    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
        new_dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
        if !new_dog.empty?
            find_by_id(new_dog.first.first)
        else
            create(attributes)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
