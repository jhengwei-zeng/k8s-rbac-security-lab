# Kubernetes Enterprise RBAC and Security Lab

This project demonstrates Kubernetes enterprise-level access control, automated certificate signing, and multi-tenancy isolation based on the Principle of Least Privilege.

## Features
- Automated X.509 client certificate generation and CSR approval via Kubernetes API.
- Standalone kubeconfig assembly with embedded CA and client credentials.
- Multi-tenancy namespace isolation using native RBAC (Role and RoleBinding).
- ServiceAccount management restricting automated bots to dedicated deployment operations.

## Project Structure
- generate-user-kubeconfig.sh: Shell script for automating certificate issuance and kubeconfig packaging.
- dev-rbac.yaml: Role and RoleBinding manifests for developer access control in the dev namespace.
- bot-sa.yaml: ServiceAccount and RBAC definitions for automated workloads.

## Verification
1. Access dev namespace (Allowed)
kubectl --kubeconfig=dev-walter.kubeconfig get pods -n dev

2. Access prod namespace (Strictly Forbidden)
kubectl --kubeconfig=dev-walter.kubeconfig get pods -n prod

3. Verify ServiceAccount permission matrix
kubectl auth can-i patch deployments -n dev --as=system:serviceaccount:dev:deploy-bot-sa
kubectl auth can-i delete deployments -n dev --as=system:serviceaccount:dev:deploy-bot-sa
