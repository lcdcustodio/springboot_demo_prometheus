Springboot Demo with Prometheus
===========================
--------------

1- Intro
===========================
Monitoring an application's health and metrics helps us manage it better, notice unoptimized behavior and get closer to its performance. In this article, we'll cover how to monitor Spring Boot web applications. We will be using three projects to achieve this:

- **Spring Boot Actuator:** a sub-project of the Spring Boot Framework. It uses HTTP endpoints to expose health and monitoring metrics from applications
- **Micrometer:** Exposes the metrics from our application
- **Prometheus:** Stores our metric data
- **Grafana:** Visualizes our data in graphs

## Spring Boot Actuator

To use Actuator in your application, you need to enable the spring-boot-actuator dependency in pom.xml:

```sh
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
```

Dependency provides production-ready endpoints that you can use for your application. These endpoints (/health, /metrics, /mappings, etc.) are common prefix of /actuator and are, by default, protected. Expose them individually, or all at once, by adding the following properties in application.properties:

```sh
    management.endpoints.web.exposure.include=*
```

Spring Boot Actuator shares a lot of information about your application, but it's not very user-friendly. It can be integrated with Spring Boot Admin for visualization, but it has its limitations and is less popular.

Tools like Prometheus, Netflix Atlas, and Grafana are more commonly used for the monitoring and visualization and are language/framework-independent.

Each of these tools has its own set of data formats and converting the /metrics data for each one would be a pain. To avoid converting them ourselves, we need a vendor-neutral data provider, such as Micrometer.

## Micrometer

To solve this problem of being a vendor-neutral data provider, Micrometer came to be. It exposes Actuator metrics to external monitoring systems such as Prometheus, Netflix Atlas, AWS Cloudwatch, and many more.

Micrometer automatically exposes /actuator/metrics data into something your monitoring system can understand. All you need to do is include that vendor-specific micrometer dependency in your application.

Micrometer is a separate open-sourced project and is not in the Spring ecosystem, so we have to explicitly add it as a dependency. Since we will be using Prometheus, let's add it's specific dependency in our pom.xml:

```
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
```
This will generate a new endpoint - /actuator/prometheus. Opening it, you will see data formatted specific for **Prometheus**.

## Prometheus

Prometheus is a time-series database that stores our metric data by pulling it (using a built-in data scraper) periodically over HTTP. The intervals between pulls can be configured, of course, and we have to provide the URL to pull from. It also has a simple user interface where we can visualize/query on all of the collected metrics.

Let's configure Prometheus, and more precisely the scrape interval, the targets, etc. To do that, we'll be using the prometheus.yml file:

<kbd>![Alt text](/pictures/prometheus_yaml.png "Prometheus yaml file")</kbd>

As you can see, we have a scrape_configs root key where we can define a list of jobs and specify the URL, metrics path, and the interval. If you'd like to read more about Prometheus configurations, feel free to visit the [official documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/).

**Note:** Since we are going to use Docker to run Prometheus, Docker network that won't understand localhost as you might expect. Since our app is going to run on localhost, and for the Docker container, localhost means its own network, we have to specify our system IP in place of it.

So instead of using locahost:8080, 192.168.0.20:8080 is used where 192.168.0.20 is my PC IP at the moment.

To check your system IP you can run ipconfig or ifconfig in your terminal, depending upon your OS.

## Grafana

Grafana is a visualization layer that offers a rich UI where you can build up custom graphs quickly and create a dashboard out of many graphs faster. You can also import many community built dashboards for free and get going.

Grafana can pull data from various data sources like Prometheus, Elasticsearch, InfluxDB, etc. It also allows you to set rule-based alerts, which then can notify you over Slack, Email, Hipchat, and similar.


------------

2- Installation
===========================

First of all, let’s clone the repository and build the application:

```sh
    git clone https://github.com/lcdcustodio/springboot_demo_prometheus.git
    cd springboot_demo_prometheus
    mvn clean install
```    

Once the Maven build is finished, the deployment archive has been created in target folder. Now, we be able to create image and run the container:  

```sh
    # Create container
    docker build -t springboot_demo_prometheus .
```

```sh    
    # Run container
    docker run -p 8080:8080 springboot_demo_prometheus
```    

We can see the application up and running at:

```sh
    http://localhost:8080/hello-world
```    

All of metrics, including prometheus, are exposed by:

```sh
    http://localhost:8080/actuator
    http://localhost:8080/actuator/prometheus
```    

Now, we can run Prometheus using the Docker command:


```sh
    docker run -d -p 9090:9090 -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```    


To see Prometheus dashboard, navigate your browser to **http://localhost:9090:**

<kbd>![Alt text](/pictures/prometheus.png "Welcome Prometheus")</kbd>

To check if Prometheus is actually listening to the Spring app, you can go to the /targets endpoint:

<kbd>![Alt text](/pictures/prometheus_target.png "Prometheus Target")</kbd>


Let's start  by running **Grafana** using Docker:


```sh
    docker run -d -p 3000:3000 grafana/grafana
```    

If you visit **http://localhost:3000**, you will be redirected to a login page. The default username is admin and the default password is admin. You can change these in the next step, which is highly recommended:

<kbd>![Alt text](/pictures/grafana.png "Grafana")</kbd>

Since Grafana works with many data sources, we need to define which one we're relying on. Select Prometheus as your data source:

<kbd>![Alt text](/pictures/grafana_ds_1.png "Grafana DataSource")</kbd>

**Note:** Since we are going to use Docker to run Grafana, Docker network that won't understand localhost as you might expect. Localhost means its own network, we have to specify our system IP in place of it in order to connect Prometheus Data Source

<kbd>![Alt text](/pictures/grafana_ds_2.png "Grafana Prometheus Ready")</kbd>

[Reference](https://stackabuse.com/monitoring-spring-boot-apps-with-micrometer-prometheus-and-grafana/)

Prometheus:

- https://grafana.com/grafana/dashboards/4701-jvm-micrometer/


