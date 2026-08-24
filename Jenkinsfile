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

            sed -e "s|{{ ECR_REGISTRY }}|203637463799.dkr.ecr.us-east-1.amazonaws.com|g" \
                -e "s|{{ IMAGE_TAG }}|$IMAGE_TAG|g" \
                frontend/k8s/deployment.yaml | kubectl apply -f -
            kubectl apply -f frontend/k8s/configmap.yaml -f frontend/k8s/service.yaml -f frontend/k8s/ingress.yaml

            sed -e "s|{{ ECR_REGISTRY }}|203637463799.dkr.ecr.us-east-1.amazonaws.com|g" \
                -e "s|{{ IMAGE_TAG }}|$IMAGE_TAG|g" \
                backend/k8s/deployment.yaml | kubectl apply -f -
            kubectl apply -f backend/k8s/configmap.yaml -f backend/k8s/service.yaml

            kubectl rollout status deployment/olfactory-frontend
            kubectl rollout status deployment/olfactory-fragrance-backend
            '''
        }
}
  }
}