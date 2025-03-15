apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432 