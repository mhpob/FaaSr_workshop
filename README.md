# Building and Deploying Ecological Forecasts with neon4cast and FaaSr

As a part of this workshop, we will run a ecological forecasting workflow that uses [neon4cast package](https://github.com/eco4cast/neon4cast) using FaaSr. 

## Prerequisites
Before we start running the workflow, you need to complete some prerequisites and keep the following things ready.
- A Github account
- A Github personal access token (PAT)
- RStudio on Posit Cloud (recommended) or a local Docker-based installation. 
- a Minio S3 bucket (you can use the [Play Console](https://min.io/docs/minio/linux/administration/minio-console.html#minio-console) to use a public/unauthenticated server)

While you can use your existing GitHub PAT if you have one, it is recommended that you create a short-lived GitHub PAT token for this tutorial if you plan to use Posit Cloud. [Detailed instructions to create a PAT are available here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic); in summary:

* In the upper-right corner of any page, click your profile photo, then click Settings.
* In the left sidebar, click Developer settings.
* In the left sidebar, click Personal access tokens (Classic).
* Click Generate new token (Classic); *note: make sure to select Classic*
* In the "Note" field, give your token a descriptive name.
* In scopes, select “workflow” and “read:org” (under admin:org). 
* Copy and paste the token; you will need to save it to a file in your computer for use in the tutorial

