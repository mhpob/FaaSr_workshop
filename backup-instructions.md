# Backup Instructions (When Minio is Down)

## Overview
These instructions should be followed **only** if you encounter issues accessing the Minio server during the workshop. The workshop facilitators will inform you if this is necessary.

## Using AWS S3 Storage Instead of Minio

If the Minio service is unavailable, we have prepared an alternative workflow using AWS S3. Follow these steps to configure and run your workflow with AWS S3 instead.

### 1. Use the Provided AWS Credentials File

1. Download the `faasr_env_aws.zip` file provided by the workshop facilitators
2. Unzip the file to extract the file `faasr_env_aws`
3. The password required for the extraction will be provided by the workshop facilitators on the screen
4. Copy this file to your working directory

This file already contains the necessary AWS credentials:
```
My_AWS_Bucket_ACCESS_KEY=XXXXXXXXXXXX
My_AWS_Bucket_SECRET_KEY=XXXXXXXXXXXX
```

### 2. Use the AWS Workflow JSON File

Instead of using `neon_workflow.json`, we will use the `neon_workflow_aws.json` file that's configured for AWS S3:

1. Open the `neon_workflow_aws.json` file
2. Just like in the original instructions, replace `YOUR_GITHUB_USERNAME` with your GitHub username
3. Update the `folder` parameter in all four functions by replacing `yourname` with your actual name (e.g., change `FaaSr_workshop_yourname` to `FaaSr_workshop_jane`)
4. Save the file

### 3. Register and Invoke the AWS Workflow

Use the following commands to register and invoke your workflow using AWS S3:

```r
# Load the AWS workflow configuration
faasr_workshop_aws <- faasr(json_path="neon_workflow_aws.json", env="faasr_env_aws")

# Register the workflow on GitHub
faasr_workshop_aws$register_workflow()
```

When prompted, select "public" to create a public repository.

Then, invoke the workflow:

```r
faasr_workshop_aws$invoke_workflow()
```

### 4. Verify Your Results

Once your workflow has completed successfully:

1. Navigate to your GitHub repository `FaaSr_workshop_actions`
2. Check the "Actions" tab to confirm successful execution

The screenshot below shows how a successful workflow execution should appear:

![Screenshot from 2025-04-23 13-39-28](https://github.com/user-attachments/assets/75c645ef-ab49-46b7-b96a-80e541d697a2)
