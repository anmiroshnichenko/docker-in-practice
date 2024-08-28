# Домашнее задание к занятию 5. «Практическое применение Docker»

### Инструкция к выполнению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
3. **Своё решение к задачам оформите в вашем GitHub репозитории.**
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.
5. Сопроводите ответ необходимыми скриншотами.

---
## Примечание: Ознакомьтесь со схемой виртуального стенда [по ссылке](https://github.com/netology-code/shvirtd-example-python/blob/main/schema.pdf)

---

## Задача 0
1. Убедитесь что у вас НЕ(!) установлен ```docker-compose```, для этого получите следующую ошибку от команды ```docker-compose --version```
```
Command 'docker-compose' not found, but can be installed with:

sudo snap install docker          # version 24.0.5, or
sudo apt  install docker-compose  # version 1.25.0-1

See 'snap info docker' for additional versions.
```
В случае наличия установленного в системе ```docker-compose``` - удалите его.  
2. Убедитесь что у вас УСТАНОВЛЕН ```docker compose```(без тире) версии не менее v2.24.X, для это выполните команду ```docker compose version```  

![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/0_1.jpg)

###  **Своё решение к задачам оформите в вашем GitHub репозитории!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**

---

## Задача 1
1. Сделайте в своем github пространстве fork репозитория ```https://github.com/netology-code/shvirtd-example-python/blob/main/README.md```.   
2. Создайте файл с именем ```Dockerfile.python``` для сборки данного проекта(для 3 задания изучите https://docs.docker.com/compose/compose-file/build/ ). Используйте базовый образ ```python:3.9-slim```. 
Обязательно используйте конструкцию ```COPY . .``` в Dockerfile. Не забудьте исключить ненужные в имадже файлы с помощью .dockerignore. Протестируйте корректность сборки.  
Dockerfile.python:

```
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py ./
# .dockerignore test
#COPY . /app/test  
CMD ["python", "main.py"]
```

3. (Необязательная часть, *) Изучите инструкцию в проекте и запустите web-приложение без использования docker в venv. (Mysql БД можно запустить в docker run).
 Изменил .env:
 ```
MYSQL_ROOT_PASSWORD="YtReWq4321"

MYSQL_DATABASE="virtd"
MYSQL_USER="app"
MYSQL_PASSWORD="QwErTy1234"

DB_USER=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}
DB_NAME=${MYSQL_DATABASE}
 ```
Изменил main.py:
```
from flask import Flask
from flask import request
import os
from dotenv import load_dotenv 
load_dotenv()  # take environment variables from .env.
import mysql.connector
from datetime import datetime
```
```
git clone https://github.com/netology-code/shvirtd-example-python.git
cd shvirtd-example-python
sudo apt install python3.8-venv
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
docker run -d   -v './db_data:/var/lib/mysql' -e \
	'MYSQL_ROOT_PASSWORD=YtReWq4321' -e 'MYSQL_DATABASE=virtd' -e 'MYSQL_USER=app' -e \
	'MYSQL_PASSWORD=QwErTy1234' -p 3306:3306 --name db-mysql   mysql:8
pip install python-dotenv # пакет читает  файл .env, и загружает необходимые  приложению переменные среды
python main.py
``` 
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/1.jpg)

4. (Необязательная часть, *) По образцу предоставленного python кода внесите в него исправление для управления названием используемой таблицы через ENV переменную.
### Изменил main.py:
```
from flask import Flask
from flask import request
import os
from dotenv import load_dotenv 
load_dotenv()  # take environment variables from .env.
import mysql.connector
from datetime import datetime
app = Flask(__name__)
db_host=os.environ.get('DB_HOST')
db_user=os.environ.get('DB_USER')
db_password=os.environ.get('DB_PASSWORD')
db_database=os.environ.get('DB_NAME')
db_datatable=os.environ.get('DB_TABLE')
print(f'Используем таблицу: {db_datatable}')
# Подключение к базе данных MySQL
db = mysql.connector.connect(
host=db_host,
user=db_user,
password=db_password,
database=db_database,
autocommit=True )
cursor = db.cursor()
# SQL-запрос для создания таблицы в БД
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {db_database}.{db_datatable}  (
id INT AUTO_INCREMENT PRIMARY KEY,
request_date DATETIME,
request_ip VARCHAR(255)
)
"""
cursor.execute(create_table_query)

@app.route('/')
def index():
    # Получение IP-адреса пользователя
    ip_address = request.headers.get('X-Forwarded-For')

    # Запись в базу данных
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    query = f"INSERT INTO {db_database}.{db_datatable}  (request_date, request_ip) VALUES (%s, %s)"
    values = (current_time, ip_address)
    cursor.execute(query, values)
    db.commit()

    return f'TIME: {current_time}, IP: {ip_address}'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```
