apiVersion: v1
kind: Service
metadata:
  name: digital-store-frontend
  namespace: default
  labels:
    app: digital-store
    tier: frontend
spec:
  selector:
    app: digital-store
    tier: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
