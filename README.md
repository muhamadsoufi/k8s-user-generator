# k8s-user-generator
Automatic bash script for creating user for kubernetes cluster
By the following bash script , your able to create your user with answering 5 simple question:
1- What is your username for K8S cluster:
2- Which group this user is included: 
3- What actions your user can do:
4- What resources your user can access:
5- What is your kube-api server ip:
=========================================================================================
After answering the questions this script doese the 8 steps than can make it easy for you:
1- Generate a private key
2- Create a Certificate Signing Request (CSR)
3- Encode the csr with base64 and make CSR yaml
4- Create and apply the yaml
5- Approve the user CSR
6- Export the CRT for this user which was issued by you cluster
7- Make RBAC (ROLE & ROLEBINDING) for user in your desire namespace
8- Make kube config file for access and move to other systems 
