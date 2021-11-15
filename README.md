# Skygear v1 Helm Chart

This Helm chart is supposed to be used as a subchart of your main chart.

Read the [values.yaml](./skygear/values.yaml) to see the configuration of this chart.

This chart does NOT include any ingress. You must define the ingress yourself.

# Recipes

Here are some common customization you want to make

## Define you ingress

Here is an example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myingress
  annotations:
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
spec:
  tls:
  - secretName: web-tls
    hosts:
    - myapp.mydomain.com
  rules:
  - host: myapp.mydomain.com
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /
        backend:
          service:
            name: {{ include "skygear.skygear-server.name" . | quote }}
            port:
              name: http
      - pathType: ImplementationSpecific
        path: /pubsub
        backend:
          service:
            name: {{ include "skygear.skygear-server.master.name" . | quote }}
            port:
              name: http
      - pathType: ImplementationSpecific
        path: /_pubsub
        backend:
          service:
            name: {{ include "skygear.skygear-server.master.name" . | quote }}
            port:
              name: http
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myingress2
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  tls:
  - secretName: web-tls
    hosts:
    - myapp.mydomain.com
  rules:
  - host: myapp.mydomain.com
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /static(/|$)(.*)
        backend:
          service:
            name: {{ include "skygear.staticfiles.name" . | quote }}
            port:
              name: http
```

## Customize forgot password templates

Define a ConfigMap and set `forgotpassword.configMapName`.

For example,

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: forgotpassword
data:
  # Assume files/forgot_password_email.txt is present in your chart.
  forgot_password_email.txt: |-
    {{- .Files.Get "files/forgot_password_email.txt" | nindent 4 }}
```

In your `values.yaml`,

```yaml
# The key "skygear" depends the alias of the subchart.
# If you did not override anything, it should be "skygear".
skygear:
  forgotpassword:
    configMapName: forgotpassword
```

## Serve 1 level of static files

Define a ConfigMap and set `staticfiles.configMapName`

For example,

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: staticfiles
data:
  {{- $currentScope := . }}
  {{- range $path, $- := .Files.Glob "static/**" }}
  {{- with $currentScope }}
  {{ trimPrefix "static/" $path }}: |-
    {{- .Files.Get $path | nindent 4 }}
  {{- end }}
  {{- end }}
```

In your `values.yaml`,

```yaml
skygear:
  staticfiles:
    configMapName: staticfiles
```

The reason for support only 1 level of static files is due to the fact that
there is no easy way to encode a relative path so that it is a valid ConfigMap key.
Helm provides `b64enc` and `b32enc` but both of them always write padding character `=`.
The validation regexp of ConfigMap key is `[-_0-9a-zA-Z]+`.

If you need to serve more than 1 level of static files, consider building your own Nginx image.
Manually enumerating all static file paths are NOT recommended.
