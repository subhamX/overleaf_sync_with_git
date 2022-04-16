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

## Getting the required parameters
### OVERLEAF_PROJECT_ID
The OVERLEAF_PROJECT_ID secret can be copied from the Overleaf URL of the project you want to sync.
The project ID of the following URL ```https://www.overleaf.com/project/12345a6b7890cdef1a23456b``` would be ```12345a6b7890cdef1a23456b```

### OVERLEAF_COOKIE
This value is a bit trickier to find. It is used to authenticate the action against the Overleaf servers. It is part of the cookie that Overleaf sets in your browser after you successfully login. The process of extracting the required value differs from browser to browser.

In either case open the developer console (Hotkey F12). For Firefox look for the ```Storage``` tab and then select ```Cookies```. For Edge the same setting can be found under ```Application``` and then ```Storage -> Cookies```.
Look for a cookie with the name ```overleaf_session2``` and copy its value.

This github action expects a certain key-value syntax for the cookie to work:
```
Cookie: overleaf_session2=<YOUR_SESSION_COOKIE_VALUE>
```

> Note: More finer details will be added here soon. 
