#! /usr/bin/env groovy

pipeline {

  agent {
    label 'maven'
  }

  stages {
    /*stage('Build') {
      steps {
        echo 'Building..'

        sh 'mvn clean package'
        
      }
    }
    stage('Create Container Image') {
      steps {
        echo 'Create Container Image..'
        
        script {
          openshift.withCluster() {
            openshift.withProject("cicd") {
                def buildConfigExists = openshift.selector("bc", "spring-boot-sample").exists()

                if(!buildConfigExists){
                    openshift.newBuild("--name=spring-boot-sample", "--docker-image=registry.access.redhat.com/ubi8/openjdk-11:1.14-12", "--binary")
                }

                openshift.selector("bc", "spring-boot-sample").startBuild("--from-file=target/spring-boot-sample-0.0.1-SNAPSHOT.jar", "--follow")

                openshift.tag("cicd/spring-boot-sample:latest", "app-pipeline-dev/spring-boot-sample:latest")

            }

          }
        }
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying....'
        script {
          openshift.withCluster() {
            openshift.withProject("app-pipeline-dev") {

              def deployment = openshift.selector("dc", "spring-boot-sample")

              if(!deployment.exists()){
                openshift.newApp('spring-boot-sample', "--as-deployment-config").narrow('svc').expose()
              }

              timeout(5) { 
                openshift.selector("dc", "spring-boot-sample").related('pods').untilEach(1) {
                  return (it.object().status.phase == "Running")
                  }
                }

            }

          }
        }
      }
    }*/
    stage('Deploy opentlc') {
      steps {
        echo 'Deploying....'
        script {
          openshift.withCluster('homol', 'opentlc-token' ) {
            openshift.withProject("app-pipeline-hml") {

              def deployment = openshift.selector("dc", "spring-boot-sample")

              if(!deployment.exists()){
                openshift.newApp('spring-boot-sample', "--as-deployment-config").narrow('svc').expose()
              }

              timeout(5) { 
                openshift.selector("dc", "spring-boot-sample").related('pods').untilEach(1) {
                  return (it.object().status.phase == "Running")
                  }
                }

            }

          }
        }
      }
    }
  }
}