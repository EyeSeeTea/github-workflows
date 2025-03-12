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

To test changes in a branch:

run `./create-test-master.sh` (this copies the master.yml to test-master.yml and replaces @master with @branchname)

replace `<branchname>`
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
    uses: EyeSeeTea/github-workflows/.github/workflows/test-master.yml@branchname

```