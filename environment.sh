#!/usr/bin/bash

# 1. EncryptionConfig용 암호화 키 (수정 불필요, 실행 시 자동 생성)
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# 2. 클러스터 노드 IP 리스트 (본인의 노드 IP로 변경하세요)
export NODE_IPS=(172.31.39.151 172.31.32.72)

# 3. 각 IP에 대응하는 호스트명 (본인의 호스트명으로 변경하세요)
export NODE_NAMES=(k8s-01 k8s-02)

# 4. etcd 클러스터 주소 (위에서 설정한 NODE_IPS에 맞춰 수정)
export ETCD_ENDPOINTS="https://172.31.39.151:2379,https://172.31.32.72:2379"

# 5. etcd 노드 간 통신 설정 (호스트명=https://IP:2380 형식)
export ETCD_NODES="k8s-01=https://172.31.39.151:2380,k8s-02=https://172.31.32.72:2380"

# 6. 네트워크 인터페이스 이름 (중요: 본인의 서버에서 'ip addr' 명령어로 확인한 이름)
# 보통 eth0, ens3, enp0s3 등입니다.
export IFACE="eth0"

# 7. 데이터 저장 디렉토리 (기본값 권장, 용량이 충분한 파티션으로 지정)
export ETCD_DATA_DIR="/data/k8s/etcd/data"
export ETCD_WAL_DIR="/data/k8s/etcd/wal"
export K8S_DIR="/data/k8s/k8s"
export CONTAINERD_DIR="/data/k8s/containerd"

# 8. 네트워크 대역 설정 (기존 네트워크와 겹치지 않는다면 그대로 사용 권장)
SERVICE_CIDR="10.254.0.0/16"      # 서비스(Cluster IP) 대역
CLUSTER_CIDR="172.30.0.0/16"      # Pod 대역 (Cilium/Flannel에서 사용)

# 9. 주요 서비스 IP (SERVICE_CIDR 대역 안의 첫 번째, 두 번째 IP 사용)
export CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"
export CLUSTER_DNS_SVC_IP="10.254.0.2"
export CLUSTER_DNS_DOMAIN="cluster.local"

# 10. 경로 설정
export PATH=/opt/k8s/bin:$PATH