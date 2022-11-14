Springboot Demo with Prometheus
===========

------------
Monitoring an application's health and metrics helps us manage it better, notice unoptimized behavior and get closer to its performance. In this article, we'll cover how to monitor Spring Boot web applications. We will be using three projects to achieve this:

- Spring Boot Actuator: a sub-project of the Spring Boot Framework. It uses HTTP endpoints to expose health and monitoring metrics from applications
- Micrometer: Exposes the metrics from our application
- Prometheus: Stores our metric data
- Grafana: Visualizes our data in graphs

------------

Spring Boot Actuator
===========================

To use Actuator in your application, you need to enable the spring-boot-actuator dependency in pom.xml:

```
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
```

Dependency provides production-ready endpoints that you can use for your application. These endpoints (/health, /metrics, /mappings, etc.) are common prefix of /actuator and are, by default, protected. Expose them individually, or all at once, by adding the following properties in application.properties:
```
    management.endpoints.web.exposure.include=*
```
Spring Boot Actuator shares a lot of information about your application, but it's not very user-friendly. It can be integrated with Spring Boot Admin for visualization, but it has its limitations and is less popular. 
Tools like Prometheus, Netflix Atlas, and Grafana are more commonly used for the monitoring and visualization and are language/framework-independent.
Each of these tools has its own set of data formats and converting the /metrics data for each one would be a pain. To avoid converting them ourselves, we need a vendor-neutral data provider, such as Micrometer.
------------

Micrometer
===========================
To solve this problem of being a vendor-neutral data provider, Micrometer came to be. It exposes Actuator metrics to external monitoring systems such as Prometheus, Netflix Atlas, AWS Cloudwatch, and many more.
Micrometer automatically exposes /actuator/metrics data into something your monitoring system can understand. All you need to do is include that vendor-specific micrometer dependency in your application.
Micrometer is a separate open-sourced project and is not in the Spring ecosystem, so we have to explicitly add it as a dependency. Since we will be using Prometheus, let's add it's specific dependency in our pom.xml:
```
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
```



Prometheus:
- mvn clean install
- docker build -t springboot_demo_prometheus .
- docker run -p 8080:8080 springboot_demo_prometheus

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
