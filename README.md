# Using Grafana instead of Kibana to visualize data
In this branch, we use Grafana as data visualizer instead of using Kibana. The settings are very similar, but in this case It's necessary to define some configurations (see .env file) such as:
- **Grafana plugins**: The plugins that will automatically installed inside Grafana container. You can specify them separated by ',' and, for each one, you can set the plugin version separated by blank space (e.g.: ```grafana-clock-panel 1.0.1```). In addition, you have the choice to use custom-user plugins from GitHub. To do so, just set the GitHub repository ```.zip``` file URL and the directory where the package will be installed inside the container (e.g.: ```https://github.com/VolkovLabs/custom-plugin.zip;custom-plugin```). In this case, It will be necessary to import elasticsearch plugin.
- **Grafana volumes**: You can link Grafana default paths with a volume in Docker, as usual. You can find the Grafana default paths (such as logs, plugins or Grafana configuration file) [here](https://grafana.com/docs/grafana/latest/setup-grafana/configure-docker/#default-paths). Therefore, supposing you want to create a docker volume with your installed plugins, just link the directory path where plugins are installed inside the container (i.e., ```var/lib/grafana/plugins```) to the volume you want.

***Remember: to go into Grafana, type ```http://localhost:<your_grafana_port>```***

# Access to ElasticSearch cluster from Grafana
Once we are inside Grafana GUI and the ES cluster is running, you can access and interact with ES database from Grafana just specifying the target ES URL from Grafana settings:

![Alt text](/doc/images/image.png)

Then go to Add Datasource:

![Alt text](/doc/images/image-1.png)

Add a new Elasticsearch database and set the URL (Connection URL field).

**Remember!** Don't set destination database URL to ```http://localhost:<your_elasticsearch_port>```, since, in that case, you are connecting to localhost Grafana container itself. Remember that docker containers connect each other thanks to the network and that there is automatic DNS resolution, so providing you want to connect to Elasticsearch instance from Grafana, use the container name instead of localhost: ```http://es01:<your_elasticsearch_port>``` in this case.

***NOTE***: To make your tests with your ElasticSearch Data, the documents inside the index must contain the @timestamp field. You can create a test index and add it some data metrics to begin your tests as It follows:

1. Create an index with timestamp mapping. Run this command from your console while your ElasticSearch instance is running:
```
curl -X PUT "http://localhost:<your_elasticsearch_port>/<index_name_you_want>" -H 'Content-Type: application/json' -d '{"mappings": {"properties": {"@timestamp": {"type": "date"}, "field1": {"type": "keyword"}, "field2": {"type": "text"}}}}'
```

2. Add a document to the recently created index:

```
curl -X POST "http://localhost:<your_elasticsearch_port>/<index_name_you_want>/_doc" -H 'Content-Type: application/json' -d '{"@timestamp": "2024-01-08T12:00:00", "field1": "value1", "field2": "value2"}'
```

Once you have added custom test data, you can visualize it: add a dashboard and see it as Raw Data or whatever you want! :D