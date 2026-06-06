# Jenkins CI/CD

Jenkins is provisioned automatically on an EC2 t3.micro instance via Terraform (`terraform/modules/ec2/`).

## Pipelines

| Pipeline | Repository | Triggers |
|---|---|---|
| olfactory-backend | https://github.com/qezman/olfactory-fragrance-backend | Manual / Webhook |
| olfactory-frontend | https://github.com/qezman/olfactory-fragrance | Manual / Webhook |

## Pipeline Stages

### Backend
1. Checkout - pulls latest code from GitHub
2. Lint & Type Check - `npm ci`, `prisma generate`, `tsc --noEmit`
3. Test - `vitest run`
4. Docker Build - multi-stage build tagged with build number
5. Push to ECR - authenticates via EC2 IAM role, pushes image
6. Deploy to EKS - `helm upgrade --install` to `olfactory` namespace

### Frontend
1. Checkout - pulls latest code from GitHub
2. Docker Build - multi-stage build with `NEXT_PUBLIC_API_URL` baked in
3. Push to ECR - authenticates via EC2 IAM role, pushes image
4. Deploy to EKS - `helm upgrade --install` to `olfactory` namespace

## Jenkins Credentials Required

| ID | Type | Purpose |
|---|---|---|
| DATABASE_URL | Secret text | Supabase PostgreSQL connection string |

## Pre-requisites After EC2 Recreation
Jenkins configuration does not persist after EC2 destroy/recreate. After reprovisioning:
1. Add `DATABASE_URL` credential
2. Recreate both pipeline jobs pointing to respective GitHub repos
3. Grant Jenkins EC2 IAM role access to EKS cluster