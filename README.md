# Introduction

FaaSr is a package that makes it easy for developers to create R functions and workflows that can run in the cloud, on-demand, based on triggers - such as timers, or repository commits. It is built for Function-as-a-Service (FaaS) cloud computing, and supports both widely-used commercial (GitHub Actions, AWS Lambda, IBM Cloud) and open-source platforms (OpenWhisk). It is also built for cloud storage, and supports the S3 standard also widely used in commercial (AWS S3), open-source (Minio) and research platforms (Open Storage Network). With FaaSr, you can focus on developing the R functions, and leave dealing with the idiosyncrasies of different FaaS platforms and their APIs to the FaaSr package.

# Objective

This guide helps you through the setup and execution of a FaaSr workflow using [neon4cast package](https://github.com/eco4cast/neon4cast). In this tutorial, you will learn how to describe, configure, and execute a FaaSr workflow of R functions in the cloud, using GitHub Actions for cloud execution of functions, and a public Minio S3 “bucket” for cloud data storage. With the knowledge gained from this tutorial, you will be able to also run FaaSr workflows in OpenWhisk and Amazon Lambda, as well as use an S3-compliant bucket of your choice. 


# Prerequisite requirements

This tutorial is designed to work with either a Posit Cloud instance (recommended), or the [rocker/rstudio Docker container](https://rocker-project.org/) (on your own computer). You can also run this tutorial from your existing RStudio environment - you will need to install devtools, sodium, minioclient, and credentials packages for FaaSr.

Before we start running the workflow, you need to complete some prerequisites and keep the following things ready.
- A Github account
- A Github personal access token (PAT)
    - While you can use your existing GitHub PAT if you have one, it is recommended that you create a short-lived GitHub PAT token for this tutorial if you plan to use Posit Cloud. [Detailed instructions to create a PAT are available here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic); in summary:
  
    * In the upper-right corner of any page, click your profile photo, then click Settings.
    * In the left sidebar, click Developer settings.
    * In the left sidebar, click Personal access tokens (Classic).
    * Click Generate new token (Classic); *note: make sure to select Classic*
    * In the "Note" field, give your token a descriptive name.
    * In scopes, select “workflow” and “read:org” (under admin:org). 
    * Copy and paste the token; you will need to save it to a file in your computer for use in the tutorial
- a Minio S3 bucket (you can use the [Play Console](https://min.io/docs/minio/linux/administration/minio-console.html#minio-console) to use a public/unauthenticated server)
    * You can try out the Minio Console using https://play.min.io:9443. Log in with the following credentials:
    ```
    Username: Q3AM3UQ867SPQQA43P2F
    Password: zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG
    ```

- RStudio on Posit Cloud (recommended) or a local Docker-based installation. 


# Start your Rstudio session on Posit Cloud, or local Docker

## For Posit Cloud

[Login with your GitHub account](https://posit.cloud/login), and then [navigate to your Posit workspace](https://posit.cloud/content/yours?sort=name_asc). Click on New Project, and select "New RStudio Project". This will start RStudio and connect you to it through your browser.

## For local Docker

"Pull" and run the Rocker RStudio container with the following command in your terminal (note: set your own password by replacing "yourpassword"):

```
docker pull rocker/rstudio
docker run --rm -ti -e ROOT=true -e PASSWORD=yourpassword -p 8787:8787 rocker/rstudio
```

*Note for Mac M1/2/3 users: currently the Arm64 version of the Rocker container fails to install devtools; the commands below download and run an amd64-based Rocker that works with this tutorial:*

```
docker pull --platform linux/amd64 rocker/rstudio
docker run --rm -ti --platform linux/amd64 -e ROOT=true -e PASSWORD=yourpassword -p 8787:8787 rocker/rstudio
```

Then, point your browser to http://localhost:8787 and log in (username is rstudio and use the password you provided in the command above)


*Note: don't forget to terminate your Posit Cloud session (click on the "Trash" next to your workspace) or your Docker container (ctrl-C on the terminal) at the end of the tutorial*

# Deploy a ecological FaaSr workflow.


## Clone the FaaSr workshop repo

First let's clone the FaaSr workshop repo - copy and paste this command in the R console:

```
system('git clone https://github.com/dekkov/neon4cast_faasr.git')
```

In RStudio, navigate to the FaaSr_workshop folder, then set it as the working directory (More > Set as Working Directory).



## Source the script that sets up FaaSr and dependences

Run one of the following commands, depending on your setup (Posit, or local Docker). Fair warning: it will take a few minutes to install all dependences:

### For Posit Cloud:

```
source('posit_setup_script')
```

### For local Docker

```
source('rocker_setup_script')
```

### For Rstudio desktop

If you are using Rstudio natively in your desktop, without Docker (*note: you may need to install the sodium library separately for your system*):

```
source('rstudio_setup_script')
```

## Configure Rstudio to use GitHub Token

Within Rstudio, configure the environment to use your GitHub account (replace with your username and email). Input this into the console:

```
usethis::use_git_config(user.name = "YOUR_GITHUB_USERNAME", user.email = "YOUR_GITHUB_EMAIL")
```

Now set your GitHub token as a credential for use with Rstudio - paste your token to the pop-up window that opens with this command pasted into the console:

```
credentials::set_github_pat()
```

## Configure the FaaSr secrets file with your GitHub token

Open the file named faasr_env in the editor. You need to enter your GitHub token here: replace the string "REPLACE_WITH_YOUR_GITHUB_TOKEN" with your GitHub PAT, and save this file. 

The secrets file stores all credentials you use for FaaSr. You will notice that this file has the pre-populated credentials (secret key, access key) to access the Minio "play" bucket.

## Configure the FaaSr JSON workflow

Head over to files tab and open `neon_workflow.json`. This is where we will decide the workflow for our project. Replace YOUR_GITHUB_USERNAME with your actual github username in the username of ComputeServer section. A workflow has been configured for you, shown in the image attached below. For more information, please refer to [this schema](https://github.com/FaaSr/FaaSr-package/blob/main/schema/FaaSr.schema.json).

![image](https://github.com/user-attachments/assets/da1f0143-9387-431c-b466-818ddd943d67)


### Workflow Pipeline
1. getData - Invoke function:
    - Download and process aquatic dataset and upload it to S3
    - This function will act as the starting point for our workflow, invoking both oxygenForecastRandomWalk and temperatureForecastRandomWalk next.
2. The following two functions will run simultaneously:

   a. oxygenForecastRandomWalk
     - Use the filtered dataset to create Oxygen forecast using RandomWalk method and upload it to S3
     - Invoke combined forecast next.
       
    b.temperatureForecastRandomWalk
     - Use the filtered dataset to create Temperature forecast using RandomWalk method and upload it to S3
     - Invoke combined forecast next.
 3. combineForecastRandomWalk:
    - Download the 2 forecasts file from S3 to generate a combined forecast and store it in S3
    - This function doesn't invoke any function after, meaning this is the end of our workflow.



## Register and invoke the simple workflow with GitHub Actions

Now you're ready for some Action! The steps below will:

* Use the faasr function in the FaaSr library to load the neon_workflow.json and faasr_env in a list called neon4cast_tutorial
* Use the register_workflow() function to create a repository called neon4cast_faasr_actions in GitHub, and configure the workflow there using GitHub Actions
* Use the invoke_workflow() function to invoke the execution of your workflow

Enter the following commands to your console:

```
neon4cast_tutorial<- faasr(json_path="neon_workflow.json", env="faasr_env")
neon4cast_tutorial$register_workflow()
```

When prompted, select "public" to create a public repository. Now run the workflow:

```
neon4cast_tutorial$invoke_workflow()
```

## Check if action is successful

Head over to the github repo `neon4cast_faasr_actions` just created by FaaSr, go to actions page to see if your actions has successfully run. 
If the runs are successful, you can explore the Console using https://play.min.io:9443. Log in with the following credentials:
```
Username: Q3AM3UQ867SPQQA43P2F
Password: zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG
```

Look for the neon4cast folder in faasr bucket, you should be able to see the forecasts you have just created.


