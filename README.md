# Stack ELK (Elastic + Logstash + Kibana) container prototype without SSL/TLS security

Each component in stack ELK (ElasticSearch cluster-node Database, Logstash and Kibana) is a separated container with different base images. Those containers are defined in [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) file, except **Logstash**, which must be launched inside another single-use container. Nonetheless, that .yml file needs some [environment variables](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) we have to define previously before ```docker compose up```. We will use the [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env) to define these parameter values:

- ElasticSearch password
- Kibana password
- Stack version (version of ElasticSearch, Kibana and Logstash)
- ElasticSearch port (```default: 9200```)
- Kibana port (```defaul: 5601```)
- Others such as memory limit, license, docker project name, docker elasticsearch cluster name...

In this repository you will find three variants of the stack:
- **Main architecture**: Elasticsearch as database + Logstash as intermediate data processor + Kibana as data visualizer.
- **Grafana variant**: Elasticsearch as database + Logstash as intermediate data processor + Grafana as data visualizer.
- **Prometheus+Grafana variant**: In this case no Elastic stack containers are used (neither Elasticsearch, Logstash or Kibana). Only Prometheus as database and Grafana as data visualizer.

The steps you need to follow are:

1. Modify .env template file with the values you want. You have a version for multinode ES cluster and singlenode ES cluster.
2. Rename that .env file to ```.env``` so that it is recognized by docker.
3. Copy the .yml file depending on whether you want to deploy a multinode cluster or not. In case you want to deploy multinode cluster, please copy docker-compose-multinode.yml file and rename the copy with ```docker-compose.yml```. Otherwise, copy docker-compose-singlenode.yml and rename it in the same way.

_By default, kibana and elastic username is ```kibana_system```._

With the [docker-compose.yml](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml) that we can find in the tutorial for multinode cluster, by default three nodes are created for ElasticSearch DB Cluster (es01, es02 and es03), but user can add as many as they want.

