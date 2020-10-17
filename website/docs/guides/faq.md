---
id: FAQ
slug: faq
---

### Why does Jard sometimes fail to stop in Ruby 2.7?

Jard depends on Byebug, and Byebug depends on Ruby Tracepoint. In Ruby 2.7.0 and 2.7.1, Tracepoint has a bug that breaks Byebug. The bug is fixed, and released in Ruby 2.7.2. See more in [this issue](https://github.com/deivid-rodriguez/byebug/issues/719).

### Can Ruby Jard work with Docker?

Yes it can. However, if you are using `docker-compose up`, you may have to change your workflow a little bit since that command is not meant to be interactive. To enable Ruby Jard in docker:

- Use `docker exec -it` or `docker run -it`
- Use `docker-compose run` with `tty: true` and `stdin_open: true` flags. For example: `docker-compose run --service-ports web`
- Use `docker-compose up -d`. Then `docker ps`. Then `docker attach` to attach into your service docker instance.
