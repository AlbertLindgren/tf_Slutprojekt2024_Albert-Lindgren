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

#Processors
get('/processors') do
    result = getDBItems('db/lowdoc.db', 'Processors')
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
    redirect('/processors')
end

post('/processors/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Processors', id)
    redirect('/processors')
end

#Subjects
get('/subjects') do
    result = getDBItems('db/lowdoc.db', 'Subjects')
    slim(:"subjects/index", locals:{subjects:result})
end

get('/subjects/:id/show') do

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
    redirect('/subjects')
end

post('/subjects/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Subjects', id)
    redirect('/subjects')
end

#Searching and links
get('/links') do
    result = getDBItems('db/lowdoc.db', 'Links')
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
    redirect('/links')
end

post('/links/:id/delete') do
    id = params[:id]
    deleteRecord('db/lowdoc.db', 'Links', id)
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

post('/accounts/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if password != password_confirm
        redirect('/accounts/register')
    end

    if !registerAccount('db/lowdoc.db', username, password)
        # Do something with sessions here, and maybe sinatra-flash
        redirect('/accounts/register')
    end

    redirect('/')
end

post('/accounts/login') do
    username = params[:username]
    password = params[:password]

    if login('db/lowdoc.db', username, password)
       session[:user_id] = fetchUserId('db/lowdoc.db', username)
       session[:user_privilege] = fetchPrivilege('db/lowdoc.db', session[:user_id])
       session[:username] = username
       session[:logged_in] = true
    else
        redirect('/accounts/login')
    end

    redirect('/')
end