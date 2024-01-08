# Using Grafana instead of Kibana to visualize data
In this branch, we use Grafana as data visualizer instead of using Kibana. The settings are very similar, but in this case It's necessary to define some configurations (see .env file) such as:
- **Grafana plugins**: The plugins that will automatically installed inside Grafana container. You can specify them separated by ',' and, for each one, you can set the plugin version separated by blank space (e.g.: ```grafana-clock-panel 1.0.1```). In addition, you have the choice to use custom-user plugins from GitHub. To do so, just set the GitHub repository ```.zip``` file URL and the directory where the package will be installed inside the container (e.g.: ```https://github.com/VolkovLabs/custom-plugin.zip;custom-plugin```). In this case, It will be necessary to import elasticsearch plugin.
- **Grafana volumes**: You can link Grafana default paths with a volume in Docker, as usual. You can find the Grafana default paths (such as logs, plugins or Grafana configuration file) [here](https://grafana.com/docs/grafana/latest/setup-grafana/configure-docker/#default-paths). Therefore, supposing you want to create a docker volume with your installed plugins, just link the directory path where plugins are installed inside the container (i.e., ```var/lib/grafana/plugins```) to the volume you want.

***Remember: to go into Grafana, type ```http://localhost:<your_grafana_port>```***

# Using Prometheus instead of Elasticsearch
In this branch, we use Prometheus as database instead of using Elasticsearch. The settings are very similar, but in this case It's necessary to define some configurations (see .env file) such as:
- **Push Gateway port**: Prometheus Databases use an intermediate gateway server where we have to connect to in order to upload data.

Access to Prometheus database from web browser: just go to ```http://localhost:9090```.

Once we are inside Grafana GUI and the Prometheus container is running (the Prometheus nodes are autonomous, so in this case we cannot consider multi-node cluster), you can access and interact with Prometheus database from Grafana just specifying the target Prometheus URL from Grafana settings:

![Alt text](/doc/images/image.png)

Then go to Add Datasource:

![Alt text](/doc/images/image-1.png)

Add a new Prometheus database and set the URL (Connection URL field).

**Remember!** Don't set destination database URL to ```http://localhost:<your_prometheus_port>```, since, in that case, you are connecting to localhost Grafana container itself. Remember that docker containers connect each other thanks to the network and that there is automatic DNS resolution, so providing you want to connect to Prometheus instance from Grafana, use the container name instead of localhost: ```http://prom01:<your_elasticsearch_port>``` in this case.

***NOTE***: To make your tests with your Prometheus Data, you can use default time series:

![Alt text](/doc/images/image-2.png)

Nonetheless, on condition you want to add custom data, send everything you want to the Push Gateway:
```
curl -X POST -H "Content-Type: application/json" -d '{"job": "test", "instance": "localhost:9090", "metric": "my_metric", "value": 42}' http://localhost:9090/metrics/job/test
```