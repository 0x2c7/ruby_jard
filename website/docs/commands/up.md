<div class="alert alert--warning">TODO: This page is still under construction.</div>

**Repl command**: `up`

**Key binding**: F6

**Examples:**

```
up     # Move to upper frame
up 3   # Move to upper 3 frames
```

Explore the upper frame. When you use this command, all associated displaying screens will be updated accordingly, but your program current position is still at the latest frame. This command is mostly used to explore, and view the trace, input parameters, or how your program stops at the current position. When use this command, you should have a glance at Variable panel, and Source panel to see the variables at destination frame.

You can combine with `next` or `step` to perform powerful execution redirection at the destination frame. Let's look at an example. You are debugging a chain of 10 rack middlewares, you go deep into the #9 middleware, found something, then want to go back to #5 middleware. It's pretty boring and frustrated to just use `next` or `step-out` and hope it eventually goes back. Now use `up` for some times (or `frame`, described below) to go to your desired frame, and use `next` there. Tada, it's magical, just like teleport.

One note is that you cannot explore a frame in c.
