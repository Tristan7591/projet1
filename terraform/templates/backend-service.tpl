apiVersion: v1
kind: Service
metadata:
  name: digital-store-backend
  namespace: default
  labels:
    app: digital-store
    tier: backend
spec:
  selector:
    app: digital-store
    tier: backend
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
