apiVersion: apps/v1
kind: Deployment
metadata:
  name: digital-store-frontend
  namespace: default
  labels:
    app: digital-store
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: digital-store
      tier: frontend
  template:
    metadata:
      labels:
        app: digital-store
        tier: frontend
    spec:
      containers:
        - name: react-container
          image: "${ecr_repository_url}:${image_tag}"
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 20
            periodSeconds: 10 