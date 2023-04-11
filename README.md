# simple-reranker
A simple ruby app, using elasticsearch and metarank to rerank search results, orchestrated with docker-compose

## TL;DR
After downloading and running the `docker-compose up` command, you should be able to use the postman collection to:
- Set up a movies index in Elasticsearch.
- Search the movies index via the `/search` endpoint, using the `q` query parameter, ie `http://localhost:4567/search?q=toy`.
- Rerank the search request via the `/rerank` endpoint.
- Send click events to metarank and get personalized reranking results.

### Initial Elasticsearch Query for "toy"
```
GET http://localhost:4567/search?q=toy
[
    {
        "id": 3114,
        "title": "Toy Story 2"
    },
    {
        "id": 78499,
        "title": "Toy Story 3"
    },
    {
        "id": 2253,
        "title": "Toys"
    },
    {
        "id": 1707,
        "title": "Home Alone 3"
    },
    {
        "id": 2953,
        "title": "Home Alone 2: Lost in New York"
    },
    {
        "id": 6936,
        "title": "Elf"
    },
    {
        "id": 2399,
        "title": "Santa Claus: The Movie"
    },
    {
        "id": 90866,
        "title": "Hugo"
    }
]
```

### Initial Reranking Query for "toy"
```
GET http://localhost:4567/rerank?q=toy
[
    {
        "id": 2953,
        "title": "Home Alone 2: Lost in New York"
    },
    {
        "id": 3114,
        "title": "Toy Story 2"
    },
    {
        "id": 1707,
        "title": "Home Alone 3"
    },
    {
        "id": 78499,
        "title": "Toy Story 3"
    },
    {
        "id": 90866,
        "title": "Hugo"
    },
    {
        "id": 6936,
        "title": "Elf"
    },
    {
        "id": 2253,
        "title": "Toys"
    },
    {
        "id": 2399,
        "title": "Santa Claus: The Movie"
    }
]
```

### Reranking Query for "toy" After Click Event
```
POST http://localhost:8080/feedback
{
    "event": "interaction",
    "type": "click",
    "id": "id2",
    "ranking": "id1",
    "item": "3114",
    "user": "alice",
    "session": "alice1",
    "timestamp": 1661431896711
}

//then
GET http://localhost:4567/rerank?q=toy
[
    {
        "id": 3114,
        "title": "Toy Story 2"
    },
    {
        "id": 2953,
        "title": "Home Alone 2: Lost in New York"
    },
    {
        "id": 78499,
        "title": "Toy Story 3"
    },
    {
        "id": 1707,
        "title": "Home Alone 3"
    },
    {
        "id": 90866,
        "title": "Hugo"
    },
    {
        "id": 6936,
        "title": "Elf"
    },
    {
        "id": 2253,
        "title": "Toys"
    },
    {
        "id": 2399,
        "title": "Santa Claus: The Movie"
    }
]
```

## Libraries/Tools
- [Sinatra](https://sinatrarb.com/)
- [Elasticsearch](https://www.elastic.co/) (version 8.7.0)
- [Metarank](https://www.metarank.ai/)
- [Docker Compose](https://docs.docker.com/compose/) (tested on Docker Desktop for Mac version 4.12)
- [Postman](https://www.postman.com/)

## Data
The movie data used the ranklens dataset from the [metarank demo](https://github.com/metarank/ranklens)

This dataset is a MovieLens-based crowd-sourced training data for ranking models. It has:
- Movie metadata from TMDB: actors, genres, tags, dates.
- Rankings for 2100 visitors for random movie groups.
- Each visitor interacted with ~5 groups, and marked >1 movies as liked.

## Structure
The ruby app uses the Sinatra framework to expose endpoints for setting up an elasticsearch index, searching the index, and reranking the results via metarank. 
