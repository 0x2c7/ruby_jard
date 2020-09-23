---
id: FAQ
slug: faq
---

### Can Ruby Jard work with Docker?

Yes it does. However, if you are using `docker-compose up`, you may change your workflow a little bit. That command is not meant to be interactive. To enable Ruby Jard in docker:

- Use `docker exec -it` or `docker run -it`
- Use `docker-compose run` with `tty: true` and `stdin_open: true` flags. For example: `docker-compose run --service-ports web`
- Use `docker-compose up -d`. Then `docker ps`. Then `docker attach` to attach into your service docker instance.