### Добавил переременную DB_TABLE в .env:

```
MYSQL_ROOT_PASSWORD="YtReWq4321"
MYSQL_DATABASE="virtd"
MYSQL_USER="app"
MYSQL_PASSWORD="QwErTy1234"
DB_USER=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}
DB_NAME=${MYSQL_DATABASE}
DB_TABLE=new_table
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/1_4.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/1_4_1.jpg)

---
### ВНИМАНИЕ!
!!! В процессе последующего выполнения ДЗ НЕ изменяйте содержимое файлов в fork-репозитории! Ваша задача ДОБАВИТЬ 5 файлов: ```Dockerfile.python```, ```compose.yaml```, ```.gitignore```, ```.dockerignore```,```bash-скрипт```. Если вам понадобилось внести иные изменения в проект - вы что-то делаете неверно!
---

## Задача 2 (*)
1. Создайте в yandex cloud container registry с именем "test" с помощью "yc tool" . [Инструкция](https://cloud.yandex.ru/ru/docs/container-registry/quickstart/?from=int-console-help)
2. Настройте аутентификацию вашего локального docker в yandex container registry.
3. Соберите и залейте в него образ с python приложением из задания №1.
4. Просканируйте образ на уязвимости.
5. В качестве ответа приложите отчет сканирования.

```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
yc init
yc config profile list
yc config profile  get test 
yc container registry create --name  test
yc container registry configure-docker
cat /home/miroshnichenko_an/.docker/config.json
docker build -t py-app  -f Dockerfile.python .
docker images
docker tag py-app:latest  cr.yandex/crp1f4c1p1705f2hsk89/py-app:hello
docker push cr.yandex/crp1f4c1p1705f2hsk89/py-app:hello
yc container image list --repository-name=crp1f4c1p1705f2hsk89/py-app
yc container image scan crpait1ss1f39hrnbii5 
yc container image list-vulnerabilities --scan-result-id=cheb6gtta2j5gkeqlreq
yc container image list-scan-results --repository-name=crp1f4c1p1705f2hsk89/py-app
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_1.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_2.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_3.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_4.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_5.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_6.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/2_7.jpg)

## Задача 3
1. Изучите файл "proxy.yaml"
2. Создайте в репозитории с проектом файл ```compose.yaml```. С помощью директивы "include" подключите к нему файл "proxy.yaml".
3. Опишите в файле ```compose.yaml``` следующие сервисы: 

- ```web```. Образ приложения должен ИЛИ собираться при запуске compose из файла ```Dockerfile.python``` ИЛИ скачиваться из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.5```. Сервис должен всегда перезапускаться в случае ошибок.
Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса ```web``` 

- ```db```. image=mysql:8. Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.10```. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

4. Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда ```curl -L http://127.0.0.1:8090``` должна возвращать в качестве ответа время и локальный IP-адрес. Если сервисы не стартуют воспользуйтесь командами: ```docker ps -a ``` и ```docker logs <container_name>``` . Если вместо IP-адреса вы получаете ```NULL``` --убедитесь, что вы шлете запрос на порт ```8090```, а не 5000.
```
sudo docker compose up  -d
sudo docker ps -a
sudo docker compose ps -a
curl -L http://127.0.0.1:8090
sudo docker logs py-app --tail 10
sudo docker compose logs -f --tail 5 web
sudo docker compose logs --tail 10 web
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/3_1.jpg)

5. Подключитесь к БД mysql с помощью команды ```docker exec <имя_контейнера> mysql -uroot -p<пароль root-пользователя>```(обратите внимание что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем) . Введите последовательно команды (не забываем в конце символ ; ): ```show databases; use <имя вашей базы данных(по-умолчанию example)>; show tables; SELECT * from requests LIMIT 10;```.

```
sudo docker exec -it  db-mysql mysql -uroot -pYtReWq4321

