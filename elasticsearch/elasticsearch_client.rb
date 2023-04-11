require 'elasticsearch'

module ElasticsearchClient
  HOST = 'http://es01:9200'.freeze

  def self.client
    @client ||= Elasticsearch::Client.new(host: HOST)
  end

  def self.setup_index(index_name, batch_size)
    mappings = {
      properties: {
        budget: { type: 'float' },
        description: { type: 'text' },
        director: { type: 'nested', properties: {
          gender: { type: 'integer' },
          id: { type: 'integer' },
          name: { type: 'text' },
          popularity: { type: 'float' }
        }},
        genres: { type: 'nested', properties: {
          id: { type: 'integer' },
          name: { type: 'text' }
        }},
        id: { type: 'integer' },
        overview: { type: 'text' },
        poster: { type: 'text' },
        releaseDate: { type: 'date' },
        revenue: { type: 'float' },
        runtime: { type: 'integer' },
        tags: { type: 'keyword' },
        title: { type: 'text' },
        tmdbId: { type: 'integer' },
        tmdbPopularity: { type: 'float' },
        tmdbVoteAverage: { type: 'float' },
        tmdbVoteCount: { type: 'integer' },
        topActors: { type: 'nested', properties: {
          gender: { type: 'integer' },
          id: { type: 'integer' },
          name: { type: 'text' },
          popularity: { type: 'float' }
        }},
        writer: { type: 'nested', properties: {
          gender: { type: 'integer' },
          id: { type: 'integer' },
          name: { type: 'text' },
          popularity: { type: 'float' }
        }}
      }
    }
  
    client.indices.create(index: index_name, body: { mappings: mappings })
  
    # Refresh the index to make sure the mappings are updated
    client.indices.refresh(index: index_name)
  end

  def self.index_data(index_name, data)
    bulk_data = []
    data.each do |doc|
        bulk_data << { index: { _index: index_name } }
        bulk_data << doc


    # data.each_slice(250) do |batch|
        # bulk_data = []
        # bulk_data << { index: { _index: index_name } }
        # bulk_data << data

        # data.each do |row|
        #     # doc = {
        #     #   budget: row['budget'],
        #     #   description: row['description'],
        #     #   director: {
        #     #     gender: row['director']['gender'],
        #     #     id: row['director']['id'],
        #     #     name: row['director']['name'],
        #     #     popularity: row['director']['popularity']
        #     #   },
        #     #   genres: row['genres'].map { |genre| { id: genre['id'], name: genre['name'] } },
        #     #   id: row['id'],
        #     #   overview: row['overview'],
        #     #   poster: row['poster'],
        #     #   release_date: row['releaseDate'],
        #     #   revenue: row['revenue'],
        #     #   runtime: row['runtime'],
        #     #   tags: row['tags'],
        #     #   title: row['title'],
        #     #   tmdb_id: row['tmdbId'],
        #     #   tmdb_popularity: row['tmdbPopularity'],
        #     #   tmdb_vote_average: row['tmdbVoteAverage'],
        #     #   tmdb_vote_count: row['tmdbVoteCount'],
        #     #   top_actors: row['topActors'].map { |actor| { gender: actor['gender'], id: actor['id'], name: actor['name'], popularity: actor['popularity'] } },
        #     #   writer: {
        #     #     gender: row['writer']['gender'],
        #     #     id: row['writer']['id'],
        #     #     name: row['writer']['name'],
        #     #     popularity: row['writer']['popularity']
        #     #   }
        #     # }
        #     bulk_data << { index: { _index: index_name } }
        #     bulk_data << row
        #  end

        client.bulk(body: bulk_data)
    end
  end

  def self.bulk_index_ndjson(index_name, file_path, batch_size=250)
    File.open(file_path).each_slice(batch_size) do |batch|
      bulk_data = []
      
      batch.each do |line|
        data = JSON.parse(line)
        bulk_data << { index: { _index: index_name, _id: data['id'] } }
        bulk_data << data
      end
      
      puts bulk_data
      client.bulk(body: bulk_data)
    end
  end

end
