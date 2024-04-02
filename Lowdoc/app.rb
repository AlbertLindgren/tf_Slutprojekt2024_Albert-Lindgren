require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/flash'

require_relative "model.rb"

# Hashes containing text for procesors and subjects, ids used as keys
#processors_desc = Hash.new
#subjects_desc = Hash.new
# Save paths to text, '/public/text/processors/1.txt'

enable :sessions

get('/') do
    slim(:index)
end

# CRUD
#---------------------------------------------------
# Before block

before('/processors/new') do 
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/processors')
    end
end
before('/processors/:id/edit') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/processors')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Processors', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/processors')
    end
end
before('/processors/:id/delete') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/processors')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Processors', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/processors')
    end
end

before('/subjects/new') do 
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/subjects')
    end
end
before('/subjects/:id/edit') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/subjects')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Subjects', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/subjects')
    end
end
before('/subject/:id/delete') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/subject')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Subjects', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/subject')
    end
end

before('/links/new') do 
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/links')
    end
end
before('/links/:id/edit') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/links')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Links', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/links')
    end
end
before('/links/:id/delete') do 
    id = params[:id]
    if session[:logged_in] != true
        flash[:not_logged_in] = "You need to be logged in to perform this action"
        redirect('/links')
    end
    if session[:user_privilege] != "admin" && session[:user_privilege] != "owner" && !(checkUserAccess('db/lowdoc.db', 'Links', session[:user_id], id))
        flash[:unauthorized] = "You are not authorized to perform this action"
        redirect('/links')
    end
end

#Processors
get('/processors') do

    result = getDBItems('db/lowdoc.db', 'Processors')
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')
    @links = getDBItems('db/lowdoc.db', 'Links')

    slim(:"processors/index", locals:{processors:result})
end

get('/processors/:id/show') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Processors', @id, 'name')
    # Fetch description text
    @content = fetchText('Processors', @id)
    slim(:"processors/show")
end

get('/processors/new') do
    slim(:"processors/new")
end

get('/processors/:id/edit') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Processors', @id, 'name')
    #@content = fetchInfo('db/lowdoc.db', 'Processors', @id, 'content')

    # Fetch description text
    @content = fetchText('Processors', @id)

    # Get relational info
    @relSubjects = getDBItemsWithRelId('db/lowdoc.db', 'Processors', 'subject_id', @id)
    @relLinks = getDBItemsWithRelId('db/lowdoc.db', 'Processors', 'link_id', @id)
    # Id lists for checkbox
    @relSubjectsIdList = []
    @relSubjects.each do |subject|
        @relSubjectsIdList.append(subject["id"])
    end
    @relLinksIdList = []
    @relLinks.each do |link|
        @relLinksIdList.append(link["id"])
    end

    @subjects = getDBItems('db/lowdoc.db', 'Subjects')
    @links = getDBItems('db/lowdoc.db', 'Links')

    slim(:"processors/edit")
end

post('/processors/:id/update') do
    id = params[:id]
    name = params[:name]
    content = params[:content]

    # Get ids of the related items
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')
    @links = getDBItems('db/lowdoc.db', 'Links')

    relSubjects = []
    relLinks = []
    params.each_key {|key|
        if key.class == String
            @subjects.each do |subject|
                if subject["name"] == key
                    relSubjects.append(subject["id"])
                end
            end
            @links.each do |link|
                if link["name"] == key
                    relLinks.append(link["id"])
                end
            end
        end
    }

    updateRecord('db/lowdoc.db', 'Processors', id, name, content, relSubjects, relLinks)
    redirect('/processors')
end

post('/processors/new') do
    name = params[:name]
    content = params[:content]

    addRecord('db/lowdoc.db', 'Processors', name, content)
    addUserRelation('db/lowdoc.db', 'Processors', session[:user_id])
    redirect('/processors')
end

post('/processors/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Processors', id)
    redirect('/processors')
end

post('/processors/filter') do
    session[:filteredProcessors] = []
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')
    @links = getDBItems('db/lowdoc.db', 'Links')

    chosenSubjects = []
    chosenLinks = []
    params.each_key {|key|
        if key.class == String
            @subjects.each do |subject|
                if subject["name"] == key
                    chosenSubjects.append(subject["id"])
                end
            end
            @links.each do |link|
                if link["name"] == key
                    chosenLinks.append(link["id"])
                end
            end
        end
    }
    p "ewufhwe"
    p chosenSubjects
    p "jewfiuwh"
    p chosenLinks

    @filteredProcessors = getFilteredItems('db/lowdoc.db', 'Processors', chosenSubjects, chosenLinks)
    p "fpåfe"
    p @filteredProcessors
    session[:chosenSubjects] = chosenSubjects
    session[:chosenLinks] = chosenLinks

    # Make it one dimensional
    @filteredProcessors.each do |x|
        session[:filteredProcessors].append(x[0])
    end
    p session[:filteredProcessors]

    redirect('/processors')
end