```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/3_2.jpg)

6. Остановите проект. В качестве ответа приложите скриншот sql-запроса.

![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/3_3.jpg)

## Задача 4
1. Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).
2. Подключитесь к Вм по ssh и установите docker.
3. Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.
4. Зайдите на сайт проверки http подключений, например(или аналогичный): ```https://check-host.net/check-http``` и запустите проверку вашего сервиса ```http://<внешний_IP-адрес_вашей_ВМ>:8090```. Таким образом трафик будет направлен в ingress-proxy. ПРИМЕЧАНИЕ: Приложение весьма вероятно упадет под нагрузкой, но успеет обработать часть запросов - этого достаточно.
5. (Необязательная часть) Дополнительно настройте remote ssh context к вашему серверу. Отобразите список контекстов и результат удаленного выполнения ```docker ps -a```
6. В качестве ответа повторите  sql-запрос и приложите скриншот с данного сервера, bash-скрипт и ссылку на fork-репозиторий.

```
#!/bin/bash
cd /opt
git clone https://github.com/anmiroshnichenko/docker-in-practice.git
cd  docker-in-practice && docker compose up -d   
docker compose ps -a 
``` 
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/create_vm.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/4_1.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/4_2.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/4_3.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/4_5.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/4_6.jpg)

## Задача 5 (*)
1. Напишите и задеплойте на вашу облачную ВМ bash скрипт, который произведет резервное копирование БД mysql в директорию "/opt/backup" с помощью запуска в сети "backend" контейнера из образа ```schnitzler/mysqldump``` при помощи ```docker run ...``` команды. Подсказка: "документация образа."
2. Протестируйте ручной запуск
3. Настройте выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Придумайте способ не светить логин/пароль в git!!
4. Предоставьте скрипт, cron-task и скриншот с несколькими резервными копиями в "/opt/backup"
Создал  файл /op/dump_mysql.sh:    
```
#!/bin/bash
 docker run \
    --rm --entrypoint "" \
    -v /opt/backup:/backup \
    --link="container:db-mysql" \
    --network="docker-in-practice_backend" \
    schnitzler/mysqldump \
    mysqldump --opt -h db -u root -p"YtReWq4321" "--result-file=/backup/dump_$(date +%Y.%m.%d-%H.%M.%S).sql" virtd   > /dev/null 2>&1
```
```
sudo crontab -u root -e
sudo cat /var/log/syslog | grep CRON
ls -la /opt/backup
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/5_1.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/5_2.jpg)
 
## Задача 6
Скачайте docker образ ```hashicorp/terraform:latest``` и скопируйте бинарный файл ```/bin/terraform``` на свою локальную машину, используя dive и docker save.
Предоставьте скриншоты  действий .

```
sudo docker pull  hashicorp/terraform:latest
sudo docker images
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest hashicorp/terraform
# Digest: sha256:2e4c7a391cbe470bdd510791978859db7e09e412dc2587c5b27451aef764cf1b
sudo docker save -o /tmp/image_hashicorp.tar.gz hashicorp/terraform 
sudo tar xf /tmp/image_hashicorp.tar.gz
cd /tmp/ &&  ls
cd blobs/sha256/ && ls
sudo tar xf 2e4c7a391cbe470bdd510791978859db7e09e412dc2587c5b27451aef764cf1b  &&  ls 
ls -la bin/
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6_1.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6_2.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6_3.jpg)

## Задача 6.1
Добейтесь аналогичного результата, используя docker cp.  
Предоставьте скриншоты  действий .

```
sudo docker images
sudo docker run  -d  --name=terraform  hashicorp/terraform
sudo docker ps -a 
sudo docker cp terraform:/bin/terraform  /tmp   && ls -la  /tmp/  | grep terraform
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6.1_1.jpg)

## Задача 6.2 (**)
Предложите способ извлечь файл из контейнера, используя только команду docker build и любой Dockerfile.  
Предоставьте скриншоты  действий .

Рузультатом сборки будет экспорт всех файлов в  директорию  image_files

```
sudo docker  build -o image_files  .
```
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6.2_1.jpg)
![Image alt](https://github.com/anmiroshnichenko/docker-in-practice/blob/main/screenshots/6.2_2.jpg)


## Задача 7 (***)
Запустите ваше python-приложение с помощью runC, не используя docker или containerd.  
Предоставьте скриншоты  действий .
