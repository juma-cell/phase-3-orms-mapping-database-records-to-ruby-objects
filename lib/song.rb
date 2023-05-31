class Song
  attr_accessor :id, :name, :album

  def initialize(name:, album:)
    @id = nil
    @name = name
    @album = album
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS songs (id INTEGER PRIMARY KEY, name TEXT, album TEXT)")
  end

  def save
    sql = "INSERT INTO songs (name, album) VALUES (?, ?)"
    DB[:conn].execute(sql, @name, @album)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    id, name, album = row
    Song.new(name: name, album: album).tap { |song| song.id = id }
  end

  def self.all
    sql = "SELECT * FROM songs"
    rows = DB[:conn].execute(sql)
    rows.map { |row| new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    new_from_db(row) if row
  end
end
