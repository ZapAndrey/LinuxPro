# Размещение своего RPM в своем репозитории #
## Задание ##
* создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями);

* создать свой репо и разместить там свой RPM;

* реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.

## Создаем свой RPM - nginx с поддержкой openssl
```bash
# стартуем vagrant
vagrant up  
vagrant ssh

# загружаем nginx
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm  
rpm -i nginx-1.*
# загружаем openssl
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip  
unzip OpenSSL_1_1_1-stable.zip
# проверяем
ll

# ставим зависимости
sudo yum-builddep rpmbuild/SPECS/nginx.spec

vim rpmbuild/SPECS/nginx.spec
# добавляем опцию --with-openssl=/home/vagrant/openssl-OpenSSL_1_1_1-stable в ./configure
# и удаляем --with-debug

# собираем RPM
rpmbuild -bb rpmbuild/SPECS/nginx.spec

# проверяем
ll rpmbuild/RPMS/x86_64/

# устанавливаем пакет и проверяем работу
sudo yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm
sudo systemctl start nginx
sudo systemctl status nginx
```
## Создаем свой репозиторий OTUS
```bash
# создаем директорию для пакетов
sudo mkdir /usr/share/nginx/html/repo
# помещаем туда наш пакет и пакет из интернета
sudo cp rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
sudo wget https://downloads.percona.com/downloads/pmm2/2.38.0/binary/redhat/7/x86_64/pmm2-client-2.38.0-6.el7.x86_64.rpm
sudo mv pmm2-client-2.38.0-6.el7.x86_64.rpm /usr/share/nginx/html/repo/
# проверяем
ll /usr/share/nginx/html/repo
# инициализируем репозиторий
sudo createrepo /usr/share/nginx/html/repo/

# правим файл
sudo vim /etc/nginx/conf.d/default.conf
# добавляем директиву autoindex on; в секцию "location /"

# проверяем конфигурацию nginx
sudo nginx -t
# перечитываем конфигурацию
sudo nginx -s reload
# проверяем
curl -a http://localhost/repo/

# добавляем новый репозиторий

# правим файл 
sudo vim /etc/yum.repos.d/otus.repo

> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1

# проверяем наличие репозитория
yum repolist enabled | grep otus

sudo yum install pmm2-client.x86_64 -y
```