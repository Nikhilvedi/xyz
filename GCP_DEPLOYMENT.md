# GCP Cloud Run Deployment Guide

This document explains how to set up Google Cloud Platform (GCP) to deploy this website using Cloud Run via GitHub Actions.

## Prerequisites

- A GCP account with billing enabled
- This GitHub repository with the workflow file (`.github/workflows/deploy.yml`)
- Admin access to this GitHub repository to add secrets

## GCP Console Setup Steps

### Step 1: Create a GCP Project (if you don't have one)

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click **New Project**
4. Enter a project name (e.g., `xyz-site`)
5. Click **Create**
6. Note down the **Project ID** (you'll need this later)

### Step 2: Enable Required APIs

In the GCP Console, enable these APIs:

1. Go to **APIs & Services** > **Library**
2. Search for and enable each of these APIs:
   - **Cloud Run Admin API**
   - **Artifact Registry API**
   - **Cloud Build API**
   - **Secret Manager API** (optional, if you need secrets)

Or use the Cloud Shell:
```bash
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Step 3: Create Artifact Registry Repository

1. Go to **Artifact Registry** in the GCP Console
2. Click **Create Repository**
3. Configure:
   - **Name**: `xyz-site`
   - **Format**: Docker
   - **Mode**: Standard
   - **Location type**: Region
   - **Region**: `europe-west2` (or your preferred region)
4. Click **Create**

Or use Cloud Shell:
```bash
gcloud artifacts repositories create xyz-site \
    --repository-format=docker \
    --location=europe-west2 \
    --description="Docker repository for xyz website"
```

### Step 4: Create a Service Account

1. Go to **IAM & Admin** > **Service Accounts**
2. Click **Create Service Account**
3. Configure:
   - **Name**: `github-actions`
   - **ID**: `github-actions`
   - **Description**: Service account for GitHub Actions deployment
4. Click **Create and Continue**

### Step 5: Grant Service Account Permissions

Add these roles to the service account:

1. **Cloud Run Admin** (`roles/run.admin`)
2. **Artifact Registry Writer** (`roles/artifactregistry.writer`)
3. **Service Account User** (`roles/iam.serviceAccountUser`)
4. **Storage Admin** (`roles/storage.admin`)

In the GCP Console:
1. Go to **IAM & Admin** > **IAM**
2. Find the `github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com` account
3. Click the pencil icon to edit
4. Add each role listed above
5. Click **Save**

Or use Cloud Shell:
```bash
PROJECT_ID=$(gcloud config get-value project)

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
```

### Step 6: Create Service Account Key

1. Go to **IAM & Admin** > **Service Accounts**
2. Click on the `github-actions` service account
3. Go to the **Keys** tab
4. Click **Add Key** > **Create new key**
5. Select **JSON** format
6. Click **Create**
7. Download the JSON file (keep this secure!)

### Step 7: Add GitHub Repository Secrets

In your GitHub repository:

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret**
3. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | Your GCP Project ID (e.g., `xyz-site-123456`) |
| `GCP_SA_KEY` | The entire contents of the JSON key file downloaded in Step 6 |

### Step 8: Deploy!

The deployment will automatically trigger when you:
- Push to the `main` branch
- Manually trigger the workflow from the **Actions** tab

To manually trigger:
1. Go to **Actions** tab in GitHub
2. Select **Deploy to GCP Cloud Run**
3. Click **Run workflow**
4. Select the `main` branch
5. Click **Run workflow**

## Post-Deployment

### View Your Site

After successful deployment, the workflow will output the service URL. You can also find it:

1. Go to **Cloud Run** in GCP Console
2. Click on `xyz-site` service
3. The URL is shown at the top (e.g., `https://xyz-site-xxxxx-uc.a.run.app`)

### Custom Domain (Optional)

To use a custom domain:

1. Go to **Cloud Run** > your service
2. Click **Manage Custom Domains**
3. Click **Add Mapping**
4. Follow the verification steps
5. Update your domain's DNS settings as instructed

### Monitor Costs

Cloud Run has a generous free tier:
- 2 million requests/month free
- 360,000 GB-seconds free compute time
- 180,000 vCPU-seconds free

Check **Billing** in GCP Console to monitor usage.

## Troubleshooting

### Build Failures

1. Check the GitHub Actions logs
2. Verify the Dockerfile builds correctly locally
3. Ensure all required files are not in `.dockerignore`

### Authentication Errors

1. Verify `GCP_SA_KEY` contains the complete JSON key
2. Check service account has required permissions
3. Ensure APIs are enabled

### Deployment Errors

1. Check Cloud Run logs in GCP Console
2. Verify the container starts properly
3. Check the PORT is set to 8080

## Workflow Configuration

The deployment workflow is in `.github/workflows/deploy.yml`. Key settings:

- **Region**: `europe-west2` (change in `REGION` env variable)
- **Service Name**: `xyz-site` (change in `SERVICE_NAME` env variable)
- **Memory**: 256Mi
- **CPU**: 1
- **Max Instances**: 5
