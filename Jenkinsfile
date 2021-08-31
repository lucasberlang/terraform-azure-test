
pipeline {
  agent {
      label "terraform-exec"
  }
	stages {
		stage('checkout') {
			steps {
				container('terraform') {
					echo "La rama de la que se va a hacer el checkout es: master"
					git branch: "master", credentialsId: 'GitLab', url: 'git@gitlab.bluetab.net:lucas.calvo/terraform-azure-test.git'
				}
			}
		}
 		stage('Review Terraform version') {
 			steps {
				container('terraform') {
 					sh 'terraform --version'
				}
 			}
 		}
 		stage('Terraform init') {
 			steps {
				container('terraform') {
 					withCredentials([sshUserPrivateKey(credentialsId: 'GitLab', keyFileVariable: 'GIT_SSH')]) {
					sh 'ssh-agent'
 					sh 'mkdir ~/.ssh && ssh-keyscan -H gitlab.bluetab.net >> ~/.ssh/known_hosts && eval $(ssh-agent) && ssh-add ${GIT_SSH} && ssh-add -l && terraform init -upgrade'
					}
				}
			}
 		}
		stage('Terraform plan infrastructure') {
 			steps {
				container('terraform') {
					withCredentials([string(credentialsId: 'vaultUrl', variable: 'VAULT_ADDR'),
					string(credentialsId: 'vaultToken', variable: 'VAULT_TOKEN')
					]) {
 					sh 'export VAULT_ADDR=${VAULT_ADDR} && export VAULT_TOKEN=${VAULT_TOKEN} && terraform plan'
					slackSend channel: "#caixabank",color: '#BADA55', message: "Plan completed! Do you approve deployment? ${env.RUN_DISPLAY_URL}"
					}
				}
			}
		}
		stage('Approval') {
			when{
				not {
					branch 'poc'
				}
			}
			steps {
				container('terraform') {
					script {
					def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
					}
				}
			}
		}
		stage('Terraform Apply') {
 			steps {
				container('terraform') {
					withCredentials([string(credentialsId: 'vaultUrl', variable: 'VAULT_ADDR'),
					string(credentialsId: 'vaultToken', variable: 'VAULT_TOKEN')
					]) {
 					sh 'export VAULT_ADDR=${VAULT_ADDR} && export VAULT_TOKEN=${VAULT_TOKEN} && terraform apply -auto-approve'
					slackSend color: '#BADA55', message: "Apply completed! Build logs from jenkins server ${env.RUN_DISPLAY_URL}"
					}
				}
 			}
		}
		stage('Waiting to review the infrastructure') {
 			steps {
				container('terraform') {
					slackSend channel: "#caixabank", color: '#BADA55', message: "Waiting 5 minutes before destroy the infrastructure!"
					sh 'sleep 300'
				}
			}
 			
		}
		stage('Destroy Infra') {
 			steps {
				container('terraform') {
					withCredentials([string(credentialsId: 'vaultUrl', variable: 'VAULT_ADDR'),
					string(credentialsId: 'vaultToken', variable: 'VAULT_TOKEN')
					]) {
 					sh 'export VAULT_ADDR=${VAULT_ADDR} && export VAULT_TOKEN=${VAULT_TOKEN} && terraform destroy -auto-approve'
					slackSend channel: "#caixabank", color: '#BADA55', message: "Destroy completed! Build logs from jenkins server ${env.RUN_DISPLAY_URL}"
					}
				}
 			}
		}
	}
}

