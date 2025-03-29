apiVersion: v1
kind: Secret
metadata:
  name: rds-credentials
  namespace: default
  labels:
    app: digital-store
    type: database-credentials
type: Opaque
data:
  DB_NAME: ${db_name}
  DB_USERNAME: ${db_username}
  # DB_PASSWORD is populated by the prepare-rds-secret.sh script from SSM
  DB_HOST: ${db_host}
  DB_PORT: ${db_port}
  SPRING_DATASOURCE_URL: ${spring_datasource_url} 