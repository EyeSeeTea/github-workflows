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

optional parameters can be passed
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
    with:
      # --- to specify runner. By default:
      # --- the runner is `ubuntu-latest` if repo is public
      # --- the runner is `self-hosted` if repo is private
      #runner: "ubuntu-latest"
      
      # --- codeQL parameters
      # languages: '["javascript-typescript", "python"]'
      # build_mode: "manual"
      
      # --- to specify bundlemon config branch in repo. Usually for testing
      # --- can also be customized in caller repo
      #bundlemonrc_branch_name: "development"
      # --- to specify which flows to run. 'all' by default
      #workflows_to_run: "run-tests,codeql-scan"
```