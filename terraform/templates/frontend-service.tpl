apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-frontend-service
  namespace: {{ .Release.Namespace | default "default" }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Values.appName | default "digital-store" }}
    tier: frontend
  ports:
    - port: 80
      targetPort: 80
      name: http
