apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-frontend
  namespace: {{ .Release.Namespace | default "default" }}
  labels:
    app: {{ .Values.appName | default "digital-store" }}
    tier: frontend
spec:
  replicas: {{ .Values.frontend.replicas | default 2 }}
  selector:
    matchLabels:
      app: {{ .Values.appName | default "digital-store" }}
      tier: frontend
  template:
    metadata:
      labels:
        app: {{ .Values.appName | default "digital-store" }}
        tier: frontend
    spec:
      containers:
        - name: react-container
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag | default "latest" }}"
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: {{ .Values.frontend.resources.requests.memory | default "128Mi" }}
              cpu: {{ .Values.frontend.resources.requests.cpu | default "100m" }}
            limits:
              memory: {{ .Values.frontend.resources.limits.memory | default "256Mi" }}
              cpu: {{ .Values.frontend.resources.limits.cpu | default "200m" }}
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
