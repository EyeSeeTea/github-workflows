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
      # --- to specify runner for run-tests, codeql-scan and build-check.
      # --- default is `general-runner` (self-hosted)
      #runner: "general-runner"

      # --- optional: runner for dependency-track workflows only
      # --- default is `dependency-track-runner`
      #bom_runner: "dependency-track-runner"
      
      # --- codeQL parameters
      # languages: '["javascript-typescript", "python"]'
      # build_mode: "manual"
      
      # --- to specify bundlemon config branch in repo. Usually for testing
      # --- can also be customized in caller repo
      #bundlemonrc_branch_name: "development"
      # --- to specify which flows to run. 'all' by default
      #workflows_to_run: "run-tests,codeql-scan"
```