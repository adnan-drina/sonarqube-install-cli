# sonarqube-install-cli
Deploy Sonarqube on OpenShift using a deployment template.

## Create a Project
[sonarqube-namespace.yaml](sonarqube-namespace.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    openshift.io/description: "Catch bugs and vulnerabilities in your app, with thousands of automated Static Code Analysis rules."
    openshift.io/display-name: "SonarQube Static Code Analysis"
  name: sonarqube
```
```shell script
oc apply -f sonarqube-namespace.yaml
```
or
```shell script
oc new-project sonarqube
```

## Apply the Deployment template
- Template will trigger a Deployment, create the Service and expose Route

[sonarqube-template.yaml](sonarqube-template.yaml)
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
  labels:
    app: sonarqube
    app.kubernetes.io/component: sonarqube
    app.kubernetes.io/instance: sonarqube
    app.kubernetes.io/name: sonarqube
    app.kubernetes.io/part-of: sonarqube
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarqube
      name: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
        name: sonarqube
    spec:
      containers:
        - name: sonarqube
          imagePullPolicy: Always
          image: docker.io/sonarqube:8-community
          ports:
            - containerPort: 9000
              protocol: TCP
          volumeMounts:
            - mountPath: /opt/sq/temp
              name: sonarqube-temp
            - mountPath: /opt/sq/conf
              name: sonarqube-conf
            - mountPath: /opt/sq/data
              name: sonarqube-data
            - mountPath: /opt/sq/extensions
              name: sonarqube-extensions
            - mountPath: /opt/sq/logs
              name: sonarqube-logs
          livenessProbe:
            failureThreshold: 10
            httpGet:
              path: /
              port: 9000
              scheme: HTTP
            initialDelaySeconds: 45
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 10
            httpGet:
              path: /
              port: 9000
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          resources:
            limits:
              cpu: "1"
              memory: 4Gi
            requests:
              cpu: 200m
              memory: 512Mi
      volumes:
        - name: sonarqube-temp
          emptyDir: {}
        - name: sonarqube-conf
          emptyDir: {}
        - name: sonarqube-data
          emptyDir: {}
        - name: sonarqube-extensions
          emptyDir: {}
        - name: sonarqube-logs
          emptyDir: {}
---
apiVersion: v1
kind: Route
metadata:
  labels:
    app: sonarqube
  name: sonarqube
spec:
  port:
    targetPort: 9000-tcp
  tls:
    termination: edge
  to:
    kind: Service
    name: sonarqube
    weight: 100
  wildcardPolicy: None
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: sonarqube
  name: sonarqube
spec:
  ports:
    - name: 9000-tcp
      port: 9000
      protocol: TCP
      targetPort: 9000
  selector:
    app: sonarqube
    name: sonarqube
  type: ClusterIP
```
```shell script
oc apply -f sonarqube-template.yaml -n sonarqube
```

### Access SonarQube GUI
```shell script
oc get routes -n sonarqube
```
You should see one route:
- sonarqube — is for connecting to the gui

connect to the route named **sonarqube** using your browser
and login using credentials (username/password: admin/admin)

---
Installation is base on the example provided by 
[Siamak Sadeghianfar](https://github.com/siamaksade/tekton-cd-demo/blob/pipelines-1.2/cd/sonarqube.yaml)