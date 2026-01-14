# 11 | Addons 배포 (2): Prometheus 배포

`kube-prometheus`는 Prometheus를 사용하여 클러스터 지표를 수집하고 Grafana로 시각화하는 전체 모니터링 솔루션입니다. 다음 컴포넌트를 포함합니다

* The Prometheus Operator
* Highly available Prometheus
* Highly available Alertmanager
* Prometheus node-exporter
* Prometheus Adapter for Kubernetes Metrics APIs (k8s-prometheus-adapter)
* kube-state-metrics
* Grafana

그중 `k8s-prometheus-adapter`는 Prometheus를 사용하여 `metrics.k8s.io` 및 `custom.metrics.k8s.io` API를 구현했으므로, 별도로 `metrics-server`를 배포할 필요가 없습니다. 

**참고:** 특별한 언급이 없다면 모든 작업은 `k8s-01` 노드에서 수행합니다.

Metrics 컴포넌트를 설치하기 전에는 `kubectl top pods` 명령을 사용해도 모니터링 데이터를 확인할 수 없습니다. 설치 후에는 `kubectl top pods`를 사용하여 Pod의 성능 지표를 확인할 수 있습니다.

**Metrics 설치 전**

```bash
$ kubectl top pods
error: Metrics API not available
```

## Prometheus 다운로드 및 설치

```bash
cd /opt/k8s/work
git clone -b v0.14.0 https://github.com/coreos/kube-prometheus.git
cd kube-prometheus/
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
```

## 실행 상태 확인

```bash
$ kubectl -n monitoring get pods
NAME                                   READY   STATUS    RESTARTS   AGE
alertmanager-main-0                    1/2     Running   0          26s
alertmanager-main-1                    1/2     Running   0          26s
alertmanager-main-2                    2/2     Running   0          26s
blackbox-exporter-7bc87966c-nbxdb      3/3     Running   0          44s
grafana-59f4f468db-55h6j               1/1     Running   0          42s
kube-state-metrics-66f74d7f8c-8mxs2    3/3     Running   0          42s
node-exporter-b6lhk                    2/2     Running   0          41s
node-exporter-c67pb                    2/2     Running   0          41s
prometheus-adapter-599c88b6c4-mrl9b    1/1     Running   0          40s
prometheus-adapter-599c88b6c4-ngrfd    1/1     Running   0          40s
prometheus-k8s-0                       1/2     Running   0          25s
prometheus-k8s-1                       1/2     Running   0          25s
prometheus-operator-7d545fcffc-vcqh7   2/2     Running   0          40s
```

`kubectl top` 명령이 Pod의 실행 지표를 가져올 수 있는지 테스트합니다

```bash
NAME                                   CPU(cores)   MEMORY(bytes)
alertmanager-main-0                    3m           30Mi
alertmanager-main-1                    1m           31Mi
alertmanager-main-2                    2m           30Mi
blackbox-exporter-7bc87966c-nbxdb      0m           29Mi
grafana-59f4f468db-55h6j               6m           93Mi
kube-state-metrics-66f74d7f8c-8mxs2    0m           51Mi
node-exporter-b6lhk                    4m           33Mi
node-exporter-c67pb                    5m           28Mi
prometheus-adapter-599c88b6c4-mrl9b    2m           26Mi
prometheus-adapter-599c88b6c4-ngrfd    4m           38Mi
prometheus-k8s-0                       20m          271Mi
prometheus-k8s-1                       17m          261Mi
prometheus-operator-7d545fcffc-vcqh7   0m           42Mi
```

## Prometheus UI 접속

서비스 프록시 시작

* `port-forward`는 `socat`에 의존합니다.

```bash
$ kubectl port-forward --address 0.0.0.0 pod/prometheus-k8s-0 -n monitoring 9090:9090
Forwarding from 0.0.0.0:9090 -> 9090
```

브라우저로 `http://public-ip:9090/`에 접속합니다. 접속 화면은 다음과 같습니다

<img width="2295" height="497" alt="image" src="https://github.com/user-attachments/assets/df2bc178-7702-4d57-824c-a2a1871ac98a" />



## Grafana UI 접속

프록시 시작

```bash
$ kubectl port-forward --address 0.0.0.0 svc/grafana -n monitoring 3000:3000 
Forwarding from 0.0.0.0:3000 -> 3000
```

브라우저로 `http://public-ip:3000/`에 접속합니다. 접속 화면은 다음과 같습니다.

<img width="526" height="537" alt="image" src="https://github.com/user-attachments/assets/ab54b36e-4c59-4409-9816-f5ccc920befa" />



`admin/admin`으로 로그인합니다. 로그인 후 다양한 사전 정의된 대시보드를 볼 수 있으며 화면은 다음과 같습니다.

<img width="2253" height="1070" alt="image" src="https://github.com/user-attachments/assets/18a4919d-510e-4da3-9f9c-6698cbb933dc" />

