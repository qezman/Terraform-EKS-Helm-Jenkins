pipeline {
  agent any
  environment {
    AWS_REGION      = 'us-east-1'
    FRONTEND_REPO   = '203637463799.dkr.ecr.us-east-1.amazonaws.com/eks-project-frontend'
    BACKEND_REPO    = '203637463799.dkr.ecr.us-east-1.amazonaws.com/eks-project-backend'
    IMAGE_TAG       = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Checkout App Repos') {
      steps {
        dir('frontend') {
          git branch: 'main', url: 'https://github.com/qezman/olfactory-fragrance'
        }
        dir('backend') {
          git branch: 'main', url: 'https://github.com/qezman/olfactory-fragrance-backend'
        }
      }
    }

    stage('ECR Login') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | \
            docker login --username AWS --password-stdin 203637463799.dkr.ecr.us-east-1.amazonaws.com
        '''
      }
    }

    stage('Build & Push Frontend') {
      steps {
        sh '''
          docker build -t $FRONTEND_REPO:$IMAGE_TAG ./frontend
          docker push $FRONTEND_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Build & Push Backend') {
      steps {
        sh '''
          docker build -t $BACKEND_REPO:$IMAGE_TAG ./backend
          docker push $BACKEND_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy') {
      steps {
        sh '''
          aws eks update-kubeconfig --name eks-project-eks --region $AWS_REGION
          kubectl set image deployment/frontend frontend=$FRONTEND_REPO:$IMAGE_TAG
          kubectl set image deployment/backend backend=$BACKEND_REPO:$IMAGE_TAG
          kubectl rollout status deployment/frontend
          kubectl rollout status deployment/backend
        '''
      }
    }
  }
}