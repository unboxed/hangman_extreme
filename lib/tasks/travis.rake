namespace :travis do

  namespace :create do

    desc "create the database for travis ci"
    task :db do
      template_yml = File.read("config/database.travis_template.yml")
      case ENV['DB_ADAPTER']
        when 'postgresql'
          puts `psql -c 'create database hangnman_extreme;' -U postgres`
          template_yml.gsub!('%%username%%','postgres')
          template_yml.gsub!('%%adapter%%','postgresql')
        when 'mysql'
          puts `mysql -e 'create database hangnman_extreme;'`
          template_yml.gsub!('%%username%%','root')
          template_yml.gsub!('%%adapter%%',RUBY_PLATFORM == 'java' ? 'mysql' : 'mysql2')
        when 'sqlite3'
          template_yml.gsub!('%%username%%','')
          template_yml.gsub!('%%adapter%%','sqlite3')
      end
      File.open("config/database.travis.yml","w"){|fp| fp << template_yml}
    end
  end

end