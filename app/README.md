# Application Repositories

The application code lives in separate repositories following a polyrepo structure.

## Frontend - Next.js

- **Repo**: https://github.com/qezman/olfactory-fragrance
- **Stack**: Next.js 14 (App Router), TypeScript, Tailwind CSS
- **Containerized**: Yes - multi-stage Dockerfile, deployed to EKS
- **Helm Chart**: `helm/olfactory-frontend/`
- **CI/CD**: Jenkins pipeline (`Jenkinsfile` in repo root)

## Backend - Node.js/Express

- **Repo**: https://github.com/qezman/olfactory-fragrance-backend
- **Stack**: Node.js, Express, TypeScript, Prisma ORM, PostgreSQL
- **Containerized**: Yes - multi-stage Dockerfile, deployed to EKS
- **Helm Chart**: `helm/olfactory-fragrance-backend/`
- **CI/CD**: Jenkins pipeline (`Jenkinsfile` in repo root)
