apiVersion: v1
kind: ConfigMap
metadata:
  name: digital-store-config
  namespace: default
data:
  application.yml: |
    spring:
      application:
        name: digital-store
      datasource:
        url: jdbc:postgresql://${DB_HOST:localhost}:5432/${DB_NAME:digitalstore}
        username: ${DB_USERNAME:postgres}
        password: ${DB_PASSWORD:postgres}
        driver-class-name: org.postgresql.Driver
      jpa:
        hibernate:
          ddl-auto: validate
        show-sql: false
        properties:
          hibernate:
            format_sql: true
            dialect: org.hibernate.dialect.PostgreSQLDialect
      flyway:
        enabled: true
        baseline-on-migrate: true
        locations: classpath:db/migration
    
    server:
      port: 8080
      servlet:
        context-path: /api
        
    management:
      endpoints:
        web:
          exposure:
            include: health,info
      endpoint:
        health:
          show-details: always 