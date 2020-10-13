# Reference chart for a configmap with actual files included and templated

> This chart has no functional value, it is just for demostrating a specific Helm templating strategy

Showcases:
- how to include a series of files in a configMap
- pass each of this files into the Helm templating engine to hydrated `.Values`

## Usage

``
helm install --dry-run test  .
```
