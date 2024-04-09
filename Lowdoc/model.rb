require 'sqlite3'
require 'bcrypt'
require 'time'

module Model

    # Helper functions
	
	# Returns file as a string
    #
    # @param [String] filename Filename/filepath
    #
    # @return [String] String containing the file data
    def get_file_as_string(filename)
        if filename.class != String
            raise "Error, wrong datatype"
        end
        
        data = ''
        f = File.open(filename, "r")
        f.each_line do |line|
        data += line
        end
        return data
    end

    # Returns database items from specified table
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    #
    # @return [Hash] Hash containing the items
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

    # Returns records with specified column value from specified table
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [String] column Relevant column in table
    # @param [String, Integer] requestedValue Requested value for the specified column
    #
    # @return [Hash] Hash containing the items
    def getColumn(source, type, column, requestedValue)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
        if column.class != String
            raise "Error, wrong datatype"
        end

        db = SQLite3::Database.new(source)
        db.results_as_hash = true

        result = db.execute("SELECT * FROM #{type} WHERE #{column} = ?", requestedValue)
        return result
    end

    # Returns records of the requested type with relation to specified ID of another type
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [String] requestedType The requested related table
    # @param [Integer] id ID of the item whose relations are requested
    #
    # @return [Hash] Hash containing the items
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

    # Returns specified column value of record with specified id and type
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [Integer] id ID of the relevant record
    # @param [String] column The wanted column
    #
    # @return [Array] Requested column value in array form
    def fetchInfo(source, type, id, column)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
        if column.class != String
            raise "Error, wrong datatype"
        end
        
        db = SQLite3::Database.new(source)

        return db.execute("SELECT #{column} FROM #{type} WHERE id = ?", id)
    end

    # Returns id of the user related to the specified record of specified type
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [Integer] id Id of the relevant record
    #
    # @return [Array] Requested user ID in array form
    def fetchUserRelationalInfo(source, type, id)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
        
        db = SQLite3::Database.new(source)
        case type
        when "Processors"
            return db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE processor_id = ?", id)
        when "Subjects"
            return db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE subject_id = ?", id)
        when "Links"
            return db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE link_id = ?", id)
        end
    end

    # Returns the text that belongs to the record of specified ID and type
    #
    # @param [String] type Relevant table
    # @param [Integer] id Id of the relevant record
    #
    # @return [String] Requested text as a string
    def fetchText(type, id)
        if type.class != String
            raise "Error, wrong datatype"
        end

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

    # Creates a new record in specified table (type) and set name and either text or link depending on the type
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [String] name Name in the new record
    # @param [String] content Text or link depending on type
    # @option content [String] Text of the created record
    # @option content [String] Link of the created link-record
    #
    # @return [nil] Nothing
    def addRecord(source, type, name, content)
        # Validation
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
        if name.class != String
            raise "Error, wrong datatype"
        end
        if content.class != String
          raise "Error, wrong datatype"
        end
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

    # Deletes the record specified by type (table) and ID
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [Integer] id ID of the record to delete
    #
    # @return [nil] Nothing
    def deleteRecord(source, type, id)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end

        db = SQLite3::Database.new(source)

        db.execute("DELETE FROM #{type} WHERE id = ?", id)

        # Relational table deletion
        case type
        when "Processors"
            db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE processor_id = ?", id)
            db.execute("DELETE FROM Users_Processors_Subjects_Links_Rel WHERE processor_id = ?", id)
        when "Subjects"
            db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE subject_id = ?", id)
            db.execute("DELETE FROM Users_Processors_Subjects_Links_Rel WHERE subject_id = ?", id)
        when "Links"
            db.execute("DELETE FROM Processors_Subjects_Links_Rel WHERE link_id = ?", id)
            db.execute("DELETE FROM Users_Processors_Subjects_Links_Rel WHERE link_id = ?", id)
        when "Users"
            db.execute("DELETE FROM Users_Processors_Subjects_Links_Rel WHERE user_id = ?", id)
        end
    end

    # Updates the record specified by type (table) and ID
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [Integer] id ID of the record to update
    # @param [String] name New name of the record
    # @param [String] content New text or link, depending on type
    # @param [Array] relProcOrSub Array of ID:s of either related Processors or related Subjects, depending on type
    # @param [Array] relLinkOrSub Array of ID:s of either related Links or related Subjects, depending on type
    # @option content [String] Text if type is either Processors or Subjects
    # @option content [String] Link if type is Links
    #
    # @return [nil] Nothing
    def updateRecord(source, type, id, name, content, relProcOrSub, relLinkOrSub)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
        if name.class != String
          raise "Error, wrong datatype"
        end
        if content.class != String
            raise "Error, wrong datatype"
        end
        if relProcOrSub.class != String
            raise "Error, wrong datatype"
        end
        if relLinkOrSub.class != String
            raise "Error, wrong datatype"
        end

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
            db.execute("UPDATE #{type} SET source = ? WHERE id = ?", content, id)

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

    # Returns the items that were filtered with related items from other tables (relProcOrSub and relLinkOrSub)
    #
    # @param [String] source Path to database
    # @param [String] type Relevant table
    # @param [Array] relProcOrSub Array of ID:s of either requested Processors or requested Subjects, depending on type
    # @param [Array] relLinkOrSub Array of ID:s of either requested Links or requested Subjects, depending on type
    #
    # @return [Array] Array of filtered items
    def getFilteredItems(source, type, relProcOrSub, relLinkOrSub)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end

        db = SQLite3::Database.new(source)
        case type
        when "Processors"
            filteredProcessors = []
            processors = db.execute("SELECT DISTINCT processor_id FROM Processors_Subjects_Links_Rel")

            processors.each do |processor_id|
                relProcOrSub.each do |subject_id|
                    if db.execute("SELECT processor_id FROM Processors_Subjects_Links_Rel WHERE subject_id = ?", subject_id).include?(processor_id)
                        filteredProcessors.append(processor_id)
                    end
                end
                
                relLinkOrSub.each do |link_id|
                    if db.execute("SELECT processor_id FROM Processors_Subjects_Links_Rel WHERE link_id = ?", link_id).include?(processor_id)
                        filteredProcessors.append(processor_id)
                    end
                end
            end
            return filteredProcessors.uniq
        when "Subjects"
            filteredSubjects = []
            subjects = db.execute("SELECT DISTINCT subject_id FROM Processors_Subjects_Links_Rel")

            subjects.each do |subject_id|
                relProcOrSub.each do |processor_id|
                    if db.execute("SELECT subject_id FROM Processors_Subjects_Links_Rel WHERE processor_id = ?", processor_id).include?(subject_id)
                        filteredSubjects.append(subject_id)
                    end
                end
                
                relLinkOrSub.each do |link_id|
                    if db.execute("SELECT subject_id FROM Processors_Subjects_Links_Rel WHERE link_id = ?", link_id).include?(subject_id)
                        filteredSubjects.append(subject_id)
                    end
                end
            end

            return filteredSubjects.uniq
        when "Links"
            filteredLinks = []
            links = db.execute("SELECT DISTINCT link_id FROM Processors_Subjects_Links_Rel")

            links.each do |link_id|
                relProcOrSub.each do |processor_id|
                    if db.execute("SELECT link_id FROM Processors_Subjects_Links_Rel WHERE processor_id = ?", processor_id).include?(link_id)
                        filteredLinks.append(link_id)
                    end
                end
                
                relLinkOrSub.each do |subject_id|
                    if db.execute("SELECT link_id FROM Processors_Subjects_Links_Rel WHERE subject_id = ?", subject_id).include?(link_id)
                        filteredLinks.append(link_id)
                    end
                end
            end

            return filteredLinks.uniq
        end

    end

    #---------------------------------------------
    # Accounts

    # Registers an account
    #
    # @param [String] source Path to database
    # @param [String] username Username to set
    # @param [String] password Password to set
    #
    # @return [true,false] True if succesful, otherwise false
    def registerAccount(source, username, password)
        if source.class != String
            raise "Error, wrong datatype"
        end
        
        db = SQLite3::Database.new(source)
        # Validation
        if username.class != String
            raise "Error, wrong type for username"
        end
        if password.class != String
            raise "Error, wrong type for password"
        end

        # Check if account already exists
        result = db.execute("SELECT id FROM Users WHERE username=?", username)

        # Create password hash with Bcrypt
        if result.empty?
            password_digest = BCrypt::Password.create(password)
            db.execute("INSERT INTO Users
                (username, password_digest, privilege) VALUES (?,?,'user')", username, password_digest)
                return true
        else
            puts "Error, account already exists"
            return false
        end
    end

    # Logs in a user
    #
    # @param [String] source Path to database
    # @param [String] username Username to check
    # @param [String] password Password to check
    #
    # @return [true,false] True if succesful, otherwise false
    def login(source, username, password)
        if source.class != String
            raise "Error, wrong datatype"
        end

        db = SQLite3::Database.new(source)
        # Validation
        if username.class != String
            raise "Error, wrong type for username"
        end
        if password.class != String
            raise "Error, wrong type for password"
        end

        # Check if account exists
        result = db.execute("SELECT id FROM Users WHERE username=?", username)

        if !(result.empty?)
            password_digest = (db.execute("SELECT password_digest FROM Users WHERE username=?", username))[0][0]
            if BCrypt::Password.new(password_digest) == password
                return true
            else
                return false
            end
        end

    end

    # Fetches the ID of a user specified by username
    #
    # @param [String] source Path to database
    # @param [String] username Username to check
    # @param [String] password Password to check
    #
    # @return [Array] The requested user ID
    def fetchUserId(source, username)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if username.class != String
            raise "Error, wrong datatype"
        end
        db = SQLite3::Database.new(source)
        return db.execute("SELECT id FROM Users WHERE username=?", username)[0][0]
    end

    # Fetches the privilege of a user specified by ID
    #
    # @param [String] source Path to database
    # @param [Integer] id ID of requested user
    #
    # @return [Array] The requested user ID
    def fetchPrivilege(source, id)
        if source.class != String
            raise "Error, wrong datatype"
        end
 
        db = SQLite3::Database.new(source)
        return db.execute("SELECT privilege FROM Users WHERE id=?", id)[0][0]
    end

    # Adds a relation between a user and a record from another table
    #
    # @param [String] source Path to database
    # @param [String] type Requested table to add a relation to
    # @param [Integer] user_id ID of requested user
    #
    # @return [nil] Nothing
    def addUserRelation(source, type, user_id)
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end
 
        db = SQLite3::Database.new(source)
        # Validation

        case type
        when "Processors"
            processor_id = db.execute("SELECT id FROM Processors ORDER BY id DESC LIMIT 1")[0][0]
            db.execute("INSERT INTO Users_Processors_Subjects_Links_Rel (user_id,processor_id) VALUES (?,?)", user_id, processor_id)
        when "Subjects"
            subject_id = db.execute("SELECT id FROM Subjects ORDER BY id DESC LIMIT 1")[0][0]
            db.execute("INSERT INTO Users_Processors_Subjects_Links_Rel (user_id,subject_id) VALUES (?,?)", user_id, subject_id)
        when "Links"
            link_id = db.execute("SELECT id FROM Links ORDER BY id DESC LIMIT 1")[0][0]
            db.execute("INSERT INTO Users_Processors_Subjects_Links_Rel (user_id,link_id) VALUES (?,?)", user_id, link_id)
        end
    end

    # Checks whether the requested record belongs to the user specified by user_id
    #
    # @param [String] source Path to database
    # @param [String] type Table with the relevant record
    # @param [Integer] user_id ID of relevant user
    # @param [Integer] related_id ID of relevant record
    #
    # @return [true,false] True if the record belongs to the user, otherwise false
    def checkUserAccess(source, type, user_id, related_id)
        # Validation
        if source.class != String
            raise "Error, wrong datatype"
        end
        if type.class != String
            raise "Error, wrong datatype"
        end

        db = SQLite3::Database.new(source)
 
        case type
        when "Processors"
            test_user_id = db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE processor_id=?", related_id)[0][0]
            if user_id == test_user_id
                return true
            else
                return false
            end
        when "Subjects"
            test_user_id = db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE subject_id=?", related_id)[0][0]
            if user_id == test_user_id
                return true
            else
                return false
            end
        when "Links"
            test_user_id = db.execute("SELECT user_id FROM Users_Processors_Subjects_Links_Rel WHERE link_id=?", related_id)[0][0]
            if user_id == test_user_id
                return true
            else
                return false
            end
        end

        return false
    end

    # Updates account details
    #
    # @param [String] source Path to database
    # @param [Integer] user_id ID of relevant user
    # @param [String] username New username
    # @param [String] password New password
    #
    # @return [true,false] True if the change was succesful, otherwise false
    def updateAccount(source, user_id, username, password)
        # Validation
        if source.class != String
            raise "Error, wrong datatype"
        end
        if username.class != String
            raise "Error, wrong datatype"
        end
        if username.class != String
            raise "Error, wrong type for username"
        end
        if password.class != String
            raise "Error, wrong type for password"
        end

        db = SQLite3::Database.new(source)
        
        # Check if account already exists
        result = db.execute("SELECT id FROM Users WHERE username=? AND NOT id = ?", username, user_id)

        # Create password hash with Bcrypt
        if result.empty?
            password_digest = BCrypt::Password.create(password)
            db.execute("UPDATE Users SET username = ?, password_digest = ? WHERE id = ?", username, password_digest, user_id)
            return true
        else
            puts "Error, account name is taken"
            return false
        end
    end
end