post('/processors/filter/clear') do
    session[:filteredProcessors] = nil
    session[:chosenSubjects] = nil
    session[:chosenLinks] = nil
    redirect('/processors')
end

#Subjects
get('/subjects') do
    result = getDBItems('db/lowdoc.db', 'Subjects')
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @links = getDBItems('db/lowdoc.db', 'Links')

    slim(:"subjects/index", locals:{subjects:result})
end

get('/subjects/:id/show') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Subjects', @id, 'name')
    # Fetch description text
    @content = fetchText('Subjects', @id)
    slim(:"subjects/show")
end

get('/subjects/new') do
    slim(:"subjects/new")
end

get('/subjects/:id/edit') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Subjects', @id, 'name')

    # Fetch description text
    @content = fetchText('Subjects', @id)

    # Get relational info
    @relProcessors = getDBItemsWithRelId('db/lowdoc.db', 'Subjects', 'processor_id', @id)
    @relLinks = getDBItemsWithRelId('db/lowdoc.db', 'Subjects', 'link_id', @id)
    # Id lists for checkbox
    @relProcessorsIdList = []
    @relProcessors.each do |processor|
        @relProcessorsIdList.append(processor["id"])
    end
    @relLinksIdList = []
    @relLinks.each do |link|
        @relLinksIdList.append(link["id"])
    end

    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @links = getDBItems('db/lowdoc.db', 'Links')

    slim(:"subjects/edit")
end

post('/subjects/:id/update') do
    id = params[:id]
    name = params[:name]
    content = params[:content]

    # Get ids of the related items
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @links = getDBItems('db/lowdoc.db', 'Links')

    relProcessors = []
    relLinks = []
    params.each_key {|key|
        if key.class == String
            @processors.each do |processor|
                if processor["name"] == key
                    relProcessors.append(processor["id"])
                end
            end
            @links.each do |link|
                if link["name"] == key
                    relLinks.append(link["id"])
                end
            end
        end
    }

    updateRecord('db/lowdoc.db', 'Subjects', id, name, content, relProcessors, relLinks)
    redirect('/subjects')
end

post('/subjects/new') do
    name = params[:name]
    content = params[:content]

    addRecord('db/lowdoc.db', 'Subjects', name, content)
    addUserRelation('db/lowdoc.db', 'Subjects', session[:user_id])
    redirect('/subjects')
end

post('/subjects/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Subjects', id)
    redirect('/subjects')
end

post('/subjects/filter') do
    session[:filteredSubjects] = []
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @links = getDBItems('db/lowdoc.db', 'Links')

    chosenProcessors = []
    chosenLinks = []
    params.each_key {|key|
        if key.class == String
            @processors.each do |processor|
                if processor["name"] == key
                    chosenProcessors.append(processor["id"])
                end
            end
            @links.each do |link|
                if link["name"] == key
                    chosenLinks.append(link["id"])
                end
            end
        end
    }

    @filteredSubjects = getFilteredItems('db/lowdoc.db', 'Subjects', chosenProcessors, chosenLinks)
    session[:chosenProcessors] = chosenProcessors
    session[:chosenLinks] = chosenLinks

    # Make it one dimensional
    @filteredSubjects.each do |x|
        session[:filteredSubjects].append(x[0])
    end

    redirect('/subjects')
end

post('/subjects/filter/clear') do
    session[:filteredSubjects] = nil
    session[:chosenProcessors] = nil
    session[:chosenLinks] = nil
    redirect('/subjects')
end

#Searching and links
get('/links') do
    result = getDBItems('db/lowdoc.db', 'Links')
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')

    slim(:"links/index", locals:{links:result})
end

get('/links/new') do
    slim(:"links/new")
end

get('/links/:id/edit') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Links', @id, 'name')
    @source = fetchInfo('db/lowdoc.db', 'Links', @id, 'source')

    # Get relational info
    @relProcessors = getDBItemsWithRelId('db/lowdoc.db', 'Links', 'processor_id', @id)
    @relSubjects = getDBItemsWithRelId('db/lowdoc.db', 'Links', 'subject_id', @id)
    # Id lists for checkbox
    @relProcessorsIdList = []
    @relProcessors.each do |processor|
        @relProcessorsIdList.append(processor["id"])
    end
    @relSubjectsIdList = []
    @relSubjects.each do |subject|
        @relSubjectsIdList.append(subject["id"])
    end

    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')

    slim(:"links/edit")
end

post('/links/:id/update') do
    id = params[:id]
    name = params[:name]
    source = params[:source]

    # Get ids of the related items
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')

    relProcessors = []
    relSubjects = []
    params.each_key {|key|
        if key.class == String
            @processors.each do |processor|
                if processor["name"] == key
                    relProcessors.append(processor["id"])
                end
            end
            @subjects.each do |subject|
                if subject["name"] == key
                    relSubjects.append(subject["id"])
                end
            end
        end
    }

    updateRecord('db/lowdoc.db', 'Links', id, name, source, relProcessors, relSubjects)
    redirect('/links')
end

