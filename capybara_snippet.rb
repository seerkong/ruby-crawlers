// Rails 3.0.0
$ rails generate cucumber:install --rspec --capybara

# Webrat
field_with_id('openid_identifier').value.should =~ /invalid OpenID/
# Capybara
find_field('openid_identifier').value.should =~ /invalid OpenID/

# Webrat
response.should contain('Previous')
# Capybara
page.should have_content('Previous')

# Webrat
assert_have_selector('.author', :count => 1)
# Capybara
page.should have_css('.author', :count => 1)

# Webrat
assert_have_xpath("//span[@id='#{id}']", :content => expected_count)
# Capybara
page.should have_xpath("//span[@id='#{id}']", :text => expected_count)

cookies = Capybara.current_session.driver.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
cookies[:remember_me_id] = remember_me_id