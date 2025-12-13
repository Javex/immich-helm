# Immich

This chart installs [Immich](https://immich.app/), a self-hosted photo and video management solution.

# TL;DR

```bash
$ helm repo add javex https://javex.github.io/immich-helm/
$ helm install --namespace immich install immich javex/immich
```

## Introduction

The chart provides an alternative to the [official Helm chart](https://github.com/immich-app/immich-charts).
It avoids using the [bjw-s](https://github.com/bjw-s-labs/helm-charts) library
chart. Instead, it uses Helm template files directly. This allows it to follow
Helm best practices more closely and pick typical parameter names in the
`values.yaml` file.

If you are coming from the official chart, you need to explicitly migrate to the
new format. Be careful when doing the migration to avoid breaking your
installation. This chart prioritises Helm best practices over backwards
compatibility with the official chart.

## Database

By default, this chart ships with a very minimal Postgres installation. It is
based on the [official Docker Compose installation](https://docs.immich.app/install/docker-compose),
using [Immich's provided Postgres image](https://github.com/immich-app/base-images/pkgs/container/postgres).
This image contains the [necessary extensions](https://docs.immich.app/administration/postgres-standalone)
for the database to work with Immich.

While this default image provides an equivalent to the docker-compose file, it
might not be the most suitable for a production deployment. You can use a
[pre-existing Postgres database](https://docs.immich.app/administration/postgres-standalone),
but make sure to follow the linked instructions to ensure your Postgres
installation supports the necessary extensions.

You can then update your `values.yaml` to use an external database:

```yaml
server:
  env:
    DB_USERNAME: immich
    DB_PASSWORD: <insert secure password>
    DB_DATABASE_NAME: immich
    DB_HOSTNAME: mydb.mynamespace.svc.cluster.local
```

If you don't wish to put the password in your Helm values, you can set an empty
string here and [provide it externally](#external-secrets).

## External Secrets

You can provide secrets to this chart without adding the literal secret values
to the `values.yaml`. A common approach is the [External Secrets Operator](https://external-secrets.io/).
To keep secrets out of your `values.yaml`, create the `Secret` resource
externally. Then mount it into the container. For example, to provide the
database password externally, you could do this:

```yaml
server:
  env:
    DB_PASSWORD: ""
  extraEnvFrom:
    - secretRef:
      name: my-secrets
```

Ensure that `my-secrets` contains a `DB_PASSWORD` key with the correct value.

## Disable Default Configuration

By default, the chart ships with a minimal configuration that tells the server
where to find the machine learning service. However, when a configuration is
provided, Immich does not allow the administrator to change settings via the UI
(as these would be overwritten by a new deployment or there would be conflicts).
If you prefer to configure Immich via the UI, you can disable this configuration
file:

```yaml
server:
  configuration: null
```

> [!TIP]
> When disabling the default configuration, update the Machine Learning settings
> to provide the correct URL. The helm chart's NOTES that are shown when you
> install it will print the correct URL if configuration is disabled.

## External Configuration

Similar to the [approach for external secrets](#external-secrets), it is
possible to provide configuration externally. This can be useful if you want to
put secrets into the configuration, for example an SMTP password for sending
emails. Add this to your `values.yaml`:

```yaml
server:
  # Setting this to `null` disables the default configuration
  configuration: null
  env:
    IMMICH_CONFIG_FILE: /config/immich-config.yaml
  volumes:
    - name: config
      secret:
        # Create this Secret externally
        secretName: immich-server-config
  volumeMounts:
    - name: config
      mountPath: /config
```

This [disables the default configuration](#disable-default-configuration), and
allows you to provide your own configuration file. Because configuration is
disabled entirely, the Helm chart will not tell Immich about a configuration
file, so you need to set `IMMICH_CONFIG_FILE` explicitly. Then you mount the
configuration from an external source.

## Valkey (Redis Cache)

Caching is provided by the [valkey-helm](https://github.com/valkey-io/valkey-helm)
chart. At the moment there is no option to disable it or provide an external
cache. Raise an issue if you would like to use an external Valkey or Redis
instance.

By default, Valkey's authentication is disabled, relying on network security
alone. Refer to the [Valkey Helm chart's authentication documentation](https://github.com/valkey-io/valkey-helm/tree/main/valkey#authentication)
for how to enable authentication. You then need to provide the [correct
environment variables](https://docs.immich.app/install/environment-variables#redis)
to Immich so it can authenticate.

Persistence is disabled for Valkey by default. When a pod re-created, Valkey's
data is lost. This is the default for the [Docker Compose installation](https://docs.immich.app/install/docker-compose),
so it is fine for Immich. Valkey is used to store jobs, which Immich will
re-schedule if they were lost. However, if you'd still like data to survive pod
re-creation, you can enable persistence:

```yaml
valkey:
  dataStorage:
    enabled: true
    requestedSize: 200Mi
```

The size for the volume is only guide. Observe your installation's storage use
and adjust it as needed.

For a complete list of options, refer to the [valkey helm chart](https://github.com/valkey-io/valkey-helm).

## Reverse Proxy (`HTTPRoute`)

> [!NOTE]
> At the moment, only [Gateway API](https://gateway-api.sigs.k8s.io/)
> (`HTTPRoute`) is supported. If you'd like to use `Ingress`, raise an issue.

This charts supports access through a reverse proxy by creating a `HTTPRoute`.
Ensure you have a gateway created to expose your instance. Then add this to your
`values.yaml`:

```yaml
server:
  configuration:
    server:
      externalDomain: https://immich.example.com
httpRoute:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: gateway-namespace
  hostnames:
    - immich.example.com
```

Make sure your DNS server points at the gateway for the hostname you picked (or
configure something like [External DNS](https://kubernetes-sigs.github.io/external-dns).

The `externalDomain` configuration is necessary for Immich to render public
shared links correctly.

You can check that the route is valid using the following command:

```bash
kubectl describe --namespace immich httproutes.gateway.networking.k8s.io immich-server
```

Replace the namespace and resource name if you've changed them from the default.
The `Status` field contains an explanation of whether the route is ready or
there were any errors.

## Migrating from the official chart

If you are coming from the official
