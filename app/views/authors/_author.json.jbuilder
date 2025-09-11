json.extract! author, :id, :name, :link, :img, :created_at, :updated_at
json.url author_url(author, format: :json)
