# Overleaf Sync with Git


🤖 Automatically sync and backup your Overleaf projects to Git - works with online, self-hosted, and other LaTeX editors


## Usage

Ensure that you have set **OVERLEAF_COOKIE** and **OVERLEAF_PROJECT_ID** as GitHub secrets. Head over to [this link](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) to get more info on how to add secrets to a GitHub repo.

You may also need to edit your project settings to allow workflows to write to your repository. Click on Settings -> then Actions and ensure that under Workflow permissions you've provided Read and write permissions to workflow.
![image](https://github.com/MattHeffNT/overleaf_sync_with_git/assets/43654114/a1a7203c-3ff4-4712-ba3e-d32df0605b50)


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
    - name: Delete Old Artifacts
      uses: actions/github-script@v6
      id: artifact
      with:
        script: |
          const res = await github.rest.actions.listArtifactsForRepo({
            owner: context.repo.owner,
            repo: context.repo.repo,
          })

          res.data.artifacts
            .forEach(({ id }) => {
              github.rest.actions.deleteArtifact({
                owner: context.repo.owner,
                repo: context.repo.repo,
                artifact_id: id,
              })
            })

    - name: Fetch the latest version from overleaf server
      uses: subhamx/overleaf_sync_with_git@master
      with:
        OVERLEAF_PROJECT_ID: ${{ secrets.OVERLEAF_PROJECT_ID }}
        OVERLEAF_COOKIE: ${{ secrets.OVERLEAF_COOKIE }}

    - name: Upload to Project Artifacts
      uses: actions/upload-artifact@v4
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

> **IMPORTANT:** I would recommend that after you copy overleaf_session2 cookie and put it in the GitHub actions secret, please delete the cookie from the browser. And then start a new browser session (by logging in again) if required. **Please do not logout,** it will make overleaf revoke the credentials. If you follow the above point, then the cookie should remain active for atleast 2 months, and the workflow should work without any issues. We've tested it in early 2023 by working a sample workflow for couple of months, and you can find the insights [here](https://github.com/subhamX/overleaf_sync_with_git/pull/4#issuecomment-1355116634).

In the following case, please put `s%3A3xxaFrMMXWi1xxxtm23BjBYJTc8GAb7P.xxyxxzhxxrPJxxovoxxaafnxx9ZorxxP6YxxzxfxxIo` as the OVERLEAF_COOKIE value.

<img width="1357" alt="image" src="https://user-images.githubusercontent.com/43654114/219082856-5a235fe7-5884-4b2f-b176-52912dd863ae.png">


## Optional Parameters
### OVERLEAF_HOST
The OVERLEAF_HOST parameter can be used to sync with a self-hosted Community Edition or Server Pro Overleaf instance. The parameter defaults to `www.overleaf.com`, when not set.

To set the value, just add the environment variable to the actions step, as seen below:
```
    - name: Fetch the latest version from overleaf server
      uses: subhamx/overleaf_sync_with_git@master
      with:
        OVERLEAF_PROJECT_ID: ${{ secrets.OVERLEAF_PROJECT_ID }}
        OVERLEAF_COOKIE: ${{ secrets.OVERLEAF_COOKIE }}
        OVERLEAF_HOST: ${{ secrets.OVERLEAF_HOST }}
```
