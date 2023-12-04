# Stack ELK (Elastic + Logstash + Kibana) container prototype

Each component in stack ELK (ElasticSearch cluster-node Database, Logstash and Kibana) is a separated container with different base images. Those containers are defined in [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) file, except **Logstash**, which must be launched inside another single-use container. Nonetheless, that .yml file needs some [environment variables](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) we have to define before ```docker compose up```. We will use the [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env) to define this parameter values:

- ElasticSearch password
- Kibana password
- Stack version (version of ElasticSearch, Kibana and Logstash)
- ElasticSearch port (```default: 9200```)
- Kibana port (```defaul: 5601```)
- Others such as memory limit, license, docker project name, docker elasticsearch cluster name...

*Please, keep the name as .env for the env file.*

By default, kibana and elastic username is ```elastic```.

With the [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) that we can find in the tutorial, by default three nodes are created for ElasticSearch DB Cluster (es01, es02 and es03), but user can add as many as they want.

However, before ```docker compose up```, you must configure [vm.max_map_count](https://www.elastic.co/guide/en/elasticsearch/reference/8.11/docker.html) so as to set how many memory areas ES can use. This parameter is a kernel parameter and you will need to modify it in a different way depending on your host OS. On condition that you haven't configured this setting, the next message error will come up when deploying ES:

```
stack_elk-es01-1    | {"@timestamp":"2023-12-04T07:08:37.142Z", "log.level":"ERROR", "message":"node validation exception\n[1] bootstrap checks failed. You must address the points described in the following [1] lines before starting Elasticsearch. For more information see [https://www.elastic.co/guide/en/elasticsearch/reference/8.11/bootstrap-checks.html]\nbootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]; for more information see [https://www.elastic.co/guide/en/elasticsearch/reference/8.11/_maximum_map_count_check.html]", "ecs.version": "1.2.0","service.name":"ES_ECS","event.dataset":"elasticsearch.server","process.thread.name":"main","log.logger":"org.elasticsearch.bootstrap.Elasticsearch","elasticsearch.node.name":"es01","elasticsearch.cluster.name":"elasticsearch-cluster"}

ERROR: Elasticsearch exited unexpectedly, with exit code 78
```
To set this parameter on Linux systems, you can access to /etc/sysctl.conf file and add this line: ```vm.max_map_count=262144```. Then, reboot your host machine and run ```docker compose up```.

On the other hand, we might get a message error from Kibana related to the .kibana index. This is owing to a disk usage of each node (if it's critically low, [Kibana might get unavailable](https://www.elastic.co/guide/en/elasticsearch/reference/8.11/fix-watermark-errors.html)). Typically, you can diagnose these errors using an API. For example, you can GET the resource ```/_cluster/allocation/explain``` while node cluster is running to diagnose this kind of allocation errors, i.e., if you get this error when deploying Kibana, then go to this URL in your navigator:

```https://localhost:9200/_cluster/allocation/explain```

If your need credentials, use ```username: kibana_system``` and ```password: <the ELASTIC_PASSWORD you set in .env file>```

# Run logstash

Once we have the three-node Elasticsearch cluster running, we can try to create a logstash pipeline and visualize some metrics from Kibana. For this purpose, we have to run a docker container (single-use, i.e., that container will be removed when it stops running) and then specify where the .conf file is and to where send that .conf file inside the logstash container.

```source .env``` or ```. .env``` (so as to load the .env variables in the current shell session)

```docker pull docker.elastic.co/logstash/logstash:$STACK_VERSION```

Now we have Logstash image, in order to visualize some metrics in Kibana, please follow these steps:

1. Create a ```logstash.yml``` file 

1. ```docker pull``` the logstash image. Please, use the same version you specified in .env file so that Elastic, Kibana and Logstash share the same version. To this end, you can move to the directory where you cloned this repository (i.e., the directory where the .env is located) and then run the following command:

```docker run --rm -it -v <>:<>```

# References:

[1] [Elasticsearch Official Doc](https://www.elastic.co/guide/en/elasticsearch/reference)

[2] [docker-compose.yml with Elasticsearch cluster of 3 nodes and kibana](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml)

[3] [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env)
