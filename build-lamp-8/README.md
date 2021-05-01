To use the embedded Docker Environment, follow these steps from this directory:  

1. Download a copy of the database and uploads from a backup to your local environment (if applicable). 
1. Extract and rename the database dumps to build-dev/mysql-on-build/import-dump and/or build-dev/postgres-on-build/import-dump (if applicable)
1. Extract the uploads to src/httpdocs/uploads/  (for wordpress)
1. Run `docker-compose up --build`  
1. Navigate to http://localhost:8081 in your web browser.  

You should now have a functioning development environment.

Some additional tips for the Docker Environment:  

1. To download a backup, you need to access the appropriate S3 bucket. Using your IAM credentials and the S3 console:  
IAM Console=https://deltasys.signin.aws.amazon.com/console  
Navigate to the S3 dashboard and locate the correct bucket:  
S3 Bucket: 
Bucket=$bucket-name  
Path=$hostname

1. To connect directly to the Postgres DB server, use these credentials:  
host=localhost  
port=5433  
user=postgres  
pass=Pass@1234  

1. To stop and start your Docker environment, use the following commands:  
`docker-compose stop`  
`docker-compose start` 
To daemonize your runs add the `-d` flag  
`docker-compose start -d`  
*Warning:* If you use `docker-compose down` it will tear down your containers and the data contained therein. The `import-data` SQL file will be imported when starting the containers for the first time, taking awhile to finish.

1. If you need to access the web server's shell to execute CLI commands, you can do so like this:  
`docker-compose run web /bin/bash`  
If executing a cron, don't forget to add APPLICATION_ENV:  
`APPLICATION_ENV=development_docker ./exec-cron`  
*Note:* If you run into a bad interpreter error when running PHP from the CLI, it may be because the assumped PHP location is actually different on the Docker container. Run the following:  
`ln -s -f /usr/local/bin/php /usr/bin/php`  