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

![Alt text](/pictures/prometheus)yaml.png "Setup")

As you can see, we have a scrape_configs root key where we can define a list of jobs and specify the URL, metrics path, and the interval. If you'd like to read more about Prometheus configurations, feel free to visit the [official documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/).

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



Prometheus:

- https://stackabuse.com/monitoring-spring-boot-apps-with-micrometer-prometheus-and-grafana/
- docker run -d -p 9090:9090 -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
- docker run -d -p 3000:3000 grafana/grafana
- https://grafana.com/grafana/dashboards/4701-jvm-micrometer/

------------
Deploying Enterprise JavaBeans application over Kubernetes cluster. For achieving the aim is mandatory to follow containerization approach. For this purposes was considered WildFly Docker image. It is required also a Kubernetes Cluster up and running.  


------------

1- High Level Design
===========================


![Alt text](/picture/hld.png "Solution Architecture")


------------

2- Installation
===========================

First of all, let’s clone the repository and build the application:

```
    git clone https://github.com/lcdcustodio/ejb_demo_k8s.git
    cd ejb_demo_k8s
    mvn clean install
```    

Once the Maven build is finished, the deployment archive has been created in target folder. Now, we be able to create images required for Pods in the Solution Architecture.  

```
    # EJB image
    docker build -t ejb_demo_k8s .
    # NGINX image
    docker build -f deploy/Dockerfile -t nginx_soap_script .    

```    


------------

3- Kubernetes resources assembly 
===========================

Yaml files in charge to create all of kubernetes resources for this demo are available at deploy folder. Through the Kubernetes command-line tool, kubectl, let's run the following instructions:  

```
    # create deployment, pod and replicaset for EJB application
    kubectl apply -f .\deploy\deployment.yaml
    # create service for EJB application
    kubectl apply -f .\deploy\service.yaml
    # create NGINX pod
    kubectl apply -f .\deploy\pod-nginx.yaml
```    

------------

4- Kubernetes Logs 
===========================


- kubectl get services # get service info
- kubectl get deployments # get deployment info
- kubectl get rs # get replicaset info
- kubectl get pods -o wide  # get pod info
- kubectl describe service svc-ejb-demo-k8s #endpoint address to load balance
- kubectl logs -f pod-nginx #soap script is up and running

------------

5- Check load balancing between pods
===========================

- kubectl logs -f <pod_name> #pods created from deployment 

------------

6- Use Case - check pod resiliency 
===========================

#
- kubectl get pods -o wide  # get pods info
- kubectl delete pods --all  #pods will be back, except pod-nginx
- kubectl delete pods <pod_name> # pod downtime is really fast.. s
- kubectl get pods -o wide  # get pods info
