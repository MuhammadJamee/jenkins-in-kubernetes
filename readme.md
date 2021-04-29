# Plugin Needs To Be Installed
- Docker pipeline
- Pipeline Maven Integration

# Google LB Healthcheck 

  /jenkins/login


# Setting up Jenkins Agent

After installing `kubernetes-plugin` for Jenkins
* Go to Manage Jenkins | Bottom of Page | Cloud | Kubernetes (Add kubenretes cloud)
* Fill out plugin values
    * Name: kubernetes
    * Kubernetes URL: https://kubernetes.default:443
    * Kubernetes Namespace: jenkins
    * Credentials | Add | Jenkins (Choose Kubernetes service account option & Global + Save)
    * Test Connection | Should be successful! If not, check RBAC permissions and fix it!
    * Jenkins URL: http://(jenkins-ip/cluster-ip)
    * Tunnel : (jenkins-ip/cluster-ip):50000
    * Apply cap only on alive pods : yes!
    * Add Kubernetes Pod Template
        * Name: jenkins-slave
        * Namespace: jenkins
        * Service Account: jenkins
        * Labels: jenkins-slave (you will need to use this label on all jobs)
        * Containers | Add Template
            * Name: jnlp
            * Docker Image: ghauri1/jenkins-slave:v1
            * Command to run : <Make this blank>
            * Arguments to pass to the command: <Make this blank>
            * Allocate pseudo-TTY: yes
            * Add Volume
                * HostPath type
                * HostPath: /var/run/docker.sock
                * Mount Path: /var/run/docker.sock
        * Timeout in seconds for Jenkins connection: 300
* Save

* Jenkins Pipeline Without PODtemplate

```
node('jenkins-slave') {
    
     stage('unit-tests') {
        sh(script: """
            docker run --rm alpine /bin/sh -c "echo hello world"
        """)
    }
}
```
* Jenkins Pipeline With PODtemplate

```
podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:19.03.1-dind
    resources:
    requests:
      cpu: 1000m
      memory: 1024Mi
    limits:
      cpu: 2000m
      memory: 2048Mi
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
''') {
    node(POD_LABEL) {
        git 'https://github.com/nginxinc/docker-nginx.git'
        container('docker') {
            sh 'docker version && cd stable/alpine/ && docker build -t nginx-example .'
        }
    }
}

```

reference: 
https://plugins.jenkins.io/pipeline-maven/
https://cloud.google.com/sdk/docs/install#deb

---
  # set-prefix
        # - name: JENKINS_OPTS
        #   value: "--prefix=/jenkins"
        # - name: CASC_JENKINS_CONFIG
        #   value: /var/jenkins_home/casc.yaml 
---

---
  # Jenkins-tunnel
    # - http://34.102.183.78/jenkins
    # -  jenkins.jenkins.svc.cluster.local:50000
---