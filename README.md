# Kubernetes 企業級 RBAC 權限控管與多租戶安全實驗室

本專案實作 Kubernetes 企業級存取控制、自動化憑證簽發，以及基於最小權限原則的多租戶環境隔離。

## 專案核心特色
- 自動化 X.509 客戶端憑證生成，並透過 Kubernetes API 自動審核 CSR。
- 自動封裝獨立的 Kubeconfig 連線設定檔，內嵌叢集 CA 與客戶端身分憑證。
- 使用原生 RBAC（Role 與 RoleBinding）實現命名空間級別的多租戶權限隔離。
- 建立專用的服務帳號（ServiceAccount），嚴格限制自動化機器人僅能更新特定 Deployment。

## 檔案架構說明
- generate-user-kubeconfig.sh: 自動化簽發客戶端憑證與打包 Kubeconfig 的 Shell 腳本。
- dev-rbac.yaml: 限制開發者只能在 dev 命名空間查看資源的 RBAC 角色與綁定設定檔。
- bot-sa.yaml: 自動化機器人專用的 ServiceAccount 與權限設定檔。

## 驗證步驟與結果展示
1. 存取 dev 開發環境（允許通過）
kubectl --kubeconfig=dev-walter.kubeconfig get pods -n dev

2. 跨環境存取 prod 正式環境（嚴格阻擋）
kubectl --kubeconfig=dev-walter.kubeconfig get pods -n prod
回傳結果：Error from server (Forbidden)

3. 驗證服務帳號權限矩陣
kubectl auth can-i patch deployments -n dev --as=system:serviceaccount:dev:deploy-bot-sa
回傳結果：yes

kubectl auth can-i delete deployments -n dev --as=system:serviceaccount:dev:deploy-bot-sa
回傳結果：no
