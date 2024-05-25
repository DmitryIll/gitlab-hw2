# Пример см. https://docs.gitlab.com/omnibus/settings/ssl/ 

#sudo dpkg -i "gitlab-ee_13.6.3-ee.0_amd64_bionic.deb"
#sudo gitlab-ctl reconfigure
#sudo gitlab-ctl restart
#sudo gitlab-ctl start

# замена в
# external_url 'http://gitlab.example.com'
################################################################################
# Let's Encrypt integration
################################################################################
# letsencrypt['enable'] = nil
# letsencrypt['contact_emails'] = [] # This should be an array of email addresses to add as contacts
# letsencrypt['group'] = 'root'
# letsencrypt['key_size'] = 2048
# letsencrypt['owner'] = 'root'
# letsencrypt['wwwroot'] = '/var/opt/gitlab/nginx/www'
# See http://docs.gitlab.com/omnibus/settings/ssl.html#automatic-renewal for more on these sesttings
# letsencrypt['auto_renew'] = true
# letsencrypt['auto_renew_hour'] = 0
# letsencrypt['auto_renew_minute'] = nil # Should be a number or cron expression, if specified.
# letsencrypt['auto_renew_day_of_month'] = "*/4"

#sudo sed -iE "/^external_url /c external_url 'https://git.dmil.ru'" /etc/gitlab/gitlab.rb
#sudo sed -iE "/letsencrypt\['enable'\]/c letsencrypt['enable'] = nil" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['group'\] = 'root'/c letsencrypt['group'] = 'root'" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['key_size'\]/c letsencrypt['key_size'] = 2048" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['owner'\]/c letsencrypt['owner'] = 'root'" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['wwwroot'\]/c letsencrypt['wwwroot'] = '/var/opt/gitlab/nginx/www'" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['auto_renew'\]/c letsencrypt['auto_renew'] = true" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['auto_renew_hour'\]/c letsencrypt['auto_renew_hour'] = 0" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['auto_renew_minute'\]/c letsencrypt['auto_renew_minute'] = 0" /etc/gitlab/gitlab.rb 
#sudo sed -iE "/letsencrypt\['auto_renew_day_of_month'\]/c letsencrypt['auto_renew_day_of_month'] = '*/4'" /etc/gitlab/gitlab.rb 

sudo sed -iE -f mysedcommands  /etc/gitlab/gitlab.rb 
sudo gitlab-ctl reconfigure


