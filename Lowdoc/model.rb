require 'sqlite3'
require 'bcrypt'

def getDBItems(source, type)
    if source.class != String
        raise "Error, wrong datatype"
    end
    if type.class != String
        raise "Error, wrong datatype"
    end

    db = SQLite3::Database.new(source)
    db.results_as_hash = true
    case type
    when "processors"
        result = db.execute("SELECT * FROM Processors")
    when "subjects"
        result = db.execute("SELECT * FROM Subjects")
    when "links"
        result = db.execute("SELECT * FROM Links")
    end
    return result
end

def addRecord(source, type, name, content)
    # Validation
    
    db = SQLite3::Database.new(source)
    

end

def deleteRecord(source, type, id)

end