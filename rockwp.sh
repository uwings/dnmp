#! /bin/bash
LINE="══════════════════════════════════════════════════"
SLINE="──────────────────────────────────────────────────"
echo -e "\n$LINE"
echo "      Install dependences, start docker"
echo -e "$LINE\n"
cp env.sample .env
cp docker-compose.sample.yml docker-compose.yml
docker-compose up -d

echo -e "\n$LINE"
echo "      Install wordpress in webroot?"
echo -e "$LINE\n"
PS3='Choice you option: '
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            mkdir tmp
            echo -e "\n$LINE"
            echo "        Install axel download WP"
            echo -e "$LINE\n"
            PS3='How to install axel (Multi-threaded download WP): '
            options=("use CentOS yum" "use MacOS brew" "don not use axel,use wget")
            select opt in "${options[@]}"
            do
                case $opt in
                    "use CentOS yum")
                        yum install  -y axel
                        axel -n 10 -a -o ./tmp/latest-zh_CN.tar.gz https://cn.wordpress.org/latest-zh_CN.tar.gz
                        break
                        ;;
                    "use MacOS brew")
                        brew install axel
                        axel -n 10 -a -o ./tmp/latest-zh_CN.tar.gz https://cn.wordpress.org/latest-zh_CN.tar.gz
                        break
                        ;;
                    "don not use axel,use wget")
                        wget -c -O ./tmp/latest-zh_CN.tar.gz https://cn.wordpress.org/latest-zh_CN.tar.gz
                        break
                        ;;
                    *) echo "invalid option $REPLY , please slect form the list" ;;
                esac
            done
            echo -e "\n$LINE"
            echo "     Download success, move to webroot"
            echo -e "$LINE/n"
            cd tmp
            tar -zxvf latest-zh_CN.tar.gz
            cd ..
            #mv ./www/localhost/index.php ./www/localhost/index.php.bak
            cp -rf ./tmp/wordpress/* ./www/localhost
            sleep 7
            echo "..."
            rm -rf ./tmp
            echo -e "\n$LINE"
            echo "       Already add wordpress to webroot"
            echo -e "$LINE\n"
            break
            ;;
        "No")
            break
            ;;
        *) echo "invalid option $REPLY , please slect form the list" ;;
    esac
done

echo -e "\n$LINE"
echo "      Add swoole_loader74?"
echo -e "$LINE\n"
PS3='Choice you option: '
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            echo -e "\n$LINE"
            echo "              Add swoole_loader74"
            echo -e "$LINE\n"
            echo -e "\nextension=swoole_loader74.so">>./services/php/php.ini
            docker cp ./customfile/swoole_loader74.so php:/usr/local/lib/php/extensions/no-debug-non-zts-20190902
            docker-compose down
            docker-compose build php
            echo -e "\n$LINE"
            echo "       Success add swoole_loader74"
            echo -e "$LINE\n"
            break
            ;;
        "No")
            break
            ;;
        *) echo "invalid option $REPLY , please slect form the list" ;;
    esac
done

echo -e "\n$LINE"
echo "      Add WP rewrite rule?"
echo -e "$LINE\n"
PS3='Choice you option: '
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            cd services/nginx/conf.d
            sed -i '' '34 r ../../../customfile/wprewrite.txt' localhost.conf
            cd ../../../
            docker-compose restart nginx
            break
            ;;
        "No")
            break
            ;;
        *) echo "invalid option $REPLY , please slect form the list" ;;
    esac
done

echo -e "\n$LINE"
echo "              Restart Sever"
echo -e "$LINE\n"
docker-compose stop
docker-compose up -d
echo -e "\n$LINE"
echo "          Run dnmp in background mode."
echo "$SLINE"
echo "homepage :        http://localhost"
echo "Phpmyadmin :      http://localhost:8080"
echo -e "$LINE\n"
