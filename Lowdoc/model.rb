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
    
    result = db.execute("SELECT * FROM #{type}")
    return result
end

def fetchInfo(source, type, id, column)
    db = SQLite3::Database.new(source)

    return db.execute("SELECT #{column} FROM #{type} WHERE id = ?", id)
end

def addRecord(source, type, name, content)
    # Validation

    #----------
    
    db = SQLite3::Database.new(source)
    
    case type
    when "Processors"
        db.execute("INSERT INTO #{type} (name) VALUES (?)",name)

        if content != nil
            id = db.execute("SELECT id FROM #{type} ORDER BY id DESC LIMIT 1")
            textfile = File.new("text/processors/#{id}.txt", "w+")
            textfile.syswrite(content)
        end
    when "Subjects"
        db.execute("INSERT INTO #{type} (name) VALUES (?)",name)

        if content != nil
            id = db.execute("SELECT id FROM #{type} ORDER BY id DESC LIMIT 1")
            textfile = File.new("text/subjects/#{id}.txt", "w+")
            textfile.syswrite(content)
        end
    when "Links"
        db.execute("INSERT INTO #{type} (name,source) VALUES (?,?)",name,content)

    end

end

def deleteRecord(source, type, id)
    db = SQLite3::Database.new(source)

    db.execute("DELETE FROM #{type} WHERE id = ?", id)

    # Relational table deletion
    case type
    when "Processors"
        db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE processor_id = ?", id)
    when "Subjects"
        db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE subject_id = ?", id)
    when "Links"
        db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE link_id = ?", id)
    end
end

def updateRecord(source, type, id, name, content)
    db = SQLite3::Database.new(source)
    
    case type
    when "Processors"
        db.execute("UPDATE #{type} SET name = ? WHERE id = ?", name, id)

        if content != nil
            textfile = File.new("text/processors/[[#{id}]].txt", "w+")
            textfile.syswrite(content)
        end
    when "Subjects"
        db.execute("INSERT INTO #{type} (name) VALUES (?)",name)
    when "Links"
        db.execute("INSERT INTO #{type} (name,source) VALUES (?,?)",name,content)

    end
end