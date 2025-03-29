apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: digital-store-alb
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: "/api/health"
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: "15"
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "5"
    alb.ingress.kubernetes.io/healthy-threshold-count: "2"
    alb.ingress.kubernetes.io/unhealthy-threshold-count: "2"
    alb.ingress.kubernetes.io/success-codes: "200-399"
    alb.ingress.kubernetes.io/subnets: ${public_subnet_ids}
    alb.ingress.kubernetes.io/tags: Environment=${environment},Project=${app_name}
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: digital-store-backend
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: digital-store-frontend
            port:
              number: 80  
