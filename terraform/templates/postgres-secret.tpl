apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: default
type: Opaque
data:
  POSTGRES_USER: "${postgres_user}"
  POSTGRES_PASSWORD: "${postgres_password}"
  POSTGRES_DB: "${postgres_db}"
  POSTGRES_HOST: "${postgres_host}" 