post('/links/new') do
    name = params[:name]
    source = params[:source]

    addRecord('db/lowdoc.db', 'Links', name, source)
    addUserRelation('db/lowdoc.db', 'Links', session[:user_id])
    redirect('/links')
end

post('/links/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Links', id)
    redirect('/links')
end

post('/links/filter') do
    session[:filteredLinks] = []
    @processors = getDBItems('db/lowdoc.db', 'Processors')
    @subjects = getDBItems('db/lowdoc.db', 'Subjects')

    chosenProcessors = []
    chosenSubjects = []
    params.each_key {|key|
        if key.class == String
            @processors.each do |processor|
                if processor["name"] == key
                    chosenProcessors.append(processor["id"])
                end
            end
            @subjects.each do |subject|
                if subject["name"] == key
                    chosenSubjects.append(subject["id"])
                end
            end
        end
    }

    @filteredLinks = getFilteredItems('db/lowdoc.db', 'Links', chosenProcessors, chosenSubjects)
    session[:chosenProcessors] = chosenProcessors
    session[:chosenSubjects] = chosenSubjects

    # Make it one dimensional
    @filteredLinks.each do |x|
        session[:filteredLinks].append(x[0])
    end

    redirect('/links')
end

post('/links/filter/clear') do
    session[:filteredLinks] = nil
    session[:chosenProcessors] = nil
    session[:chosenSubjects] = nil
    redirect('/links')
end

# End of CRUD
#-----------------------------------------------------------

# Accounts

get('/accounts/register') do


    slim(:"/accounts/register")
end

get('/accounts/login') do
    

    slim(:"/accounts/login")
end

get('/accounts/show') do
    

    slim(:"/accounts/show")
end

post('/accounts/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if password != password_confirm
        flash[:unconfirmed_password] = "The passwords do not match."
        redirect('/accounts/register')
    end

    if registerAccount('db/lowdoc.db', username, password)
        session[:user_id] = fetchUserId('db/lowdoc.db', username)
        session[:user_privilege] = fetchPrivilege('db/lowdoc.db', session[:user_id])
        session[:username] = username
        session[:logged_in] = true
        flash[:registered] = "Registered and logged in"
    else
        # Do something with sessions here, and maybe sinatra-flash
        flash[:failed_registration] = "Username already taken"
        redirect('/accounts/register')
    end

    redirect('/')
end

users = []
User = Struct.new(:ip_address, :time, :attempts)
cooldownTime = nil
cooldown = false

post('/accounts/login') do
    # Limit login attempts to less than 10 attempts every three minutes
    i = 0
    index = 0
    if users != []
        users.each do |user|
            if user.ip_address == request.ip
                index = i
            end
            i += 1
        end
        if users[index] == nil
            users.append(User.new(request.ip, Time.now, 0))
            index = users.length() - 1
        end
    else
        users[index] = User.new(request.ip, Time.now, 0)
        users.append(users[index])
    end

    if cooldownTime != nil && (Time.now - cooldownTime) >= 600
        users[index].time = Time.now
        users[index].attempts = 1
        cooldownTime = nil
    end

    if (Time.now - users[index].time) <= 180 && users[index].attempts <= 10
        users[index].attempts += 1
    elsif (Time.now - users[index].time) <= 180 && users[index].attempts >= 10 && !cooldown
        cooldownTime = Time.now
        cooldown = true
        flash[:too_many_login_attempts] = "Exceeded attempt limit, try again in 10 minutes"
        redirect('/accounts/login')
    end

    p "Login status"
    p users[index].attempts
    p Time.now - users[index].time

    username = params[:username]
    password = params[:password]
    
    if login('db/lowdoc.db', username, password)
       session[:user_id] = fetchUserId('db/lowdoc.db', username)
       session[:user_privilege] = fetchPrivilege('db/lowdoc.db', session[:user_id])
       session[:username] = username
       session[:logged_in] = true
       flash[:login] = "Logged in"
    elsif cooldownTime != nil && (Time.now - cooldownTime) <= 600
        flash[:try_again_later] = "Try again later"
        redirect('/accounts/login')
    else
        flash[:failed_login] = "Wrong information"
        redirect('/accounts/login')
    end

    redirect('/')
end

post('/accounts/logout') do
    session.clear
    session[:logged_in] = false
    flash[:logout] = "Logged out"
    redirect('/')
end

# User management
get('/protected/users/index') do
    @owner = getColumn('db/lowdoc.db', "Users", "privilege", "owner")[0]
    @admins = getColumn('db/lowdoc.db', "Users", "privilege", "admin")
    @users = getColumn('db/lowdoc.db', "Users", "privilege", "user")

    slim(:"/protected/users/index")
end

get('/protected/users/:id/show') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', "Users", @id, "username")[0]

    slim(:"/protected/users/show")
end

post('/protected/users/:id/update') do
    

    redirect('/protected/users/index')
end

post('/protected/users/:id/delete') do
    id = params[:id]
    
    deleteRecord('db/lowdoc.db', "Users", id)

    redirect('/protected/users/index')
end