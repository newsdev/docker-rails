# docker-rails

The [base Ruby image](https://hub.docker.com/_/ruby/)(2.5) with additions to support Rails.

package|version
:---|:---
[ruby](https://www.ruby-lang.org/)|2.5.1
[cmake](https://cmake.org/)|NA
[libssh](http://www.libssh2.org/)|NA
[node](https://nodejs.org/)|8.12.0


```
docker build . -t newsdev/rails:2.5
docker push newsdev/rails:2.5
```
