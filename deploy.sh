#!/bin/bash

cd /home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform
/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform init
/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform fmt
/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform apply -auto-approve

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

echo $"[maquina_deploy-infra]" > ../1-ansible/hosts # cria arquivo
echo "$(/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> ../1-ansible/hosts # captura output faz split de espaco e replace de ",

echo "Aguardando criação de maquinas ..."
sleep 20 # 20 segundos

cd ../1-ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key ~/.ssh/id_rsa

cd ../0-terraform
/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform output

echo $"Agora somente abrir a URL: http://$(/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform output | grep public | awk '{print $2;exit}'):8080" | sed -e "s/\",//g"


ID_MAQUINA=$(/home/ubuntu/projetos/treinamento-devops/08-jenkins/deploy-infra-img-java-app/terraform/terraform output | grep id | awk '{print $2;exit}')
echo ${ID_MAQUINA/\",/}



#mandar a chave
#scp -i ~/.ssh/id_rsa ~/.ssh/id_rsa ubuntu@ec2  /home/ubuntu


