#! /usr/bin/env groovy

pipeline {

  agent {
    label 'maven'
  }

  environment {
        USER_CREDENTIALS_OPENTLC = credentials('opentlc-user')
        USER_CREDENTIALS_CRC = credentials('crc-user')
    }

  stages {
    
    stage('Config') {
      steps {
        echo 'Configurations..'

        sh "echo USER_CREDENTIALS_OPENTLC"
        sh "echo $USER_CREDENTIALS_OPENTLC_USR"
        sh "echo $USER_CREDENTIALS_OPENTLC_PSW"

        sh "echo USER_CREDENTIALS_CRC"
        sh "echo $USER_CREDENTIALS_CRC_USR"
        sh "echo $USER_CREDENTIALS_CRC_PSW"

        sh "export OPENTLC=$(echo -n $USER_CREDENTIALS_OPENTLC_USR:$USER_CREDENTIALS_OPENTLC_PSW | base64 -w0)"
        sh "export CRC=$(echo -n $USER_CREDENTIALS_CRC_USR:$USER_CREDENTIALS_CRC_PSW | base64 -w0)"

        sh """
              rm ~/.docker/config.json
              cat << 'EOF' >~/.docker/config.json
              {
                "auths": {
                  "https://default-route-openshift-image-registry.apps-crc.testing": {
                    "auth": "$CRC",
                    "email": "you@example.com"
                  },
                  "https://default-route-openshift-image-registry.apps.cluster-kgzzp.kgzzp.sandbox2948.opentlc.com": {
                    "auth": "$OPENTLC",
                    "email": "you@example.com"
                  }
                }
              }
           """

        /*sh """
              rm ~/.docker/config.json
              cat << 'EOF' >~/.docker/config.json
              {
                "auths": {
                  "https://default-route-openshift-image-registry.apps-crc.testing": {
                    "auth": "a3ViZWFkbWluOnNoYTI1Nn5VSDdWS3JMYUVBWGZUd1pMX250a2k1eGZjbEFfSUlBTmk2SGhlY1FmYVhn",
                    "email": "you@example.com"
                  },
                  "https://default-route-openshift-image-registry.apps.cluster-kgzzp.kgzzp.sandbox2948.opentlc.com": {
                    "auth": "b3BlbnRsYy1tZ3I6c2hhMjU2fnUweUhacmpTNmFoX3d1TV9iaWV2M1NXcENGaXBxQTlmRzNTSWNvRlk3MG8=",
                    "email": "you@example.com"
                  }
                }
              }
           """*/

        sh "cat ~/.docker/config.json"  
      }
    }

    stage('Build') {
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
    stage('Deploy on CRC') {
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
    }
    stage('Promote to opentlc') {
      steps {
        script {
          //usa ~/.docker/config.json gerado no passo de config
          sh """
                oc image mirror --insecure=true default-route-openshift-image-registry.apps-crc.testing/cicd/spring-boot-sample:latest default-route-openshift-image-registry.apps.cluster-kgzzp.kgzzp.sandbox2948.opentlc.com/app-pipeline-hml/spring-boot-sample:latest 
             """
          }
        }
      }
    stage('Deploy opentlc') {
      steps {
        echo 'Deploying on opentlc'
        script {
          openshift.withCluster('homol') {
            openshift.withProject("app-pipeline-hml") {

              def deployment = openshift.selector("dc", "spring-boot-sample")

              echo "deployment: ${deployment}"

              echo "deployment.exists(): ${deployment.exists()}"

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