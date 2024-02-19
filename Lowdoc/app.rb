require 'sinatra'
require 'slim'
require 'sqlite3'
require_relative "model.rb"

# Hashes containing text for procesors and subjects, ids used as keys
#processors_desc = Hash.new
#subjects_desc = Hash.new
# Save paths to text, '/public/text/processors/1.txt'

enable :sessions

get('/') do
    slim(:index)
end

#Processors
get('/processors') do
    result = getDBItems('db/lowdoc.db', 'processors')
    slim(:"processors/index", locals:{processors:result})
end

get('/processors/:id/show') do

end

get('/processors/new') do
    slim(:"processors/new")
end

get('/processors/:id/edit') do

end

post('processors/:id/update') do

end

post('/processors/create') do
    name = params[:name]
    content = params[:content]
    

end

post('/processors/:id/delete') do

end

#Subjects
get('/subjects') do
    result = getDBItems('db/lowdoc.db', 'subjects')
    slim(:"subjects/index", locals:{subjects:result})
end

get('/subjects/:id/show') do

end

get('/subjects/new') do

end

get('/subjects/:id/edit') do

end

post('subjects/:id/update') do

end

post('/subjects/create') do

end

post('/subjects/:id/delete') do

end

#Searching and links
get('/browsing') do
    result = getDBItems('db/lowdoc.db', 'links')
    slim(:"browsing/index", locals:{links:result})
end

get('/browsing/new') do

end

get('/browsing/:id/edit') do

end

post('browsing/:id/update') do

end

post('/browsing/create') do

end

post('/browsing/:id/delete') do

end