# Brief Summary:

* The django application is packaged as a docker image with nginx as web server and gunicorn as WSGI.
* The web server and gunicorn are deployed as different containers in a Kubernetes pod, orchestrated on Google Kubernetes.
* The static content is served by nginx and application requests are routed to wsgi server. 
* A postgres instance, deployed on Google Cloud SQL service, is being used as database backend for the django application.
* A Kubernetes deployment config has been developed to manage the orchestration of pods. It makes sure that a given number of replicas are active at any time, ensuring availabillity of the application. It also manages the rolling updates.
* Google cloud load balancer with Horizontal pod autoscaling enabled makes sure that the system is highly scalable.
* Liveness check has been added to the pod template, which is required for self healing of pods. 
* Readiness check has been added to the pod template, to route requests only to healthy pods.
* The config management and secret management has been done through kubernetes config maps and secrets.
* Application picks the environment specific (dev,stg,prd etc) config from environment variables injected through the kubernetes secret and config map. 
* This makes sure that same docker artifacts can be used across all environments. This enables us to build image once, test and promote them to different environments.
* Application logs are managed via stackdriver, which help in troubleshooting.
* Implementation wise, makefile was used to group tasks or commands.

# Decisions and tradeoffs:
* Containerized deployment was chosen due to:
	1. Cost effectiveness. The same cluster resources can be shared by multiple applications.
	2. Lower init time of containers compared to vms, which helps in quick scaleup of applications.
  However, containerization might not be a good approach, if the application is stateful.
* Google cloud was chosen as the cloud platform, due to the following reasons:
	1. Google cloud is one of the best and relatively mature Kubernetes provider (like log management, integrated registry, load balancer).
	2. Loadbalancer in conjunction with horizontal pod autoscaling.
	3. Stackdriver integration for kubernetes logs and application log management.
	4. On a lighter note, I exhausted all other cloud platforms' free tier :) 
* Postgres:
  It has been chosen due to its excellent integration with django. However, the database choice depends on the nature of application.
* Deployment Strategy:
  As per me Blue/Green strategy would be the best production deployment stategy, if there were no budget issues. Due to the time constraint, I went for rolling upgrade. 

# Methodology for capacity planning and costing:

## Capacity Planning
* Requests handled by a pod per second = TPS
* Complexity of the Application w.r.t baseline application for which TPS was calculated = C
* Number of pods required for handling the requests = P = 10K/(TPS/C) (ceil to nearest integer)
* Number of pods per Kubernetes worker node = PW
* Number of Kubernetes worker nodes required = NW = P/PW (ceil to nearest integer)
* Average internal data transfer per second = NDInt
* Average external data transfer per second = NDExt
* Average data stored in stackdriver at any time = NDStack
* Number of Database nodes = ND

## Costing
* Average cost for worker Node per second(includes ip cost) = CW
* Average cost for Database hosting per second(includes ip cost) = CD
* Average cost for Load Balancer per second = CL
* Average cost for internal network (data transfer) per GB = CNInt
* Average cost for external network (data transfer) per GB = CNExt
* Average Cost for stackdriver per GB per second = CStack
* Number of seconds in year = T

Total Cost = (NW * CW + ND * CD + CL + NDStack * CStack + NDExt * CExt + NDInt * CInt)*T + Domain_cost

# Operational limits:
1. If the migrations applied for new deployment have conflicts with that of the current deployment, the application availabillity might be affected during the deployment window.
I have made the assumption that such scenarios if present are handled by the application itself.
If such a scenario is inevitable for every deployment, I will go for blue green deployment (create database, pods, load balancer).
Once the application has been tested thoroughly, the dns can be pointed to the new load balancer and the old infra can be decommisioned.
This approach also has its own tradeoffs like increased cost of deployment, data migration if any.
In short this is something which is dependent on the application.
2. It has been assumed that the application would be stateless. If any state is present, it should be maintained on a database.
3. The current deployment has been done only for a single region. This can be extended to multiple regions and a global load balancer can be used to route traffic depending on latency, geolocation etc..,


# Improvements:
* Blue/Green strategy for deployment
* Application monitoring and alerts
* Although Google Cloud has been chosen as cloud provider, I would have done a performance and cost analysis on multiple cloud vendors like AWS, Azure etc..,
* I would have tested the performance on multiple container orchestration platforms like Kubernetes, ECS, Openshift etc..,
* Depending on the application, a cache server would have been chosen.
* Database would also be chosen depending on the application (like a nosql, graph, documentdb, rds, etc..,).
* A performance comparision would have been done for various WSGI servers like uWSGI, gunicorn etc..,
* Would have made cicd jobs on tools like Jenkins, Bamboo etc..,
* Although infra provisioning is being done by shell script, I would have used terraform for infra provisioning which provides state management and easier way to track changes.
* Add some static analyis checks 
