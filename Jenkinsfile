#! /usr/bin/env groovy

pipeline {

  agent {
    label 'maven'
  }

  stages {
    
    stage('Config') {
      
      //Aternativamente ao withDockerRegistry
      environment {
        USER_CREDENTIALS_OPENTLC = credentials('opentlc-user')
        USER_CREDENTIALS_CRC = credentials('crc-user')
        OPENTLC= sh (returnStdout: true, script: "echo -n '$USER_CREDENTIALS_OPENTLC_USR:$USER_CREDENTIALS_OPENTLC_PSW' | base64 -w0").trim()
        CRC= sh (returnStdout: true, script: "echo -n '$USER_CREDENTIALS_CRC_USR:$USER_CREDENTIALS_CRC_PSW' | base64 -w0").trim()
      }

      steps {
        echo 'Configurations..'
        
        sh """
              mkdir -p ~/.docker
              cat << 'EOF' >~/.docker/config.json
              {
                "auths": {
                  "https://$REGISTRY_CRC": {
                    "auth": "$CRC",
                    "email": "you@example.com"
                  },
                  "https://$REGISTRY_OPENTLC": {
                    "auth": "$OPENTLC",
                    "email": "you@example.com"
                  }
                }
              }
           """

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
            openshift.withProject("redhat-ssa") {
                def buildConfigExists = openshift.selector("bc", "spring-boot-sample").exists()

                if(!buildConfigExists){
                    openshift.newBuild("--name=spring-boot-sample", "--docker-image=registry.access.redhat.com/ubi8/openjdk-11:1.14-12", "--binary")
                }

                openshift.selector("bc", "spring-boot-sample").startBuild("--from-file=target/spring-boot-sample-0.0.1-SNAPSHOT.jar", "--follow")

                openshift.tag("redhat-ssa/spring-boot-sample:latest", "app-pipeline-dev/spring-boot-sample:latest")

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
            openshift.withProject("redhat-ssa") {

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
        //withDockerRegistry([credentialsId: "crc-user", url: "$REGISTRY_CRC"]) {
            ///withDockerRegistry([credentialsId: "opentlc-user", url: "$REGISTRY_OPENTLC"]) {
              script {
               //usa ~/.docker/config.json gerado no passo de config
               
               /*
                 Documentação
                 https://access.redhat.com/solutions/5686371
                 https://github.com/jenkinsci/openshift-client-plugin/blob/master/README.md#configuring-an-openshift-cluster
               */
               sh """
                     oc image mirror --insecure=true $REGISTRY_CRC/redhat-ssa/spring-boot-sample:latest $REGISTRY_OPENTLC/app-pipeline-hml/spring-boot-sample:latest 
                  """
              }
            }
          //}
        //}
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

              /*timeout(5) { 
                openshift.selector("dc", "spring-boot-sample").related('pods').untilEach(1) {
                  return (it.object().status.phase == "Running")
                  }
                }*/

            }

          }
        }
      }
    }
  }
}