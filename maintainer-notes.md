# Releasing

When releasing make sure to tag the repo with the specific version `v1.2.3` and
the major version `v1`.

```bash
$ git tag v1.2.3
$ git tag -f v1
```

Then push the tags.

```bash
$ git push origin v1.2.3
$ git push -f origin v1
```
