apiVersion: v1
kind: Service
metadata:
  name: digital-store-backend-service
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: digital-store
    tier: backend
  ports:
    - port: 8080
      targetPort: 8080
      name: http 