#!/usr/bin/env bash
set -euo pipefail

USERNAME="dev-walter"
GROUP="dev-blueteam"
NAMESPACE="dev"

echo "=== 1. Generating User Private Key and CSR ==="
openssl genrsa -out ${USERNAME}.key 2048
openssl req -new -key ${USERNAME}.key -out ${USERNAME}.csr -subj "/CN=${USERNAME}/O=${GROUP}"

echo "=== 2. Submitting CertificateSigningRequest (CSR) to Kubernetes ==="
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USERNAME}-csr
spec:
  request: $(cat ${USERNAME}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

echo "=== 3. Approving CSR as Administrator ==="
kubectl certificate approve ${USERNAME}-csr

echo "=== 4. Exporting Approved Client Certificate ==="
kubectl get csr ${USERNAME}-csr -o jsonpath='{.status.certificate}' | base64 --decode > ${USERNAME}.crt

echo "=== 5. Generating User Kubeconfig File ==="
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].server}')

kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ca.crt

KUBECONFIG_OUT="${USERNAME}.kubeconfig"
kubectl config set-cluster ${CLUSTER_NAME} \
  --server="${CLUSTER_SERVER}" \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --kubeconfig="${KUBECONFIG_OUT}"


kubectl config set-credentials ${USERNAME} \
  --client-certificate=${USERNAME}.crt \
  --client-key=${USERNAME}.key \
  --embed-certs=true \
  --kubeconfig="${KUBECONFIG_OUT}"

kubectl config set-context ${USERNAME}-context \
  --cluster="${CLUSTER_NAME}" \
  --namespace=${NAMESPACE} \
  --user=${USERNAME} \
  --kubeconfig="${KUBECONFIG_OUT}"

kubectl config use-context ${USERNAME}-context --kubeconfig="${KUBECONFIG_OUT}"

echo "=== Success! Generated config: ${KUBECONFIG_OUT} ==="
