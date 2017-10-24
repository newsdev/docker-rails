# Docer Rails with Pronto

The [Docker Rails](https://github.com/newsdev/docker-rails) with additions to support pronto gem for gitlab ci.

package|version
:---|:---
[ruby](https://www.ruby-lang.org/)|2.4.1
[cmake](https://cmake.org/)|3.4.3
[libssh](http://www.libssh2.org/)|1.6.0
[node](https://nodejs.org/)|8.1.2
[libgit2](https://github.com/libgit2/libgit2) | master

## Add pronto to your Gemfile

```
gem 'pronto'
  gem 'pronto-brakeman', require: false
  gem 'pronto-flay', require: false
  gem 'pronto-rails_best_practices', require: false
  gem 'pronto-rails_schema', require: false
  gem 'pronto-rubocop', require: false
```

## Example `.gitlab-ci.yml`

```
image: "muhammet/docker-rails-with-pronto:latest"
services:
  - mysql:latest
  - redis:latest

variables:
  # Configure mysql environment variables (https://hub.docker.com/r/_/mysql/)
  MYSQL_DATABASE: blah
  MYSQL_ROOT_PASSWORD: blah

stages:
  - review

before_script:  
  - gem install bundler --no-ri --no-rdoc
  - bundle install --jobs $(nproc) "${FLAGS[@]}"

review:
  stage: review
  tags:
    - ruby
    - linux
  script:
    - PRONTO_GITLAB_API_PRIVATE_TOKEN=YOUR_PRIVATE_TOKEN pronto run -f gitlab -c origin/master

```

## Authors

[Muhammet](https://github.com/muhammet)

Many thanks to [@newsdev](https://github.com/newsdev) for [Docker Rails](https://github.com/newsdev/docker-rails) project.
