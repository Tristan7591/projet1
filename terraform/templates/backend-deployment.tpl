apiVersion: apps/v1
kind: Deployment
metadata:
  name: digital-store-backend
  namespace: default
  labels:
    app: digital-store
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: digital-store
      tier: backend
  template:
    metadata:
      labels:
        app: digital-store
        tier: backend
    spec:
      containers:
        - name: spring-boot-container
          image: "${ecr_repository_url}:${image_tag}"
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          readinessProbe:
            httpGet:
              path: /api/actuator/health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/actuator/health
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 20
          volumeMounts:
            - name: config-volume
              mountPath: /app/config
          env:
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: POSTGRES_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: POSTGRES_PASSWORD
            - name: DB_NAME
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: POSTGRES_DB
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: POSTGRES_HOST
      volumes:
        - name: config-volume
          configMap:
            name: digital-store-config 