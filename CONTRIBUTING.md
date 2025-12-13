# Contributing to the Immich Helm Chart

Thank you for considering a contribution to this repository.

## Issues

If you find bugs or are missing features, you can raise an issue. First, please
search [open issues](https://github.com/Javex/immich-helm/issues) to make sure
your issue hasn't been reported already. If it has, leave a thumbs up on the
description of the issue to indicate you're also interested or affected. If you
want to receive updates about an open issue, use the "Subscribe" function. Only
comment if you have new information to add.

If you have found a new bug or want to request a new feature, [create an
issue](https://github.com/Javex/immich-helm/issues/new) and fill out the
description.

For bugs, provide enough detail so they can be reproduced. Ideally, your entire
`values.yaml` and the version you used.

For new features, describe what you'd like the behaviour to be. If you can,
provide an example `values.yaml` block that you'd like to work, and what the
outcome should be.

## Pull Requests

### Versioning

We use [semantic versioning](https://semver.org/) for the chart versions. Once a
pull request is merged, a new version automatically released. As a result, you
should make sure you always update the version and pick the right number to
increment:

- **Major** (the first number): version when you make incompatible API changes
- **Minor** (the second number): version when you add functionality in a backward compatible manner
- **Patch** (the third number): version when you make backward compatible bug fixes

### Changelog

We use the [Artifact Hub changelog annotiation](https://artifacthub.io/docs/topics/annotations/helm/)
which means for each change you make, add an annotiation to the `Chart.yaml` file:

```yaml
annotations:
  artifacthub.io/changes: |
    - kind: added
      description: Add CONTRIBUTING.md
      links:
        - name: GitHub PR
          url: https://github.com/Javex/immich-helm/pull/7
```

Remove any previous changes as each version only contains its latest changelog.
You can then view the [full changelog on Artifact Hub](https://artifacthub.io/packages/helm/immich-helm/immich?modal=changelog)
