# Examples

Here you can find some examples to help get you started. Make sure to read
through the comments in the file as well as the corresponding section here to
fully understand the example.

## Migrate

In [`migrate.yaml`](./migrate.yaml), you'll find an example that is as closely aligned to the
[official `local/values.yaml` example](https://github.com/immich-app/immich-charts/blob/main/local/values.yaml)
as possible. If you developed your release based on this example, then
`migrate.yaml` will help you migrate to this Helm chart.

However, it's important to understand that there is no exact 1-to-1 migration!
We highly recommend carefully reviewing the differences to ensure you're not
breaking your release. The main issues to keep an eye on:

- This guide was written for commit [eda40d0](https://github.com/immich-app/immich-charts/blob/eda40d0d059d3e211ebe0dd5a32f2b8ac0cd68cc/local/values.yaml).
  As the official chart gets updated, these instructions might become invalid.
  If you find any discrepancies, please [contribute](/CONTRIBUTING.md) to get
  it fixed.

- The Valkey (cache) deployment will be completely replaced. This shouldn't
  cause any issues since Valkey is just used for jobs, but we recommend using a
  quiet period so there are no outstanding jobs
  that get lost. Immich should re-create them even if they're lost, though.
  This chart uses the new, [official valkey-io chart](https://github.com/valkey-io/valkey-helm).
  You'll see quite a few changes when deploying, though none should be
  breaking.

- The example sets `server.configuration = null` to mimic the original example,
  which doesn't mount a configuration file. However, by default, we provide a
  single configuration option to immich: `machineLearning.urls` which contains
  the URL to the included machine learning service. The official chart uses the
  `IMMICH_MACHINE_LEARNING_URL` environment variable which has been [deprecated](https://github.com/immich-app/immich/discussions/6630#discussioncomment-8235018).
  If you set _any_ configuration value, then you won't be able to edit the
  configuration in the admin UI, so make sure to export your current
  configuration first if you want to configure Immich through this Helm chart.

- Versions might change: The example does not hard-code any values since they'll
  get quickly out of date. However, there are commented-out parts in the
  example that show how to provide a version. If you want to avoid version
  changes, set those to match your current version exactly. Version upgrades
  should usually be fine, version downgrades can cause a lot of issues. We
  recommend to use your exact current version and then update separately to
  decouple the migration from the update.

Before getting started, add the Helm repo:

```bash
helm repo add immich-helm https://javex.github.io/immich-helm
```

Prepare your migration by setting these two environment variables.

- `IMMICH_NAMESPACE` is the namespace in which Immich is currently installed
- `IMMICH_RELEASE` is the name of the Helm release in the namespace

```bash
export IMMICH_NAMESPACE=immich
export IMMICH_RELEASE=immich
```

To aid in understanding the changes, we recommend using the [helm-diff
plugin](https://github.com/databus23/helm-diff). This allows you to view all
the changes that would be made by replacing the Helm chart. We
recommend you run it like this:

```bash
helm diff upgrade --namespace "$IMMICH_NAMESPACE" "$IMMICH_RELEASE" immich-helm/immich -f migrate.yaml --normalize-manifests
```

The `--normalize-manifests` option provides a cleaner diff that's easier to
review. There will be quite a few expected changes:

- Lots of labels & annotations change. This is expected.
- Some default values are not set explicitly (e.g. `dnsPolicy`). Unless you
  changed anything, this is safe as they were set to their defaults anyway.
- The `REDIS_HOSTNAME` variable is removed, because it is now set through a
  `Secret` that contains environment variables.
- The `IMMICH_MACHINE_LEARNING_URL` variable is removed, as explained
  previously.
- Lots of Valkey-related changes. This is due to using a different way to
  create a Valkey instance, as explained above.
- A new `Secret` is created. By default it only contains the `REDIS_HOSTNAME`
  variable, but you can set more in `server.env`.

Carefully review the changes that `helm-diff` is showing you before performing
the migration. If there are differences outside of the above, update your
`migrate.yaml` to mimic your current resources. If you are unable to do so with
the current chart or run into any problems, raise an issue in this repo. Once
you're satisfied, you'll need to remove the existing deployments as they have immutable
fields. Don't worry, no data will be lost. However, there **will** be downtime,
so make sure nobody needs to access Immich right now.

First fetch the list of deployments:

```bash
kubectl get --namespace "$IMMICH_NAMESPACE" deployment.apps
```

This should show three deployments, which are all safe to delete:

```bash
kubectl delete --namespace "$IMMICH_NAMESPACE" deployment immich-machine-learning
kubectl delete --namespace "$IMMICH_NAMESPACE" deployment immich-server
kubectl delete --namespace "$IMMICH_NAMESPACE" deployment immich-valkey
```

Now that all deployments have been removed, you can upgrade your release and it
will re-create them:

```bash
helm upgrade --namespace "$IMMICH_NAMESPACE" "$IMMICH_RELEASE" immich-helm/immich -f migrate.yaml
```

After this, make sure that Immich is running again. You can wait for it to
finish:

```bash
kubectl rollout status --namespace "$IMMICH_NAMESPACE" deployment immich-machine-learning
kubectl rollout status --namespace "$IMMICH_NAMESPACE" deployment immich-server
kubectl rollout status --namespace "$IMMICH_NAMESPACE" deployment immich-valkey
```

If there are any issues, check the logs for the container, for example:

```bash
kubectl logs --namespace "$IMMICH_NAMESPACE" deployment/immich-server
```

Finally, visit your Immich instance to confirm it's available again.

At this point, you have successfully migrated to our Helm chart.
Congratulations!

If you're interested, review [our documentation](/charts/immich/README.md) to
explore all available options.
