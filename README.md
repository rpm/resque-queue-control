# Resque::QueueControl

A [Resque](https://github.com/defunkt/resque) plugin. Requires Resque >= 1.20.0.

Based on the work of [Resque Pause](https://github.com/wandenberg/resque-pause) and
[Resque Lonely Job](https://github.com/wallace/resque-lonely_job)

Allows for the pausing of a given queue and the control of how the maximum amount of simultaneous running workers
per queue (currently fixed at 1)
