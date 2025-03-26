apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-backend-service
  namespace: {{ .Release.Namespace | default "default" }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Values.appName | default "digital-store" }}
    tier: backend
  ports:
    - port: 8080
      targetPort: 8080
      name: http
