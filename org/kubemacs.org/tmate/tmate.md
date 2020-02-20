- [from docker to kubemacs in-cluster](#sec-1)
  - [Environment for docker-init](#sec-1-1)
  - [Running Docker](#sec-1-2)
- [tilt up](#sec-2)
- [ingress](#sec-3)
  - [apply](#sec-3-1)
  - [config](#sec-3-2)
  - [results](#sec-3-3)
- [Modify Tilt / kustomize](#sec-4)
- [exploring the tmate deployment](#sec-5)
- [Services](#sec-6)
  - [list](#sec-6-1)
  - [master](#sec-6-2)
  - [session](#sec-6-3)
- [Ingress](#sec-7)
  - [list](#sec-7-1)
  - [tmate-session-ingress](#sec-7-2)
  - [tmate-master-ingress](#sec-7-3)
- [Setting long node name](#sec-8)
  - [Issue](#sec-8-1)
  - [erlang args](#sec-8-2)
  - [session env from status.podIP](#sec-8-3)
- [mix command](#sec-9)
- [getting logs](#sec-10)
  - [full logs](#sec-10-1)
- [kubectl get all](#sec-11)


# from docker to kubemacs in-cluster<a id="sec-1"></a>

## Environment for docker-init<a id="sec-1-1"></a>

```shell
# Pin your image
KUBEMACS_IMAGE=kubemacs/kubemacs:2020.02.19
# $(id -u) / mainly for ~/.kube/config
HOST_UID="1001"
# Vars for git commits
KUBEMACS_GIT_EMAIL=hh@ii.coop
KUBEMACS_GIT_NAME="Hippie Hacker"
KUBEMACS_TIMEZONE=Pacific/Auckland
# This is the kind cluster name, maybe we should rename
# for some reason we can't used kind as the name
KUBEMACS_KIND_NAME=tmate.kubemacs
# ~/.kube/$KUBEMACS_HOSTCONFIG_NAME
KUBEMACS_HOST_KUBECONFIG_NAME=config
# Using a docker registry alongside kind
KIND_LOCAL_REGISTRY_ENABLE=true
KIND_LOCAL_REGISTRY_NAME=kind-registry
KIND_LOCAL_REGISTRY_PORT=5000
# Where you want the repos checked out
KUBEMACS_INIT_DEFAULT_REPOS_FOLDER=Projects
# The repositories to check out
KUBEMACS_INIT_DEFAULT_REPOS='https://github.com/ii/kubemacs https://github.com/tmate-io/tmate-ssh-server.git https://github.com/tmate-io/tmate-websocket.git https://github.com/tmate-io/tmate-master.git https://github.com/ii/tmate-kube.git'
# The folder to start tmate in
KUBEMACS_INIT_DEFAULT_DIR=Projects/kubemacs/org/kubemacs.org
# The first file you want emacs to open
KUBEMACS_INIT_ORG_FILE=Projects/kubemacs/org/kubemacs.org/tmate/tmate.org
# If you want to see lots of information
KUBEMACS_INIT_DEBUG=true
```

## Running Docker<a id="sec-1-2"></a>

```shell
. kubemacs-tmate.env
docker run \
       --env-file kubemacs-tmate.env \
       --name kubemacs-docker-init \
       --user root \
       --privileged \
       --network host \
       --rm \
       -it \
       -v "$HOME/.kube:/tmp/.kube" \
       -v /var/run/docker.sock:/var/run/docker.sock \
       $KUBEMACS_IMAGE \
       docker-init.sh
```

# tilt up<a id="sec-2"></a>

```tmate
tilt up --host 0.0.0.0
```

# ingress<a id="sec-3"></a>

## apply<a id="sec-3-1"></a>

```shell
kubectl apply -f - <<EOF
<<tcp-services>>
EOF
```

```shell
kubectl get -n ingress-nginx configmap/tcp-services -o json | jq .data
```

## config<a id="sec-3-2"></a>

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  2200: "default/session:2200"
  # 5432: "ii/postgres:5432"
  10350: "default/kubemacs-tilt:10350"
```

## results<a id="sec-3-3"></a>

    configmap/tcp-services configured

```json
{
  "10350": "default/kubemacs-tilt:10350",
  "2200": "default/session:2200"
}
```

# Modify Tilt / kustomize<a id="sec-4"></a>

<./Tiltfile> <../../../../tmate-kube/dev/master.yaml> <../../../../tmate-websocket/Dockerfile.dev> <../../../../tmate-websocket/>

# exploring the tmate deployment<a id="sec-5"></a>

```shell
lsof -i -n -P 2>&1
:
```

    COMMAND   PID USER   FD   TYPE     DEVICE SIZE/OFF NODE NAME
    tmate     363   ii    9u  IPv4 2767323800      0t0  TCP 10.244.1.2:47214->157.230.72.130:22 (ESTABLISHED)
    tmate     619   ii   10u  IPv4 2767464814      0t0  TCP 10.244.1.2:58144->157.230.72.130:22 (ESTABLISHED)
    tilt    35885   ii    3u  IPv4 2768377566      0t0  TCP 10.244.1.2:36658->10.96.0.1:443 (ESTABLISHED)
    tilt    35885   ii   16u  IPv6 2768414883      0t0  TCP *:10350 (LISTEN)
    tilt    35885   ii   30u  IPv6 2768376574      0t0  TCP 10.244.1.2:10350->10.244.0.5:54244 (ESTABLISHED)
    tilt    35885   ii   31u  IPv6 2768421282      0t0  TCP 10.244.1.2:10350->10.244.0.5:54412 (ESTABLISHED)
    tilt    35885   ii   32u  IPv6 2768398980      0t0  TCP 10.244.1.2:10350->10.244.0.5:54414 (ESTABLISHED)

# Services<a id="sec-6"></a>

## list<a id="sec-6-1"></a>

```shell
kubectl get services
```

    NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
    kubemacs-tilt   ClusterIP   10.96.218.169   <none>        10350/TCP           4h30m
    master          ClusterIP   10.96.103.73    <none>        4000/TCP,9100/TCP   3h57m
    postgres        ClusterIP   10.96.194.125   <none>        5432/TCP            3h57m
    session         ClusterIP   10.96.200.241   <none>        2200/TCP,4001/TCP   3h57m

## master<a id="sec-6-2"></a>

```shell
kubectl get service/master -o yaml | grep -A40 spec:
```

```yaml
spec:
  clusterIP: 10.96.103.73
  ports:
  - name: http
    port: 4000
    protocol: TCP
    targetPort: 4000
  - name: metrics
    port: 9100
    protocol: TCP
    targetPort: 9100
  selector:
    app: master
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

## session<a id="sec-6-3"></a>

```shell
kubectl get service/session -o yaml | grep -A40 spec:
```

```yaml
spec:
  clusterIP: 10.96.200.241
  ports:
  - name: ssh
    port: 2200
    protocol: TCP
    targetPort: 2200
  - name: http
    port: 4001
    protocol: TCP
    targetPort: 4001
  selector:
    app: session
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

# Ingress<a id="sec-7"></a>

## list<a id="sec-7-1"></a>

```shell
kubectl get ingress
```

    NAME                    HOSTS                       ADDRESS         PORTS   AGE
    tilt-ingress            tilt.kubemacs.org           10.96.207.142   80      3h52m
    tmate-master-ingress    tmate-server.kubemacs.org   10.96.207.142   80      3h52m
    tmate-session-ingress   tmate.kubemacs.org          10.96.207.142   80      3h52m

## tmate-session-ingress<a id="sec-7-2"></a>

```shell
kubectl get ingress tmate-session-ingress -o yaml | grep -A50 spec:
```

```yaml
spec:
  rules:
  - host: tmate.kubemacs.org
    http:
      paths:
      - backend:
          serviceName: session
          servicePort: 4001
        path: /
status:
  loadBalancer:
    ingress:
    - ip: 10.96.207.142
```

## tmate-master-ingress<a id="sec-7-3"></a>

```shell
kubectl get ingress tmate-master-ingress -o yaml | grep -A50 spec:
```

```yaml
spec:
  rules:
  - host: tmate-server.kubemacs.org
    http:
      paths:
      - backend:
          serviceName: master
          servicePort: 4000
        path: /
status:
  loadBalancer:
    ingress:
    - ip: 10.96.207.142
```

# Setting long node name<a id="sec-8"></a>

## Issue<a id="sec-8-1"></a>

```shell
OBJECT=$(kubectl get pods -l app=session -o name)
POD=$(echo $OBJECT | sed s:.*/::g)
# kubectl describe pod/$POD
# kubectl exec $POD # -c tmate-websocket env
kubectl logs $POD -c tmate-websocket | head -4
```

\#+RESULTS without working node name:

    []
    "Can't set long node name!\nPlease check your configuration\n"
    {error_logger,info_msg}
    2020-02-20 02:42:58.517093 

## erlang args<a id="sec-8-2"></a>

<file:///home/ii/Projects/tmate-websocket/rel/vm.args> This makes me think it's coming from a ENV VAR

```erlang
## Name of the node
-name <%= release_name %>@${ERL_NODE_NAME}
```

## session env from status.podIP<a id="sec-8-3"></a>

Looks like we needed to add an ERL<sub>NODE</sub><sub>NAME</sub> var to our session erlang app in the same way we did for the master.

<session.yaml>

```yaml
- name: ERL_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
```

# mix command<a id="sec-9"></a>

```shell
kubectl exec -it deploy/master mix do ecto.create, ecto.migrate
```

    The database for Tmate.Repo has been created
    
    23:04:29.713 [info]  == Running 20151010162127 Tmate.Repo.Migrations.Initial.change/0 forward
    
    23:04:29.714 [info]  create table events
    
    23:04:29.717 [info]  create index events_type_index
    
    23:04:29.717 [info]  create index events_entity_id_index
    
    23:04:29.718 [info]  create table identities
    
    23:04:29.719 [info]  create index identities_type_key_index
    
    23:04:29.720 [info]  create table sessions
    
    23:04:29.722 [info]  create index sessions_host_identity_id_index
    
    23:04:29.722 [info]  create index sessions_stoken_index
    
    23:04:29.723 [info]  create index sessions_stoken_ro_index
    
    23:04:29.723 [info]  create table clients
    
    23:04:29.724 [info]  create index clients_session_id_client_id_index
    
    23:04:29.725 [info]  create index clients_session_id_index
    
    23:04:29.725 [info]  create index clients_client_id_index
    
    23:04:29.725 [info]  create table users
    
    23:04:29.728 [info]  == Migrated 20151010162127 in 0.0s
    
    23:04:29.742 [info]  == Running 20151221142603 Tmate.Repo.Migrations.KeySize.change/0 forward
    
    23:04:29.742 [info]  alter table identities
    
    23:04:29.743 [info]  == Migrated 20151221142603 in 0.0s
    
    23:04:29.745 [info]  == Running 20160121023039 Tmate.Repo.Migrations.AddMetadataIdentity.change/0 forward
    
    23:04:29.745 [info]  alter table identities
    
    23:04:29.745 [info]  alter table identities
    
    23:04:29.748 [info]  == Migrated 20160121023039 in 0.0s
    
    23:04:29.749 [info]  == Running 20160123063003 Tmate.Repo.Migrations.AddConnectionFmt.change/0 forward
    
    23:04:29.750 [info]  alter table sessions
    
    23:04:29.750 [info]  == Migrated 20160123063003 in 0.0s
    
    23:04:29.751 [info]  == Running 20160304084101 Tmate.Repo.Migrations.AddClientStats.change/0 forward
    
    23:04:29.751 [info]  alter table clients
    
    23:04:29.752 [info]  alter table sessions
    
    23:04:29.752 [info]  == Migrated 20160304084101 in 0.0s
    
    23:04:29.753 [info]  == Running 20160328175128 Tmate.Repo.Migrations.ClientIdUuid.change/0 forward
    
    23:04:29.753 [info]  alter table clients
    
    23:04:29.755 [debug] QUERY OK db=0.2ms
    update clients set id = md5(random()::text || clock_timestamp()::text)::uuid []
    
    23:04:29.755 [info]  drop index clients_session_id_client_id_index
    
    23:04:29.755 [info]  drop index clients_client_id_index
    
    23:04:29.756 [info]  alter table clients
    
    23:04:29.756 [info]  == Migrated 20160328175128 in 0.0s
    
    23:04:29.758 [info]  == Running 20160406210826 Tmate.Repo.Migrations.GithubUsers.change/0 forward
    
    23:04:29.758 [info]  rename column nickname to username on table users
    
    23:04:29.758 [info]  alter table users
    
    23:04:29.759 [info]  create index users_username_index
    
    23:04:29.759 [info]  create index users_email_index
    
    23:04:29.759 [info]  create index users_github_id_index
    
    23:04:29.760 [info]  == Migrated 20160406210826 in 0.0s
    
    23:04:29.761 [info]  == Running 20190904041603 Tmate.Repo.Migrations.AddDisconnectAt.change/0 forward
    
    23:04:29.761 [debug] QUERY OK db=0.2ms
    delete from sessions where closed_at is not null []
    
    23:04:29.762 [debug] QUERY OK db=0.1ms
    delete from clients where left_at is not null []
    
    23:04:29.762 [info]  alter table sessions
    
    23:04:29.762 [info]  alter table clients
    
    23:04:29.762 [info]  alter table sessions
    
    23:04:29.762 [debug] QUERY OK db=0.1ms
    update sessions set disconnected_at = clock_timestamp() []
    
    23:04:29.763 [info]  create index sessions_disconnected_at_index
    
    23:04:29.763 [info]  == Migrated 20190904041603 in 0.0s
    
    23:04:29.764 [info]  == Running 20191005234200 Tmate.Repo.Migrations.AddGeneration.change/0 forward
    
    23:04:29.764 [info]  alter table events
    
    23:04:29.764 [info]  == Migrated 20191005234200 in 0.0s
    
    23:04:29.765 [info]  == Running 20191014044039 Tmate.Repo.Migrations.AddClosedAt.change/0 forward
    
    23:04:29.765 [info]  alter table sessions
    
    23:04:29.766 [info]  == Migrated 20191014044039 in 0.0s
    
    23:04:29.767 [info]  == Running 20191108161753 Tmate.Repo.Migrations.RemoveIdentityOne.change/0 forward
    
    23:04:29.767 [info]  alter table sessions
    
    23:04:29.768 [info]  drop constraint sessions_host_identity_id_fkey from table sessions
    
    23:04:29.768 [info]  alter table clients
    
    23:04:29.769 [info]  drop constraint clients_identity_id_fkey from table clients
    
    23:04:29.769 [info]  == Migrated 20191108161753 in 0.0s
    
    23:04:29.770 [info]  == Running 20191108174232 Tmate.Repo.Migrations.RemoveIdentityThree.change/0 forward
    
    23:04:29.770 [info]  alter table sessions
    
    23:04:29.770 [info]  alter table clients
    
    23:04:29.770 [info]  drop table identities
    
    23:04:29.771 [info]  == Migrated 20191108174232 in 0.0s
    
    23:04:29.773 [info]  == Running 20191110232601 Tmate.Repo.Migrations.RemoveGithubId.change/0 forward
    
    23:04:29.773 [info]  alter table users
    
    23:04:29.773 [info]  == Migrated 20191110232601 in 0.0s
    
    23:04:29.774 [info]  == Running 20191110232704 Tmate.Repo.Migrations.ExpandTokenSize.change/0 forward
    
    23:04:29.774 [info]  drop index sessions_stoken_index
    
    23:04:29.774 [info]  drop index sessions_stoken_ro_index
    
    23:04:29.774 [info]  alter table sessions
    
    23:04:29.775 [info]  create index sessions_stoken_index
    
    23:04:29.775 [info]  create index sessions_stoken_ro_index
    
    23:04:29.776 [info]  == Migrated 20191110232704 in 0.0s
    
    23:04:29.777 [info]  == Running 20191111025821 Tmate.Repo.Migrations.AddApiKey.change/0 forward
    
    23:04:29.777 [info]  alter table users
    
    23:04:29.778 [info]  create index users_api_key_index
    
    23:04:29.778 [info]  == Migrated 20191111025821 in 0.0s

# getting logs<a id="sec-10"></a>

## full logs<a id="sec-10-1"></a>

```shell
OBJECT=$(kubectl get pods -l app=session -o name)
# kubectl describe $POD
POD=$(echo $OBJECT | sed s:.*/::g)
kubectl logs $POD -c tmate-websocket
```

    []
    "Can't set long node name!\nPlease check your configuration\n"
    {error_logger,info_msg}
    2020-02-20 02:27:35.533194 
    #{label=>{proc_lib,crash},report=>[[{initial_call,{net_kernel,init,['Argument__1']}},{pid,<0.1154.0>},{registered_name,[]},{error_info,{exit,{error,badarg},[{gen_server,init_it,6,[{file,"gen_server.erl"},{line,358}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,249}]}]}},{ancestors,[net_sup,kernel_sup,<0.1141.0>]},{message_queue_len,0},{messages,[]},{links,[<0.1151.0>]},{dictionary,[{longnames,true}]},{trap_exit,true},{status,running},{heap_size,1598},{stack_size,27},{reductions,1006}],[]]}
    #{label=>{supervisor,start_error},report=>[{supervisor,{local,net_sup}},{errorContext,start_error},{reason,{'EXIT',nodistribution}},{offender,[{pid,undefined},{id,net_kernel},{mfargs,{net_kernel,start_link,[['tmate@',longnames],true]}},{restart_type,permanent},{shutdown,2000},{child_type,worker}]}]}
    #{label=>{supervisor,start_error},report=>[{supervisor,{local,kernel_sup}},{errorContext,start_error},{reason,{shutdown,{failed_to_start_child,net_kernel,{'EXIT',nodistribution}}}},{offender,[{pid,undefined},{id,net_sup},{mfargs,{erl_distribution,start_link,[]}},{restart_type,permanent},{shutdown,infinity},{child_type,supervisor}]}]}
    #{label=>{proc_lib,crash},report=>[[{initial_call,{application_master,init,['Argument__1','Argument__2','Argument__3','Argument__4']}},{pid,<0.1140.0>},{registered_name,[]},{error_info,{exit,{{shutdown,{failed_to_start_child,net_sup,{shutdown,{failed_to_start_child,net_kernel,{'EXIT',nodistribution}}}}},{kernel,start,[normal,[]]}},[{application_master,init,4,[{file,"application_master.erl"},{line,138}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,249}]}]}},{ancestors,[<0.1139.0>]},{message_queue_len,1},{messages,[{'EXIT',<0.1141.0>,normal}]},{links,[<0.1139.0>,<0.1137.0>]},{dictionary,[]},{trap_exit,true},{status,running},{heap_size,610},{stack_size,27},{reductions,194}],[]]}
    #{label=>{application_controller,exit},report=>[{application,kernel},{exited,{{shutdown,{failed_to_start_child,net_sup,{shutdown,{failed_to_start_child,net_kernel,{'EXIT',nodistribution}}}}},{kernel,start,[normal,[]]}}},{type,permanent}]}
    {"Kernel pid terminated",application_controller,"{application_start_failure,kernel,{{shutdown,{failed_to_start_child,net_sup,{shutdown,{failed_to_start_child,net_kernel,{'EXIT',nodistribution}}}}},{kernel,start,[normal,[]]}}}"}
        args:     format:     label: 2020-02-20 02:27:35.533248 crash_report        2020-02-20 02:27:35.533360 supervisor_report   2020-02-20 02:27:35.533897 supervisor_report   2020-02-20 02:27:35.534706 crash_report        2020-02-20 02:27:35.535142 std_info            Kernel pid terminated (application_controller) ({application_start_failure,kernel,{{shutdown,{failed_to_start_child,net_sup,{shutdown,{failed_to_start_child,net_kernel,{'EXIT',nodistribution}}}}},{ker
    
    Crash dump is being written to: erl_crash.dump...

# kubectl get all<a id="sec-11"></a>

```shell
kubectl get all
```
