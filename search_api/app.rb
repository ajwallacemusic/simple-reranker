require 'sinatra'
require_relative '../elasticsearch/elasticsearch_client'
require 'faraday'
require 'json'

$stdout.sync = true

# Create a new ElasticSearch client
client = ElasticsearchClient.client
metrank_rerank_url = "http://host.docker.internal:8080/rank/xgboost"
metarank_feedback_url = "http://host.docker.internal:8080/feedback"

before do
  content_type 'application/json'
end

def build_es_query(query)
  result = {
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
  return result
end

# Define the API endpoint for search requests
get '/search' do
  # Get the search query from the request parameters
  query = params['q']

  # Build the ElasticSearch query
  es_query = build_es_query(query)

  # Execute the search query against the 'movies' index
  results = client.search index: 'movies', body: es_query

  # Parse the search results and convert them to JSON
  hits = results['hits']['hits']

  #send rank event to metarank
  ids = hits.map { |hit| hit['_source']['id'] }
  id_array = ids.map { |id| { "id" => id.to_s } }
  timestamp = Time.now.to_i

  json_obj = {
    "event": "ranking",
    "id": "id1",
    "items": id_array,
    "user": "alice",
    "session": "alice1",
    "timestamp": timestamp
  }

  json_string = JSON.generate(json_obj)

  response = Faraday.post(metarank_feedback_url, json_string)
  puts response.body

  hits.map { |hit| hit['_source'] }.to_json
end

get '/rerank' do
  query = params['q']

  # Build the ElasticSearch query
  es_query = build_es_query(query)

  # Execute the search query against the 'movies' index
  es_results = client.search index: 'movies', body: es_query
  hits = es_results['hits']['hits']
  #send rank event to metarank
  ids = hits.map { |hit| hit['_source']['id'] }
  id_array = ids.map { |id| { "id" => id.to_s } }
  timestamp = Time.now.to_i

  json_obj = {
    "event": "ranking",
    "id": "id1",
    "items": id_array,
    "user": "alice",
    "session": "alice1",
    "timestamp": timestamp
  }
  json_string = JSON.generate(json_obj)

  response = Faraday.post(metrank_rerank_url, json_string)
  response.body
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
    puts("indexing complete")
    "Indexing Complete"
end
