require 'sqlite3'
require 'bcrypt'

# Helper functions
def get_file_as_string(filename)
    data = ''
    f = File.open(filename, "r")
    f.each_line do |line|
      data += line
    end
    return data
  end

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

def getDBItemsWithRelId(source, type, requestedType, id)
    if source.class != String
        raise "Error, wrong datatype"
    end
    if type.class != String
        raise "Error, wrong datatype"
    end
    if requestedType.class != String
        raise "Error, wrong datatype"
    end
  #  if id.class != Integer
   #     raise "Error, wrong datatype"
   # end

    db = SQLite3::Database.new(source)
    db.results_as_hash = true

    # Get all ids from relational table with the id parameter
    case type
    when "Processors"
        relationalResult = db.execute("SELECT DISTINCT #{requestedType} FROM Processors_Subjects_Links_Rel
        WHERE processor_id = ? AND #{requestedType} IS NOT NULL", id)
    when "Subjects"
        relationalResult = db.execute("SELECT DISTINCT #{requestedType} FROM Processors_Subjects_Links_Rel
        WHERE subject_id = ? AND #{requestedType} IS NOT NULL", id)
    when "Links"
        relationalResult = db.execute("SELECT DISTINCT #{requestedType} FROM Processors_Subjects_Links_Rel
        WHERE link_id = ? AND #{requestedType} IS NOT NULL", id)
    end

    result = []

    case requestedType
    when "processor_id"
        relationalResult.each do |processor|
            result.append(db.execute("SELECT name, id FROM Processors
                WHERE id = ?", processor["processor_id"])[0])
        end
        return result
    when "subject_id"
        relationalResult.each do |subject|
            result.append(db.execute("SELECT name, id FROM Subjects
                WHERE id = ?", subject["subject_id"])[0])
        end
        return result
    when "link_id"
        relationalResult.each do |link|
            result.append(db.execute("SELECT name, id, source FROM Links
                WHERE id = ?", link["link_id"])[0])
        end
        return result
    end

end

def fetchInfo(source, type, id, column)
    db = SQLite3::Database.new(source)

    return db.execute("SELECT #{column} FROM #{type} WHERE id = ?", id)
end

def fetchText(type, id)

    case type
    when "Processors"
        if (File.file?("text/processors/[[#{id}]].txt"))
            return get_file_as_string("text/processors/[[#{id}]].txt")
        end
    when "Subjects"
        if (File.file?("text/subjects/[[#{id}]].txt"))
            return get_file_as_string("text/subjects/[[#{id}]].txt")
        end
    end
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

def updateRecord(source, type, id, name, content, relProcOrSub, relLinkOrSub)
    db = SQLite3::Database.new(source)

    case type
    when "Processors"
        db.execute("UPDATE #{type} SET name = ? WHERE id = ?", name, id)

        if content != nil
            textfile = File.new("text/processors/[[#{id}]].txt", "w+")
            textfile.syswrite(content)
        end

        db.execute("DELETE FROM Processors_Subjects_Links_Rel
            WHERE processor_id = ?", id)

        # For subjects
        relProcOrSub.each do |relId|
            # Add relations to subjects
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (processor_id, subject_id) VALUES (?,?)", id, relId)
        end
        # For links
        relLinkOrSub.each do |relId|
            # Add relations to links
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (processor_id, link_id) VALUES (?,?)", id, relId)
        end

    when "Subjects"
        db.execute("UPDATE #{type} SET name = ? WHERE id = ?", name, id)

        if content != nil
            textfile = File.new("text/subjects/[[#{id}]].txt", "w+")
            textfile.syswrite(content)
        end

        db.execute("DELETE FROM Processors_Subjects_Links_Rel
            WHERE subject_id = ?", id)

        # For processors
        relProcOrSub.each do |relId|
            # Add relations to processors
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (subject_id, processor_id) VALUES (?,?)", id, relId)
        end
        # For links
        relLinkOrSub.each do |relId|
            # Add relations to links
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (subject_id, link_id) VALUES (?,?)", id, relId)
        end
    when "Links"
        db.execute("UPDATE #{type} SET name = ? WHERE id = ?", name, id)
        db.execute("UPDATE #{type} SET source = ? WHERE id = ?", source, id)

        db.execute("DELETE FROM Processors_Subjects_Links_Rel
            WHERE link_id = ?", id)

        # For processors
        relProcOrSub.each do |relId|
            # Add relations to processors
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (link_id, processor_id) VALUES (?,?)", id, relId)
        end
        # For subjects
        relLinkOrSub.each do |relId|
            # Add relations to subjects
            db.execute("INSERT INTO Processors_Subjects_Links_Rel
            (link_id, subject_id) VALUES (?,?)", id, relId)
        end
    end

end
