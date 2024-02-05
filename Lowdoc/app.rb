require 'sinatra'
require 'slim'
require 'sqlite3'
require_relative "model.rb"

# Hashes containing text for procesors and subjects, ids used as keys
processors_desc = Hash.new
subjects_desc = Hash.new

enable :sessions

get('/') do
    slim(:index)
end

#Processors
get('/processors/index') do

end

get('/processors/show') do

end

get('/processors/new') do

end

get('/processors/:id/edit') do

end

post('processors/:id/update') do

end

post('/processors/create') do

end

post('/processors/:id/delete') do

end

#Subjects
get('/subjects/index') do

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
get('/browsing/index') do

end

get('/links/new') do

end

get('/links/:id/edit') do

end

post('links/:id/update') do

end

post('/links/create') do

end

post('/links/:id/delete') do

end