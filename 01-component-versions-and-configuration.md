# 01.Kubernetes 클러스터 구성 가이드

## 주요 컴포넌트 버전

| 컴포넌트 | 버전 | 릴리스 날짜 |
| ---------------------- | ------- | ------------ |
| kubernetes             | v1.33.3 | 2020-01-22   |
| etcd                   | 3.6.2   | 2019-10-24   |
| containerd             | 2.1.3   | 2020-02-07   |
| runc                   | v1.3.0  | 2019-12-23   |
| cilium                 | 1.17.6  | 2020-01-27   |
| coredns                | 1.9.4   | 2019-12-20   |
| dashboard              | 1.5.0   | 2020-02-06   |
| k8s-prometheus-adapter | v0.12.0 | 2019-04-03   |
| prometheus-operator    | v0.76.2 | 2020-01-13   |
| prometheus             | v2.54.1 | 2020-01-06   |
| grafana                | 11.2.0  |              |
| nginx                  | 1.29.0  |              |
| nerdctl                | v2.1.3  |              |
| elasticsearch          | 8.5.1   |              |
| crictl                 | 1.33.0  |              |

---

## 중요 참고사항

### 1. Debian 12 배포 권장

배포 중 환경 문제로 인한 운영 실패를 줄이기 위해 Debian 12 운영체제를 사용하는 것을 권장합니다.
또한 모든 노드가 정상적으로 외부 네트워크에 접근할 수 있어야 합니다.

### 2. 노드 간 네트워크 연결 보장

Kubernetes 클러스터의 각 노드는 네트워크 연결이 보장되어야 합니다. 클라우드 서버를 사용하는 경우, 동일 계정 및 동일 VPC 내의 노드들은 기본적으로 내부 네트워크로 연결됩니다. 그렇지 않은 경우 직접 노드 간 네트워크 연결을 구성해야 합니다 (예: 공용 네트워크 접근, 단 네트워크 비용이 발생할 수 있음).

더 큰 네트워크 대역폭 확보를 위해서 내부 네트워크 통신을 권장합니다. 그렇지 않으면 높은 네트워크 지연으로 인해 네트워크 지터나 배포 실패가 발생할 수 있습니다 (예: Etcd 배포 실패).

---

## Kubernetes 노드 구성 요구사항

클러스터 구성에 사용한 노드 스펙:

| 노드 유형 | 최소 구성 |
|---|---|
| 마스터 노드 | 2C4G, 디스크 공간 50G |
| 워커 노드 | 1C2G, 디스크 공간 50G |

---

## 주요 구성 전략

### kube-apiserver:

- 노드 로컬 nginx Layer 4 프록시로 고가용성 구성
- 비보안 포트(8080) 및 익명 접근 비활성화
- 보안 포트 6443에서 https 수신
- x509, Token, RBAC 기반 인증/인가
- kubelet TLS bootstrapping을 위한 bootstrap token 인증 활성화
- kubelet, etcd 통신 시 https 암호화

### kube-controller-manager:

- 2노드 고가용성 구성 (프로덕션에서는 3노드 권장, 비용 절감을 위해 2노드로 구성)
- 비보안 포트 비활성화, 보안 포트 10252에서 https 수신
- kubeconfig로 apiserver 보안 포트 접근
- kubelet CSR 자동 승인, 인증서 자동 갱신
- 컨트롤러별 ServiceAccount 분리

### kube-scheduler:

- 2노드 고가용성 구성
- kubeconfig로 apiserver 보안 포트 접근

### kubelet:

- apiserver의 정적 구성 대신 kubeadm을 사용하여 부트스트랩 토큰 동적 생성
- TLS 부트스트랩 메커니즘을 사용하여 클라이언트 및 서버 인증서 자동 생성, 만료 후 자동 갱신
- KubeletConfiguration 타입 JSON 파일에서 주요 파라미터 구성
- 읽기 전용 포트 비활성화, 보안 포트 10250에서 https 요청 수신, 요청 인증 및 인가, 익명 및 미인가 접근 거부
- kubeconfig를 사용하여 apiserver 보안 포트 접근

### kube-proxy:

- kubeconfig로 apiserver 보안 포트 접근
- KubeProxyConfiguration JSON 파일로 설정 관리
- ipvs 프록시 모드 사용

---

## 클러스터 애드온

| 애드온 | 구성 |
|--------|------|
| DNS | CoreDNS |
| Dashboard | 로그인 인증 적용 |
| Metric | metrics-server (kubelet https 연동) |
| Log | Elasticsearch + Fluentd + Kibana |
| Registry | Harbor |