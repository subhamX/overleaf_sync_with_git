# Overleaf Sync with Git


🤖 A GitHub action to take backups from OverLeaf which is an Online LaTeX Editor.


## Usage

Ensure that you have set **OVERLEAF_COOKIE** and **OVERLEAF_PROJECT_ID** as GitHub secrets. Head over to [this link](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) to get more info on how to add secrets to a GitHub repo.

Once you have set the secrets. Just create a new workflow file in `.github/workflows/FILE_NAME.yml` and add the following content.
```yaml
name: Overleaf Sync with Git
on:
  schedule:
    - cron: "0/5 * * * *"
  push:
  workflow_dispatch:
      
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Fetch the latest version from overleaf server
      uses: subhamx/overleaf_sync_with_git@master
      with:
        OVERLEAF_PROJECT_ID: ${{ secrets.OVERLEAF_PROJECT_ID }}
        OVERLEAF_COOKIE: ${{ secrets.OVERLEAF_COOKIE }}

    - name: Upload to Project Artifacts
      uses: actions/upload-artifact@v2
      with:
        name: project
        path: ./artifacts/

    - uses: actions/checkout@v2
      with:
        path: repo/
    
    - run: |
        cd repo/
        mkdir -p overleaf_remote_src
        cp -r ../artifacts/* ./overleaf_remote_src
        git config user.name "Overleaf Sync Bot"
        git config user.email "actions@github.com"
        git add .
        if [[ $(git diff HEAD --stat) == '' ]]; then (echo 'Working tree is clean') 
        else (git commit -m "Sync with overleaf remote"  && git push) fi
```

> Note: More finer details will be added here soon. 
