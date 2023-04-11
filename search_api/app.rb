require 'sinatra'
require_relative '../elasticsearch/elasticsearch_client'

# Create a new ElasticSearch client
client = Elasticsearch::Client.new log: true

# Define the API endpoint for search requests
get '/search' do
  # Get the search query from the request parameters
  query = params['q']

  # Build the ElasticSearch query
  es_query = {
    _source: ["title","id"],
    query: {
      multi_match: {
        query: query,
        fields: [
          'title',
          'tags',
          'genres.name',
          'description'
          ]
      }
    }
  }

  # Execute the search query against the 'test_index' index
  results = client.search index: 'movies', body: es_query

  # Parse the search results and convert them to JSON
  hits = results['hits']['hits']
  hits.map { |hit| hit['_source'] }.to_json
end

get '/movie/:id' do |id|
    # stuff
    id = id
    result = client.get(index: 'movies', id: id)
    result['_source']['title'].to_json
end


# INDEX FUNCTIONS
# Define the API endpoint for search requests
get '/setup_index' do
    # Set up Elasticsearch index
    ElasticsearchClient.setup_index('movies', 250)
    "Index Created"
end

# Define the API endpoint for search requests
get '/index_data' do
    puts("indexing data...")
    # Index data from JSON file
    filepath = "/app/tmp/movies.jsonl"
    ElasticsearchClient.bulk_index_ndjson('movies', filepath)
    "Indexing Complete"
    puts("indexing complete")
end
