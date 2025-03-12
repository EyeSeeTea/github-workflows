# github-workflows

`<appRepo>/.github/workflows/main.yml`
```yaml
name: "Shared Master Workflow"

on:
  push:
    branches: ["master", "development"]
  pull_request:
    branches: [ "master", "development" ]
  workflow_dispatch:

jobs:
  master-workflow:
    uses: EyeSeeTea/github-workflows/.github/workflows/master.yml@master
```