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

#Processors
get('/processors') do
    result = getDBItems('db/lowdoc.db', 'Processors')
    slim(:"processors/index", locals:{processors:result})
end

get('/processors/:id/show') do

end

get('/processors/new') do
    slim(:"processors/new")
end

get('/processors/:id/edit') do
    @id = params[:id]
    @name = fetchInfo('db/lowdoc.db', 'Processors', @id, 'name')

    # Get relational info
    @relSubjects = getDBItemsWithRelId('db/lowdoc.db', 'Processors', 'subject_id', @id)
    @relLinks = getDBItemsWithRelId('db/lowdoc.db', 'Processors', 'link_id', @id)
    # Id lists for checkbox
    @relSubjectsIdList = []
    @relSubjects.each do |subject|
        @relSubjectsIdList.append(subject["id"])
        puts "relelflfjnweufn"
        puts @relSubjects
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
    checkedSubjects = params[:checkedSubjects]
    checkedLinks = params[:checkedLinks]
    puts "CHECKS"
    p checkedSubjects
    p checkedLinks

    updateRecord('db/lowdoc.db', 'Processors', id, name, content)
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

end

post('/subjects/:id/update') do

end

post('/subjects/new') do
    name = params[:name]
    content = params[:content]
    
    addRecord('db/lowdoc.db', 'Subjects', name, content)
    redirect('/subjects')
end

post('/subjects/:id/delete') do

end

#Searching and links
get('/browsing') do
    result = getDBItems('db/lowdoc.db', 'Links')
    slim(:"browsing/index", locals:{links:result})
end

get('/browsing/new') do

end

get('/browsing/:id/edit') do

end

post('/browsing/:id/update') do

end

post('/browsing/new') do

end

post('/browsing/:id/delete') do

end