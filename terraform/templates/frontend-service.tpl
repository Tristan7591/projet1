apiVersion: v1
kind: Service
metadata:
  name: digital-store-frontend-service
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: digital-store
    tier: frontend
  ports:
    - port: 80
      targetPort: 80
      name: http 