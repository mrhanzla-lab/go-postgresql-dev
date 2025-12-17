pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'go-postgresql-dev-eks'
        DOCKER_IMAGE = 'go-postgresql-app'
        DOCKER_REGISTRY = 'docker.io'
        K8S_NAMESPACE = 'go-postgresql-dev'
        GO_VERSION = '1.21'
        
        // Credentials
        AWS_CREDENTIALS = credentials('aws-credentials')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        DB_PASSWORD = credentials('db-password')
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
    }
    
    stages {
        // Stage 1: Build & Test
        stage('Build & Test') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 1: Build & Test'
                    echo '========================================='
                }
                
                // Setup Go environment
                sh """
                    export PATH=/usr/local/go/bin:\$PATH
                    go version
                    go mod download
                """
                
                // Build application
                sh """
                    echo 'Building Go application...'
                    go build -v -o bin/go-postgresqld ./examples/go-postgresqld/
                """
                
                // Run tests
                sh """
                    echo 'Running unit tests...'
                    go test -v -race -coverprofile=coverage.out ./...
                    go tool cover -func=coverage.out
                """
                
                // Archive artifacts
                archiveArtifacts artifacts: 'bin/**', fingerprint: true
            }
        }
        
        // Stage 2: Security & Linting
        stage('Security & Linting') {
            parallel {
                stage('Go Linting') {
                    steps {
                        script {
                            echo 'Running golangci-lint...'
                            sh """
                                golangci-lint run --timeout=5m ./... || true
                            """
                        }
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        script {
                            echo 'Running gosec security scanner...'
                            sh """
                                gosec -no-fail ./... || true
                            """
                        }
                    }
                }
                
                stage('Vulnerability Scan') {
                    steps {
                        script {
                            echo 'Running Trivy vulnerability scanner...'
                            sh """
                                trivy fs --severity HIGH,CRITICAL . || true
                            """
                        }
                    }
                }
                
                stage('Secret Detection') {
                    steps {
                        script {
                            echo 'Checking for secrets in code...'
                            sh """
                                trufflehog filesystem . --only-verified || true
                            """
                        }
                    }
                }
            }
        }
        
        // Stage 3: Docker Build & Push
        stage('Docker Build & Push') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 3: Docker Build & Push'
                    echo '========================================='
                }
                
                // Build Docker image
                sh """
                    docker build -t ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
                               ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:latest
                """
                
                // Scan Docker image
                sh """
                    echo 'Scanning Docker image for vulnerabilities...'
                    trivy image ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:latest || true
                """
                
                // Push Docker image
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                                  usernameVariable: 'DOCKER_USER', 
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${env.DOCKER_USERNAME}/${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        // Stage 4: Terraform Apply
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 4: Terraform Apply (Infrastructure)'
                    echo '========================================='
                }
                
                dir('infra') {
                    // Configure AWS credentials
                    withCredentials([aws(credentialsId: 'aws-credentials')]) {
                        sh """
                            # Terraform init
                            terraform init -upgrade
                            
                            # Terraform validate
                            terraform validate
                            
                            # Terraform plan
                            terraform plan -out=tfplan -input=false \
                                -var="db_password=${DB_PASSWORD}"
                            
                            # Terraform apply
                            terraform apply -auto-approve -input=false tfplan
                            
                            # Save outputs
                            terraform output -json > terraform-outputs.json
                        """
                    }
                    
                    // Archive Terraform outputs
                    archiveArtifacts artifacts: 'terraform-outputs.json', fingerprint: true
                }
            }
        }
        
        // Stage 5: Kubernetes Deploy
        stage('Kubectl Apply') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 5: Kubectl Apply (Kubernetes Deploy)'
                    echo '========================================='
                }
                
                withCredentials([aws(credentialsId: 'aws-credentials')]) {
                    sh """
                        # Configure kubectl for EKS
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        
                        # Verify cluster connection
                        kubectl cluster-info
                        kubectl get nodes
                        
                        # Create namespace
                        kubectl apply -f k8s/namespace.yaml
                        
                        # Apply ConfigMaps and Secrets
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/secret.yaml
                        
                        # Deploy Redis
                        kubectl apply -f k8s/redis-deployment.yaml
                        kubectl rollout status deployment/redis -n ${K8S_NAMESPACE} --timeout=120s
                        
                        # Deploy RabbitMQ
                        kubectl apply -f k8s/rabbitmq-deployment.yaml
                        kubectl rollout status deployment/rabbitmq -n ${K8S_NAMESPACE} --timeout=120s
                        
                        # Deploy Application
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for application rollout
                        kubectl rollout status deployment/go-postgresql-app -n ${K8S_NAMESPACE} --timeout=300s
                        
                        # Get deployment status
                        echo '=== Pods ==='
                        kubectl get pods -n ${K8S_NAMESPACE}
                        echo ''
                        echo '=== Services ==='
                        kubectl get services -n ${K8S_NAMESPACE}
                        echo ''
                        echo '=== Deployments ==='
                        kubectl get deployments -n ${K8S_NAMESPACE}
                        
                        # Save deployment info
                        kubectl get all -n ${K8S_NAMESPACE} > deployment-status.txt
                    """
                }
                
                // Archive deployment status
                archiveArtifacts artifacts: 'deployment-status.txt', fingerprint: true
            }
        }
        
        // Stage 6: Post-Deploy Smoke Tests
        stage('Post-Deploy Smoke Tests') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 6: Post-Deploy Smoke Tests'
                    echo '========================================='
                }
                
                withCredentials([aws(credentialsId: 'aws-credentials')]) {
                    sh """
                        # Configure kubectl
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        
                        # Test 1: Check all pods are running
                        echo 'Test 1: Checking pod status...'
                        PODS_NOT_RUNNING=\$(kubectl get pods -n ${K8S_NAMESPACE} --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
                        if [ "\$PODS_NOT_RUNNING" -gt 0 ]; then
                            echo '❌ Error: Some pods are not running'
                            kubectl get pods -n ${K8S_NAMESPACE}
                            exit 1
                        fi
                        echo '✅ All pods are running'
                        
                        # Test 2: Check Redis connectivity
                        echo 'Test 2: Testing Redis connectivity...'
                        REDIS_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=redis -o jsonpath='{.items[0].metadata.name}')
                        kubectl exec -n ${K8S_NAMESPACE} \$REDIS_POD -- redis-cli ping | grep -q 'PONG'
                        echo '✅ Redis is responding'
                        
                        # Test 3: Check RabbitMQ connectivity
                        echo 'Test 3: Testing RabbitMQ connectivity...'
                        RABBITMQ_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=rabbitmq -o jsonpath='{.items[0].metadata.name}')
                        kubectl exec -n ${K8S_NAMESPACE} \$RABBITMQ_POD -- rabbitmqctl status > /dev/null
                        echo '✅ RabbitMQ is healthy'
                        
                        # Test 4: Check LoadBalancer service
                        echo 'Test 4: Checking LoadBalancer service...'
                        LB_HOSTNAME=\$(kubectl get service go-postgresql-app -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                        if [ -z "\$LB_HOSTNAME" ]; then
                            echo '❌ LoadBalancer hostname not found'
                            exit 1
                        fi
                        echo "✅ LoadBalancer DNS: \$LB_HOSTNAME"
                        
                        # Test 5: Check environment variables
                        echo 'Test 5: Verifying environment variables...'
                        APP_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=go-postgresql-app -o jsonpath='{.items[0].metadata.name}')
                        kubectl exec -n ${K8S_NAMESPACE} \$APP_POD -- env | grep -q 'DB_HOST' || exit 1
                        kubectl exec -n ${K8S_NAMESPACE} \$APP_POD -- env | grep -q 'REDIS_HOST' || exit 1
                        echo '✅ Environment variables configured correctly'
                        
                        # Test 6: Service DNS resolution
                        echo 'Test 6: Testing internal DNS resolution...'
                        kubectl exec -n ${K8S_NAMESPACE} \$APP_POD -- nslookup redis | grep -q 'Address:'
                        kubectl exec -n ${K8S_NAMESPACE} \$APP_POD -- nslookup rabbitmq | grep -q 'Address:'
                        echo '✅ DNS resolution working'
                        
                        # Generate smoke test report
                        echo '=== Smoke Test Report ===' > smoke-test-report.txt
                        echo "Timestamp: \$(date -u +'%Y-%m-%d %H:%M:%S UTC')" >> smoke-test-report.txt
                        echo '' >> smoke-test-report.txt
                        echo 'Pod Status:' >> smoke-test-report.txt
                        kubectl get pods -n ${K8S_NAMESPACE} >> smoke-test-report.txt
                        echo '' >> smoke-test-report.txt
                        echo 'Service Status:' >> smoke-test-report.txt
                        kubectl get services -n ${K8S_NAMESPACE} >> smoke-test-report.txt
                        
                        echo '========================================='
                        echo '✅ All smoke tests passed!'
                        echo '========================================='
                    """
                }
                
                // Archive smoke test report
                archiveArtifacts artifacts: 'smoke-test-report.txt', fingerprint: true
            }
        }
    }
    
    post {
        always {
            echo '========================================='
            echo 'Pipeline Execution Summary'
            echo '========================================='
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Build Status: ${currentBuild.currentResult}"
            echo "Duration: ${currentBuild.durationString}"
            
            // Clean up workspace
            cleanWs()
        }
        
        success {
            echo '✅ Pipeline completed successfully!'
            
            // Send notification (if configured)
            // emailext(
            //     subject: "✅ Pipeline Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //     body: "The CI/CD pipeline completed successfully.",
            //     to: "${env.NOTIFICATION_EMAIL}"
            // )
        }
        
        failure {
            echo '❌ Pipeline failed!'
            
            // Send notification (if configured)
            // emailext(
            //     subject: "❌ Pipeline Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //     body: "The CI/CD pipeline failed. Please check the logs.",
            //     to: "${env.NOTIFICATION_EMAIL}"
            // )
        }
    }
}
