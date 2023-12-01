# Stack ELK (Elastic + Logstash + Kibana) container prototype

Each component in stack ELK (ElasticSearch cluster-node Database, Logstash and Kibana) is a separated container with different base images. Those containers are defined in [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) file, except **Logstash**, which must be launched inside another single-use container. Nonetheless, that .yml file needs some [environment variables](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) we have to define before ```docker compose up```. We will use the [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env) to define this parameter values:

- ElasticSearch password
- Kibana password
- Stack version (version of ElasticSearch, Kibana and Logstash)
- ElasticSearch port (```default: 9200```)
- Kibana port (```defaul: 5601```)
- Others such as memory limit, license, docker project name, docker elasticsearch cluster name...

With the [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) that we can find in the tutorial, by default three nodes are created for ElasticSearch DB Cluster (es01, es02 and es03), but user can add as many as they want.

*Please, keep the name as .env for the env file.*

# References:

[1] [Elasticsearch Official Doc](https://www.elastic.co/guide/en/elasticsearch/reference)

[2] [docker-compose.yml with Elasticsearch cluster of 3 nodes and kibana](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml)

[3] [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env)