However, before ```docker compose up```, you must configure [vm.max_map_count](https://www.elastic.co/guide/en/elasticsearch/reference/8.11/docker.html) so as to set how many memory areas ES can use. This parameter is a kernel parameter and you will need to modify it in a different way depending on your host OS. On condition that you haven't configured this setting, the next message error will come up when deploying ES:

```
stack_elk-es01-1    | {"@timestamp":"2023-12-04T07:08:37.142Z", "log.level":"ERROR", "message":"node validation exception\n[1] bootstrap checks failed. You must address the points described in the following [1] lines before starting Elasticsearch. For more information see [https://www.elastic.co/guide/en/elasticsearch/reference/8.11/bootstrap-checks.html]\nbootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]; for more information see [https://www.elastic.co/guide/en/elasticsearch/reference/8.11/_maximum_map_count_check.html]", "ecs.version": "1.2.0","service.name":"ES_ECS","event.dataset":"elasticsearch.server","process.thread.name":"main","log.logger":"org.elasticsearch.bootstrap.Elasticsearch","elasticsearch.node.name":"es01","elasticsearch.cluster.name":"elasticsearch-cluster"}

ERROR: Elasticsearch exited unexpectedly, with exit code 78
```

To set this parameter on Linux systems, you can access to /etc/sysctl.conf file on your host Linux machine and add this line: ```vm.max_map_count=262144```. Then, reboot your host machine and run ```docker compose up```.

On the other hand, we might get a message error from Kibana related to the .kibana index. This is owing to a disk usage of each node (if it's critically low, [Kibana might get unavailable](https://www.elastic.co/guide/en/elasticsearch/reference/8.11/fix-watermark-errors.html)). Typically, you can diagnose these errors using an API. For example, you can GET the resource ```/_cluster/allocation/explain``` while node cluster is running to diagnose this kind of allocation errors, i.e., if you get this error when deploying Kibana, then go to this URL in your navigator (see below):

Error log:

```
stack_elk-kibana-1  | [2023-12-04T11:01:04.737+00:00][WARN ][savedobjects-service] Unable to connect to Elasticsearch. Error: index_not_found_exception
stack_elk-kibana-1  | 	Root causes:
stack_elk-kibana-1  | 		index_not_found_exception: no such index [.kibana]
stack_elk-kibana-1  | [2023-12-04T11:01:04.821+00:00][INFO ][savedobjects-service] [.kibana] INIT -> CREATE_NEW_TARGET. took: 78ms.
stack_elk-kibana-1  | [2023-12-04T11:01:04.824+00:00][INFO ][savedobjects-service] [.kibana_task_manager] INIT -> CREATE_NEW_TARGET. took: 79ms.
stack_elk-kibana-1  | [2023-12-04T11:01:04.830+00:00][INFO ][savedobjects-service] [.kibana_security_solution] INIT -> CREATE_NEW_TARGET. took: 78ms.
stack_elk-kibana-1  | [2023-12-04T11:01:04.866+00:00][INFO ][savedobjects-service] [.kibana_analytics] INIT -> CREATE_NEW_TARGET. took: 119ms.
stack_elk-kibana-1  | [2023-12-04T11:01:04.896+00:00][INFO ][savedobjects-service] [.kibana_ingest] INIT -> CREATE_NEW_TARGET. took: 136ms.
stack_elk-kibana-1  | [2023-12-04T11:01:04.905+00:00][INFO ][savedobjects-service] [.kibana_alerting_cases] INIT -> CREATE_NEW_TARGET. took: 149ms.
stack_elk-kibana-1  | [2023-12-04T11:01:05.079+00:00][INFO ][plugins.screenshotting.chromium] Browser executable: /usr/share/kibana/node_modules/@kbn/screenshotting-plugin/chromium/headless_shell-linux_x64/headless_shell
stack_elk-kibana-1  | [2023-12-04T11:02:04.919+00:00][ERROR][savedobjects-service] [.kibana] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.919+00:00][INFO ][savedobjects-service] [.kibana] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60099ms.
stack_elk-kibana-1  | [2023-12-04T11:02:04.921+00:00][ERROR][savedobjects-service] [.kibana_security_solution] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_security_solution_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.921+00:00][INFO ][savedobjects-service] [.kibana_security_solution] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60091ms.
stack_elk-kibana-1  | [2023-12-04T11:02:04.922+00:00][ERROR][savedobjects-service] [.kibana_task_manager] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_task_manager_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.922+00:00][INFO ][savedobjects-service] [.kibana_task_manager] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60098ms.
stack_elk-kibana-1  | [2023-12-04T11:02:04.927+00:00][ERROR][savedobjects-service] [.kibana_analytics] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_analytics_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.928+00:00][INFO ][savedobjects-service] [.kibana_analytics] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60061ms.
stack_elk-kibana-1  | [2023-12-04T11:02:04.940+00:00][ERROR][savedobjects-service] [.kibana_ingest] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_ingest_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.941+00:00][INFO ][savedobjects-service] [.kibana_ingest] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60044ms.
stack_elk-kibana-1  | [2023-12-04T11:02:04.946+00:00][ERROR][savedobjects-service] [.kibana_alerting_cases] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_alerting_cases_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 1 in 2 seconds.
stack_elk-kibana-1  | [2023-12-04T11:02:04.946+00:00][INFO ][savedobjects-service] [.kibana_alerting_cases] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 60041ms.
stack_elk-kibana-1  | [2023-12-04T11:03:06.944+00:00][ERROR][savedobjects-service] [.kibana_security_solution] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_security_solution_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 2 in 4 seconds.
stack_elk-kibana-1  | [2023-12-04T11:03:06.945+00:00][INFO ][savedobjects-service] [.kibana_security_solution] CREATE_NEW_TARGET -> CREATE_NEW_TARGET. took: 62023ms.
stack_elk-kibana-1  | [2023-12-04T11:03:06.950+00:00][ERROR][savedobjects-service] [.kibana] Action failed with '[index_not_green_timeout] Timeout waiting for the status of the [.kibana_8.11.1_001] index to become 'green' Refer to https://www.elastic.co/guide/en/kibana/8.11/resolve-migrations-failures.html#_repeated_time_out_requests_that_eventually_fail for information on how to resolve the issue.'. Retrying attempt 2 in 4 seconds.
```

Error diagnosis:

```https://localhost:<ES_PORT>/_cluster/allocation/explain```

If you need credentials, use ```username: <the ELASTICSEARCH_USERNAME you set in .env file>``` and ```password: <the ELASTIC_PASSWORD you set in .env file>```

To solve this issue, you can use singlenode approach, as one node will have got the enough memory space in contrast to three nodes, which memory is shared.

In addition, unlike reference docker-compose.yml, notice that we have added in a networks section in our docker-compose.yml. That's because later it will be necessary to add the Logstash container to the Elastic-Kibana containers. As Logstash container is a single-use container, we won't deploy it in the docker-compose.yml with Kibana and Elastic, but we will deploy it with docker run command to test our .conf file. As a result, it's necessary to specify the network when ```docker run``` Logstash container later.

In this repository, there is a .http file to make test HTTP requests from VSCode (you need to install plugin REST Client in VSCode) instead of using your web browsers to run requests towards the ES Database.

*NOTE: If you are still encountering disk usage error even for singlenode cluster, it may be because of the host system available disk space. If your host machine is running on a VM with VMware, consider following these steps:*

1. Go to VMware > Right click on your VM > Settings > Hard disk > Expand. Select the new disk capacity allocated for your VM.
2. Inside the VM: unmount the file system: ```sudo umount /dev/sdXY``` (e.g., sda3).
3. Inside the VM: Install gparted: ```sudo apt-get install gparted```. Re-mount your file system as read-write mode (```sudo mount -o remount,rw /dev/sdXY```, e.g., sda3). In case you don't know which disk partition (sda1, sda2, sda3...) is the file system, you can run gparted (write ```gparted``` in your terminal).
4. Go to gparted and right click over file system partition > orange arrow (resize).

# Run Logstash

Once we have the node Elasticsearch cluster running, we can try to create a logstash pipeline and visualize some metrics from Kibana. For this purpose, we have to run a docker container (single-use, i.e., that container will be removed when it stops running) and then specify where the .conf file is and to where send that .conf file inside the logstash container.

```source .env``` or ```. .env``` (so as to load the .env variables in the current shell session)

```shell
docker pull docker.elastic.co/logstash/logstash:$STACK_VERSION
```

Now we have Logstash image, in order to visualize some metrics in Kibana, please follow these steps:

1. Create a ```logstash.yml``` file. In that ```logstash.yml``` file you will have to specify the Elasticsearch host, because, otherwise, Logstash container tries to connect to localhost, but localhost inside the container (not ES container). As Logstash container will be deployed under the stackELK network (where ES and Kibana are), you can directly set the ES host as the service docker-compose.yml name (i.e., es01 or the name you set in docker-compose.yml for ES service container). Consequently: in ```logstash.yml```, set:

```yaml
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.hosts: ["http://es01:9200"]
```

2. Create your .conf file. For example, you can create a Logstash pipeline to ETL (Extract, Transform and Load) data from stdin (Standard Input) terminal into some Elasticsearch index using this .conf file:

```
input { stdin { } }
output {
  elasticsearch {
    hosts => ["http://es01:9200"]
    index => "logstashtest"
  }
}
```

3. ```docker run``` the logstash image. Please, use the same version you specified in .env file so that Elastic, Kibana and Logstash share the same version. To this end, you can move to the directory where you cloned this repository (i.e., the directory where the .env is located) and then run the following command:

```shell
docker run --rm -it -v ./logstash_configfiles/pipelines/my-conf.conf:/usr/share/logstash/pipeline/my-conf.conf -v ./logstash_configfiles/settings/logstash.yml:/usr/share/logstash/config/logstash.yml --network stack_elk_stackELK-net docker.elastic.co/logstash/logstash:${STACK_VERSION}
```

Once you have Logstash running, you can write something on terminal and then access to logstashtest index in ElasticSearch node on your browser (http://localhost:9200/logstashtest) to check out whether your input data has been loaded in Elasticsearch or not.

Note that the network name is different than the network name you set in docker-compose.yml. That's because docker renames the networks appending the directory name in lowercase (you can see your network name by ```docker network ls```).

# Stack ELK (Elastic + Logstash + Kibana) container prototype with SSL/TLS security
There are three security levels you can configure on a Elastic Stack [4]:

![image](https://github.com/mg-Ben/stack_ELK/assets/71702235/72711b86-0d46-420e-b2ed-dff3c968fc9b)

- The lowest (minimal) security level only implements user passwords for ElasticSearch and Kibana.
- The second (basic) security level only implements TLS in the communication between ElasticSearch nodes. However, not for external communication with the ElasticSearch database cluster (e.g. between Kibana and the cluster). 
- The highest (basic + TLS) security level implements TLS in the communication between ElasticSearch nodes and external communication with ElasticSearch database cluster, such as the communication among Kibana or Beats with the cluster.

Here we will explain how to manually configure the highest level of security:

## 1. Configure the second (basic) security level
_Refer to [5] and [6]_
1. Get the elasticsearch-certutil tool. To do so, download ElasticSearch package from [here](https://www.elastic.co/es/downloads/elasticsearch).
2. Uncompress the ```.tar.gz``` binary and look for ```/bin/elasticsearch-certutil```.
3. Run it. Generate the Certificate Authority and its password with `./elasticsearch-certutil ca`. The output will be a `.p12` file.
4. Use that `.p12` file to generate the certificate for the nodes (we will use the same certificate for each node) with `./elasticsearch-certutil cert --ca elastic-stack-ca.p12`.
5. Move the node certificate resulting file of the previous command into ```/usr/share/elasticsearch/config``` path inside the container. To do so, add this line in your ```docker-compose.yml``` for each node:

```yaml
services:
    my_ES_node_i:
        volumes:
            - path_in_host_OS/node-certificate.p12:/usr/share/elasticsearch/config/node-certificate.p12
```

6. If you set a password for the node certificate, it's also necessary to store it in ```elasticsearch.keystore``` file inside the container. For this reason, you need to run ```/bin/elasticsearch-keystore``` tool specifying the node password when prompted. Specifically, run it twice: ```./elasticsearch-certutil add xpack.security.transport.ssl.keystore.secure_password``` and ```./elasticsearch-certutil add xpack.security.transport.ssl.truststore.secure_password```. You can check whether the password has been added to keystore file or not by ```./elasticsearch-certutil list```.
7. Bind mount the ```elasticsearch.keystore``` file into docker container:

```yaml
services:
    my_ES_node_i:
        volumes:
            - path_in_host_OS/node-certificate.p12:/usr/share/elasticsearch/config/node-certificate.p12
            - path_in_host_OS/elasticsearch.keystore:/usr/share/elasticsearch/config/elasticsearch.keystore
```

## 2. Configure the highest (basic + TLS) security level
_Refer to [7]_


# Common issues
## Cannot start with [discovery.type] set to [single-node]
Error message:
```
Cannot start with [discovery.type] set to [single-node] when local node {es01}{...} does not have quorum...
```
This is because the node ```es01``` belonged to a previous cluster. However, this error might appear even though this is the first time you are deploying your single-node cluster. That's because some data might have persisted from previous tests you have done. To solve this, just remove the docker volumes where cluster information lies in and re-build everything: images and containers with ```docker compose up --build --force-recreate```.

# References:

[1] [Elasticsearch Official Doc](https://www.elastic.co/guide/en/elasticsearch/reference)

[2] [docker-compose.yml with Elasticsearch cluster of 3 nodes and kibana](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml)

[3] [.env file](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/.env)

[4] [Security layers in Elastic Stack](https://www.elastic.co/guide/en/elasticsearch/reference/8.12/manually-configure-security.html)

[5] [Configure the lowest security level](https://www.elastic.co/guide/en/elasticsearch/reference/8.12/security-basic-setup.html)

[6] [Configure the lowest security level on 6.6 ES version](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/configuring-tls-docker.html)

[7] [Configure the highest security level](https://www.elastic.co/guide/en/elasticsearch/reference/8.12/security-basic-setup-https.html)
