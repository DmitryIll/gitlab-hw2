# Домашнее задание к занятию 12 «GitLab»

## Подготовка к выполнению


1. Или подготовьте к работе Managed GitLab от yandex cloud [по инструкции](https://cloud.yandex.ru/docs/managed-gitlab/operations/instance/instance-create) .
Или создайте виртуальную машину из публичного образа [по инструкции](https://cloud.yandex.ru/marketplace/products/yc/gitlab ) .

Создал ВМ.
Вошел с пользователем root и паролем:

![alt text](image.png)


2. Создайте виртуальную машину и установите на нее gitlab runner, подключите к вашему серверу gitlab  [по инструкции](https://docs.gitlab.com/runner/install/linux-repository.html) .

### это были неудачные предварительные попытки, рабочее решение дальше

создал ВМ и установил:

![alt text](image-1.png)

![alt text](image-2.png)

Но, раннер похоже не установлися, т.к. нужен еще докер (?):

![alt text](image-4.png)

Поставил докер:

```
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

Опять пробую установить - пишет что уже все установлено:

![alt text](image-5.png)

При попытке создать раннер в gitlab - долго крутится кружочек ждем, потом пишет:

![alt text](image-6.png)


![alt text](image-7.png)

И gtilab уж очень томозной, хотя было 4 ядра и 4 RAM. Попробовал пересобрать ВМ с 8 Гб.

Перезапустил ВМ с 8 Гб.
Опять пробую создать раннер:

![alt text](image-8.png)

Создал раннер:

![alt text](image-11.png)

![alt text](image-10.png)

далее тут смотрю инструкции:
![alt text](image-12.png)

Пробую запустить получаю ошибку:

![alt text](image-13.png)

ошбика - т.к. IP адрес у ВМ уже поменялся.
Попробую все заново, только с доступом через доменное имя и так gitlab инициализировать, чтобы было в конфигах доменное имя.

В итоге настроил gitlab по https:
Подготовил команды в файле mysedcommands для правки конфига гитлаба и запустил:

```
sudo sed -iE -f mysedcommands  /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure
```
После чего gilab заработал по https и в моем домене:

![alt text](image-14.png)

Создал раннер:
![alt text](image-15.png)

Опять поставил докер на гитлаб раннер.
Установил раннер.
![alt text](image-16.png)

проверил:
![alt text](image-17.png)

![alt text](image-18.png)

Привожу конфиг раннера:

```
root@git-run:~# cat /etc/gitlab-runner/config.toml
concurrent = 1
check_interval = 0
connection_max_age = "15m0s"
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "git-run"
  url = "https://git.dmil.ru"
  id = 1
  token = "glrt-LFbmeZy7GsVnkPHV4H8u"
  token_obtained_at = 2024-05-24T06:57:34Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
    network_mtu = 0
```


3. (* Необязательное задание повышенной сложности. )  Если вы уже знакомы с k8s попробуйте выполнить задание, запустив gitlab server и gitlab runner в k8s  [по инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers). 

4. Создайте свой новый проект.

Создал.

5. Создайте новый репозиторий в GitLab, наполните его [файлами](./repository).

Наполнил:

![alt text](image-19.png)

6. Проект должен быть публичным, остальные настройки по желанию.

Публичный.

## Основная часть

### тоже неудачное решение 2024.05.27, рабочее дальше


Код:

```
image: docker:dind
services:
  - docker:dind

stages:
  - build

build:
  stage: build
  image: docker:dind
  script:
    - docker --version
    - docker build .
```

Опять ошибки:

```
Running with gitlab-runner 17.0.0 (44feccdf)
  on git-run LFbmeZy7G, system ID: s_e77be7377126
Preparing the "docker" executor 00:35
Using Docker executor with image docker:dind ...
Starting service docker:dind ...
Pulling docker image docker:dind ...
Using docker image sha256:d14813e41c93c4df721d287f3d3758e85e74da5edd9033d4897a0f6a44c94ca3 for docker:dind with digest docker@sha256:a811114bcd41954bc9b6577469ce7e648ee600c864e815e535aac79e50439352 ...
Waiting for services to be up and running (timeout 30 seconds)...
*** WARNING: Service runner-lfbmezy7g-project-1-concurrent-0-3b87b538ae2e9649-docker-0 probably didn't start properly.
Health check error:
service "runner-lfbmezy7g-project-1-concurrent-0-3b87b538ae2e9649-docker-0-wait-for-service" timeout
Health check container logs:
2024-05-27T05:34:10.812019564Z waiting for TCP connection to 172.17.0.2 on [2375 2376]...
2024-05-27T05:34:10.812432382Z dialing 172.17.0.2:2376...
2024-05-27T05:34:10.812720357Z dialing 172.17.0.2:2375...
2024-05-27T05:34:11.814611160Z dialing 172.17.0.2:2376...
2024-05-27T05:34:11.814876174Z dialing 172.17.0.2:2375...
2024-05-27T05:34:12.816345444Z dialing 172.17.0.2:2375...
2024-05-27T05:34:12.816406776Z dialing 172.17.0.2:2376...
2024-05-27T05:34:13.816514583Z dialing 172.17.0.2:2376...
2024-05-27T05:34:13.816563570Z dialing 172.17.0.2:2375...
Service container logs:
2024-05-27T05:34:12.771850235Z Certificate request self-signature ok
2024-05-27T05:34:12.771978858Z subject=CN=docker:dind server
2024-05-27T05:34:12.794387858Z /certs/server/cert.pem: OK
2024-05-27T05:34:13.488436959Z Certificate request self-signature ok
2024-05-27T05:34:13.488486589Z subject=CN=docker:dind client
2024-05-27T05:34:13.511872680Z /certs/client/cert.pem: OK
2024-05-27T05:34:13.515039643Z cat: can't open '/proc/net/ip6_tables_names': No such file or directory
2024-05-27T05:34:13.515810406Z cat: can't open '/proc/net/arp_tables_names': No such file or directory
2024-05-27T05:34:13.518428767Z ip: can't find device 'nf_tables'
2024-05-27T05:34:13.519610187Z nf_tables             266240 43 nft_chain_nat,nft_counter,nft_compat
2024-05-27T05:34:13.520104351Z nfnetlink              20480  4 nf_conntrack_netlink,nft_compat,nf_tables
2024-05-27T05:34:13.520121011Z libcrc32c              16384  5 nf_nat,nf_conntrack,nf_tables,btrfs,raid456
2024-05-27T05:34:13.520712327Z modprobe: can't change directory to '/lib/modules': No such file or directory
2024-05-27T05:34:13.523028181Z ip: can't find device 'ip_tables'
2024-05-27T05:34:13.524191282Z ip_tables              32768  0 
2024-05-27T05:34:13.524522086Z x_tables               53248  5 xt_conntrack,xt_MASQUERADE,xt_addrtype,nft_compat,ip_tables
2024-05-27T05:34:13.525236357Z modprobe: can't change directory to '/lib/modules': No such file or directory
2024-05-27T05:34:13.527354198Z iptables v1.8.10 (nf_tables)
2024-05-27T05:34:13.530233765Z mount: permission denied (are you root?)
2024-05-27T05:34:13.530448404Z Could not mount /sys/kernel/security.
2024-05-27T05:34:13.530464387Z AppArmor detection and --privileged mode might break.
2024-05-27T05:34:13.531879729Z mount: permission denied (are you root?)
*********
Using docker image sha256:d14813e41c93c4df721d287f3d3758e85e74da5edd9033d4897a0f6a44c94ca3 for docker:dind with digest docker@sha256:a811114bcd41954bc9b6577469ce7e648ee600c864e815e535aac79e50439352 ...
Preparing environment 00:01
Running on runner-lfbmezy7g-project-1-concurrent-0 via git-run...
Getting source from Git repository 00:01
Fetching changes with git depth set to 20...
Reinitialized existing Git repository in /builds/mygroup/myproject/.git/
Checking out e04c53bc as detached HEAD (ref is main)...
Skipping Git submodules setup
Executing "step_script" stage of the job script 00:01
Using docker image sha256:d14813e41c93c4df721d287f3d3758e85e74da5edd9033d4897a0f6a44c94ca3 for docker:dind with digest docker@sha256:a811114bcd41954bc9b6577469ce7e648ee600c864e815e535aac79e50439352 ...
$ docker --version
Docker version 26.1.3, build b72abbb
$ docker build .
ERROR: error during connect: Head "http://docker:2375/_ping": dial tcp: lookup docker on 192.168.10.2:53: no such host
Cleaning up project directory and file based variables 00:00
ERROR: Job failed: exit code 1
```

В виде скрина:

![alt text](image-25.png)


Докерфайл не меянл, пока такой:

```
FROM python:3.9-slim

WORKDIR /python_api
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY python-api.py ./
CMD ["python", "python-api.py"]
```

### рабочее решение

Еще попробовал сделал второй раннер, на отедльнйо ВМ, но, раннер уже настроил внутри докер контейнера:

- создал ВМ на убунте
- установил докер

```
root@git-run2:~# docker run -ti --rm --name gitlab-runner  \
     --network host \
     -v /srv/gitlab-runner/config:/etc/gitlab-runner    \
     -v /var/run/docker.sock:/var/run/docker.sock  \
      gitlab/gitlab-runner:latest register \
      --url https://git.dmil.ru  --token glrt-ZZZVJNoYGyut4q********U
```

![alt text](image-26.png)

запустил временно контейнер, что бы создались вольюмы.

далее 

```
nano /srv/gitlab-runner/config/config.toml
```
отредактировал:

```
concurrent = 1
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "run2"
  url = "https://git.dmil.ru"
  id = 2
  token = "glrt-ZZZVJNoYGyut4q4vg23U"
  token_obtained_at = 2024-05-27T07:07:11Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    #volumes = ["/cache"]
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0
    network_mtu = 0
```
Запустил:

```
docker run -d --name gitlab-runner --restart always \
      --network host \
      -v /srv/gitlab-runner/config:/etc/gitlab-runner \
      -v /var/run/docker.sock:/var/run/docker.sock \
      gitlab/gitlab-runner:latest

```


![alt text](image-27.png)

Первый раннер поставил на паузу:

![alt text](image-28.png)

Запустил сборку:

![alt text](image-29.png)

несколько раз:

![alt text](image-30.png)

Итого, получается проблема была в раннере.

### 30.052024 

вдруг перестал работать hub.docker.com.

![alt text](image-31.png)

Все переделал заново - подтягиваю докер образ теперь из зеркала:

теперь использую зеркало: https://gallery.ecr.aws/ 


```
docker run -d --name gitlab-runner --restart always       --network host       -v /srv/gitlab-runner/config:/etc/gitlab-runner       -v /var/run/docker.sock:/var/run/docker.sock       public.ecr.aws/gitlab/gitlab-runner
```

использую теперь по умолчанию образ:

```
    image = "public.ecr.aws/docker/library/docker:latest"
```

Конфиг раннера:
```
concurrent = 1
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "git-run"
  url = "https://git.dmil.ru"
  id = 1
  token = "glrt-LWfaCMxGUzx_ncjUzbiC"
  token_obtained_at = 2024-05-30T04:01:52Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "public.ecr.aws/docker/library/docker:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
#    volumes = ["/cache"]
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0
    network_mtu = 0
```

Далее столкнулся с проблемой не получается установить python 3.7 в докер контейнера из начального образа centos7.

докер файл такой (нашел в интернете):

```

FROM public.ecr.aws/docker/library/centos:7

USER root

ENV PYTHON_VERSION=3.7.5 \
    SSL_VERSION=1_1_1d

RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum -y install epel-release && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    yum clean all && \
    yum makecache 
    
RUN yum install -y wget && \
    wget https://github.com/openssl/openssl/archive/OpenSSL_${SSL_VERSION}.tar.gz && \
    tar -zxf OpenSSL_${SSL_VERSION}.tar.gz && \
    yum -y install gcc automake autoconf libtool make zlib zlib-devel  libffi-devel mariadb-devel && \
    cd openssl-OpenSSL_${SSL_VERSION} && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib && \
    make && make install && \
    if [ -f '/usr/bin/openssl' ];then mv /usr/bin/openssl /usr/bin/openssl.bak;fi && \
    if [-d '/usr/include/openssl' ];then mv /usr/include/openssl/ /usr/include/openssl.bak;fi && \
    ln -s /usr/local/openssl/include/openssl /usr/include/openssl && \
    ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so && \
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl && \
    echo 'pathmunge /usr/local/openssl/bin' > /etc/profile.d/openssl.sh && \
    echo '/usr/local/openssl/lib' > /etc/ld.so.conf.d/openssl-${SSL_VERSION}.conf && \
    ldconfig -v && \
    cd .. && rm -rf *OpenSSL_${SSL_VERSION}* && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -Jxf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl && \
    make && make install && \
    rm -rf /usr/bin/python && rm -rf /usr/bin/pip && \
    ln -s /usr/local/python3/bin/python3 /usr/bin/python && \
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/bin/yum-config-manager && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/libexec/urlgrabber-ext-down && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/bin/yum && \
    cd .. && rm -rf Python-${PYTHON_VERSION}* && \
    mkdir -p ~/.pip/ && \
    echo "[global]" > ~/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf && \
    pip install --no-cache-dir --upgrade pip && \
    python -v && \
    yum install -y openssl && \
    yum clean all && \
    rm -rf /var/cache/yum/*

```
Не заработало.

Ошибка: ![alt text](image-32.png)

Поэтому переделал как было использовал образ с питоном.

Итого код сборки:

```
FROM public.ecr.aws/docker/library/python:3.9-slim

WORKDIR /python_api
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY python-api.py ./
CMD ["python", "python-api.py"]
```

Все собралось:

![alt text](image-33.png)

### 06.08

Попробовал собранный образ выложить в докер регистри который в гитлаб.

Код сборки
```
variables:
  CONTAINER_TAG_IMAGE: hello:gitlab-$CI_COMMIT_SHORT_SHA
```
и:
```
    - docker build --build-arg version=$CI_COMMIT_TAG --build-arg username=$CI_REGISTRY_USER --build-arg password=$CI_REGISTRY_PASSWORD -t $CI_REGISTRY/dmil/$CONTAINER_TAG_IMAGE .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY/dmil/$CONTAINER_TAG_IMAGE  
```
Но, в команде логина происходит ошибка:

```
$ docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Error response from daemon: Get "https://git.dmil.ru:5050/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```
или:

![alt text](image-34.png)

При этом пробовал выводить переменные, что бы понять что в них:

![alt text](image-35.png)

Видно что переменная с паролем маскируется:
```
$ echo "$PASS_FROM_CI"
[MASKED]
```
Вопросы:
1. Если переменная с паролем маскируется, то, применяется ли пароль корректно в строке с командой docker login ? Или пароль маскируется только кода выводить на экран нужно?
2. В чем причина ошибки, что (как я понял) не работает регистри докера в gitlab:

```
Error response from daemon: Get "https://git.dmil.ru:5050/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

Что нужно сделать, что бы исправить ошибку?
Я использую ВМ в яндекс облаке с оразом станадртным яндекс облака с gitlab.
Видимо в конфигах gitlab нужно открыть этот порт?

3. Что значит:
```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
```
что значит Use --password-stdin. ? Как это использовать?

4. Если я буду пушить в яндекс регистри докер, то, как правильно сделать авторизацию к регистри в яндекс облаке? Видимо нужно создать временный токен на 12 часов, и его использовать? Но, что бы его создать нужно использовать длительный токен? Как его не светить и правильно указать в пайплайне?

5. Я так пока и не понял почему у меня докер раннер не запускался если он на ВМ без докера. Может там вольюм в конфиге не нужно пробрасывать? В чем некорректность конфига?
Т.е. конфиг, который генерит сам раннер при установке не корректный если раннер работает на ОС? Тут пока не понял.

6. и не понял в каких случаях в коде нужно выполнять, например:

```
image: docker:20.10.8
services:
  - docker:20.10.8-dind
```
У меня и без этого работает, если раннер в докер контейнере.


### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
У меня все-таки образ начальный 
```
FROM public.ecr.aws/docker/library/python:3.9-slim
```

2. Python версии не ниже 3.7.

У меня получился все-таки ниже.

3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
Выполнено.
4. Создана директория `/python_api`.
Выполнено.
5. Скрипт из репозитория размещён в /python_api.
Выполнено.
6. Точка вызова: запуск скрипта.
Выполнено.
7. При комите в любую ветку должен собираться docker image с форматом имени hello:gitlab-$CI_COMMIT_SHORT_SHA . Образ должен быть выложен в Gitlab registry или yandex registry.   




### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.

### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную ветку, связанную с этим Issue.
2. Внести изменения по тексту из задания.
3. Подготовить Merge Request, влить необходимые изменения в `master`, проверить, что сборка прошла успешно.


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл gitlab-ci.yml;
- Dockerfile; 
- лог успешного выполнения пайплайна;
- решённый Issue.

### Важно 
После выполнения задания выключите и удалите все задействованные ресурсы в Yandex Cloud.

