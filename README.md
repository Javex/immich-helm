# Immich Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/immich-helm)](https://artifacthub.io/packages/search?repo=immich-helm)

[![Release Charts](https://github.com/Javex/immich-helm/actions/workflows/release.yaml/badge.svg)](https://github.com/Javex/immich-helm/actions/workflows/release.yaml)

A Helm chart to install [Immich](https://immich.app/) in your Kubernetes cluster.

> [!IMPORTANT]
> This Helm chart is still under development. Expect breaking frequent breaking
> changes. If you'd like to help test this chart, please consider trying it
> out as an early adopter.

This is an **unofficial** Helm chart to provide an alternative to the [official
Immich Helm chart](https://github.com/immich-app/immich-charts). If you need a
more stable and better supported chart, check out the official one.

The main differentiator is that this chart doesn't use the [bjw-s](https://github.com/bjw-s-labs/helm-charts)
library chart, instead relying on raw Helm template files.

## Contribute

See [CONTRIBUTING](CONTRIBUTING.md).
