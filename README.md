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

Prometheus has got its own built-in User Interface, so Grafana is not compulsory to visualize data, but recommended. To explore Prometheus data, just go to ```http://localhost:<your_prometheus_port>```.

Prometheus typically works scraping **instances** (processes). A group of instances is called **job**. Those instances are often HTTP endpoints (or they can be generically ```IP:port``` tuples), but they cannot be any endpoint, but must be specific endpoints/instances/processes which are compatible with Prometheus. For example, you can use [**exporters**](https://prometheus.io/docs/instrumenting/exporters/), which are Prometheus-oriented processes that are ready to be scraped by Prometheus (some of them are GitHub repositories). Just download the exporter you want (e.g., the .zip binary) on the machine where the process will be scraped, then unzip it and run the executable. While it is running on that remote (or local) machine, add the job and instance to ```prometheus.yml``` file (location: ```/etc/prometheus.yml``` inside the docker container). Luckily, you don't have to care about moving the file to the container (I have thought of you :D): just edit the ```./prometheus_configfiles/prometheus.yml``` of this repository and the file will be bind-mounted to ```/etc/prometheus.yml``` file inside the docker container once it is running:

_If you don't trust me, take a look at docker-compose-singlenode.yml:_
```
prom01:
    image: prom/prometheus:${PROMETHEUS_VESION}
    ports:
      - ${PROMETHEUS_PORT}:9090
      - ${PROMETHEUS_PUSHGATEWAY_PORT}:9091
    networks:
      - stack-net
    volumes:
      - prom01data:/prometheus
      - ./prometheus_configfiles:/etc/prometheus <------------------------------ Here!
```

For example, you can scrap the Prometheus instance itself specifying the following target endpoint in ```./prometheus_configfiles/prometheus.yml```:

```
scrape_configs:
  - job_name: 'prometheus-itself'
    scrape_interval: 5s #This is the sampling period
    static_configs:
      - targets: ['localhost:9090']
```

_(Remember that Prometheus is running inside a container and that this file will be inside the container, so localhost:9090 will be=The Prometheus container:Port 9090 (therefore, it is right))_

Once you are scraping an instance, several time series (called **metrics**) are stored in Prometheus for that instance. The time series will be stored with the format ```<metric_name>{job=<job_name>, instance=<instance_name>}```. In the example, the time series with the Prometheus instance data would be stored with ```job=prometheus-itself``` (but you can choose the name you want) and ```instance=localhost:9090``` Consequently, you can go to Prometheus (type ```http//localhost:9090``` on web browser) and query the time series (metric_name) filtering by job and instance: E.g.: ```up{job='prometheus-itself', instance='localhost:9090'}```. You can also check whether it is scraping or not moving into Status > Targets.

## SNMP Exporter example

You can run [SNMP Exporter](https://github.com/prometheus/snmp_exporter) on a remote device and monitor it with Prometheus. To this end, go to the [SNMP Exporter binaries](https://github.com/prometheus/snmp_exporter/releases), download the ```.zip``` file depending on your processor architecture (see it with ```lshw``` on Linux systems or ```set processor``` on Windows systems) and decompress it on the machine which you want to monitor. Then, access to decompressed directory and look for the executable (.sh) file. Run it and your device will be ready to be monitored.

Once the SNMP server agent is running (it runs on 9116 port), identify the IP address of the device (```ifconfig``` on Linux systems, ```ipconfig``` on Windows systems) and then connect to that target from Prometheus:

```
- job_name: 'snmp-server'
  scrape_interval: 1s
  static_configs:
    - targets: ['<your_agent_IP>:9116']
```

However, SNMP Exporter can act as SNMP Manager instead of SNMP agent: this is, you can run the Exporter on any machine. Then run a SNMP agent on the remote machine that you want to monitor (to do this, if that remote machine uses Linux OS, you can use ```snmpd``` package; install it with ```sudo apt install snmp``` and run the SNMP service as ```systemctl start snmpd```). Once the remote machine is running, on Prometheus configuration file (```prometheus.yml```) set the scrap endpoint (which is the SNMP **manager** process, not the agent) and use a query string to select the remote device which is running the SNMP agent (i.e., the device who wants to be monitored). You can also set a custom label to identify that device on Prometheus:

```
- job_name: 'snmp-server'
  scrape_interval: 1s
  static_configs:
    - targets: ['<your_manager_IP>:9116/snmp?target=<your_agent_IP>']
      labels:
        - snmp_agent: my_laptop
```

BUT in Prometheus you cannot set targets with different format than ```IP:port```, and it's not possible to (1) pass query strings like ```?target=IP``` or (2) access to certain endpoint inside your process like ```/snmp``` on targets field. For this purpose, there are some dedicated fields:

- **metrics_path**: to set the specific endpoint ```/snmp```
- **params**: to set query string key-value pairs like ```target=<your_agent_IP>```

```
- job_name: 'snmp-server'
  metrics_path: '/snmp'
  params:
    target: ['<your_agent_IP>']
  static_configs:
  - targets: ['<your_manager_IP>:9116']
```

Finally, if you want to make tests with a running SNMP remote agent, that remote machine must "want to be monitored", so you will have to configure it to accept SNMP requests. Go to your remote machine and:

1. Install snmpd package with ```sudo apt install snmpd```
2. Configure snmpd daemon in ```/etc/snmp/snmpd.conf```. Set explicitly the port where to allocate SNMP agent server:

```
agentaddress udp:161
```

3. Restart the snmpd service: ```sudo systemctl restart snmpd```. Your SNMP agent is ready to receive data.

_REMEMBER: If you are running the agent or the exporter inside a Virtual Machine, that Virtual Machine must be reachable on your (W)LAN. This means that your Virtual Machine must have an assigned IP address on your LAN (the DHCP server on your (W)LAN is the responsible of this task) as if your host machine had a new Network Interface (like Ethernet, WiFi etc) corresponding to that VM. To expose your VM like a new device on your LAN, Go to VMware > Your VM Settings > Network Adapter > Set Bridged. Another solution is to consider that your VM is the same device as the host machine, so they share the IP address (=Host IP Address), but your VM must have dedicated ports and it might be necessary to dive into additional settings, so this is not recommended_