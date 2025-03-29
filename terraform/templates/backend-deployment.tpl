apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-backend
  namespace: {{ .Release.Namespace | default "default" }}
  labels:
    app: {{ .Values.appName | default "digital-store" }}
    tier: backend
spec:
  replicas: {{ .Values.backend.replicas | default 1 }}
  selector:
    matchLabels:
      app: {{ .Values.appName | default "digital-store" }}
      tier: backend
  template:
    metadata:
      labels:
        app: {{ .Values.appName | default "digital-store" }}
        tier: backend
    spec:
      containers:
        - name: spring-boot-container
          image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag | default "latest" }}"
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: {{ .Values.backend.resources.requests.memory | default "256Mi" }}
              cpu: {{ .Values.backend.resources.requests.cpu | default "100m" }}
            limits:
              memory: {{ .Values.backend.resources.limits.memory | default "512Mi" }}
              cpu: {{ .Values.backend.resources.limits.cpu | default "200m" }}
          readinessProbe:
            httpGet:
              path: /api/health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
          livenessProbe:
            httpGet:
              path: /api/actuator/health
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 20
            timeoutSeconds: 5
          volumeMounts:
            - name: config-volume
              mountPath: /app/config
          env:
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.secrets.rds.name | default "rds-credentials" }}
                  key: DB_USERNAME
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.secrets.rds.name | default "rds-credentials" }}
                  key: DB_PASSWORD
            - name: DB_NAME
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.secrets.rds.name | default "rds-credentials" }}
                  key: DB_NAME
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.secrets.rds.name | default "rds-credentials" }}
                  key: DB_HOST
            - name: DB_PORT
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.secrets.rds.name | default "rds-credentials" }}
                  key: DB_PORT
      volumes:
        - name: config-volume
          configMap:
            name: {{ .Values.configMap.name | default "digital-store-config" }}
