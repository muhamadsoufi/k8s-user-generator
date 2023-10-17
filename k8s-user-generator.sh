#!/bin/bash

read -p 'What is your username for K8S cluster: ' userk8s
read -p 'Which group this user is included: ' groupk8s
read -p "What actions do you need that $userk8s can does(for example get,list,watch)(syntax attention):" userverb
read -p "what resource do you need to manage by $userk8s(for example pods,deployments,secrets)(syntax attention):" userobject
read -p "Type IP Adress or FQDN of your kube-api server and port:(for example master:6443) " userip

# 1-Generate a private key
openssl genpkey -algorithm RSA -out $userk8s.key


# 2-Create a Certificate Signing Request (CSR)
openssl req -new -key $userk8s.key -out $userk8s.csr -subj "/CN=$userk8s/O=$groupk8s"


# 3-encode the csr with base64 and make CSR yaml
user_code=$(cat "$userk8s.csr" | base64 | tr -d '\n')

cat <<EOF > "$userk8s-csr.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $userk8s
spec:
  groups:
  - system:authenticated
  request: $(echo "$user_code" | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
#  expirationSeconds: 315569260
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF


# 4- create and apply the yaml
kubectl create -f $userk8s-csr.yaml


# 5- approve the user CSR
kubectl certificate approve $userk8s


# 6- export the CRT for this user which was issued by you cluster
kubectl get csr $userk8s -o jsonpath='{.status.certificate}' | base64 -d > $userk8s.crt


# 7- make RBAC (ROLE & ROLEBINDING) for user in your desire namespace
kubectl create clusterrole $userk8s --verb=$userverb --resource=$userobject
kubectl create clusterrolebinding $userk8s --clusterrole=$userk8s --user=$userk8s



kubectl --kubeconfig ~/.kube/config-$userk8s config set-cluster kubernetes --insecure-skip-tls-verify=true --server=https://$userip
kubectl --kubeconfig ~/.kube/config-$userk8s config set-credentials $userk8s --client-certificate=$userk8s.crt --client-key=$userk8s.key #--embed-certs=true
kubectl --kubeconfig ~/.kube/config-$userk8s config set-context $userk8s-context --cluster=kubernetes --user=$userk8s
kubectl --kubeconfig ~/.kube/config-$userk8s config use-context $userk8s-context


#by Mohammad Hosein Soufi Ghorbani
#example of query the cluster with specific kube config --> kubectl --kubeconfig ~/.kube/config-<your user> get pod -A
#use ~/.kube/config-<your-user> & crt,key,csr in your system for access your cluster

















