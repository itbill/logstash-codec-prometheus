# Overview

This codec decodes prometheus exposition document into json.

**Q**: Since Prometheus is pull based; why do we even need Logstash involved?</br>
**A**: A logstash codec plugin allows logstash to obtain metrics from any prometheus exporter, which might be desirable for environments where monitoring is built around ELK stack.<br>
See also the orignal author's comments here: https://github.com/yesmarket/logstash-codec-prometheus

# Example

Using the [http_poller](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-http_poller.html) input plugin to scrape prometheus metrics:
```ruby
input {
   http_poller {
      urls => {
         myurl => "https://test:1234/metrics"
      }
      keepalive => true
      automatic_retries => 1
      schedule => { cron => "* * * * * UTC"}
      codec => "prometheus"
   }
}
```

The following prometheus data:
```ruby
# HELP go_memstats_mallocs_total Total number of mallocs.
# TYPE go_memstats_mallocs_total counter
go_memstats_mallocs_total 1.1002486092e+10
# HELP go_memstats_mcache_inuse_bytes Number of bytes in use by mcache structures.
# TYPE go_memstats_mcache_inuse_bytes gauge
go_memstats_mcache_inuse_bytes 3472
# HELP node_cpu_seconds_total Seconds the cpus spent in each mode.
# TYPE node_cpu_seconds_total counter
node_cpu_seconds_total{cpu="0",mode="idle"} 600118.2
node_cpu_seconds_total{cpu="0",mode="iowait"} 967.03
```

Can get tanslated to multiple documents, formatted as follows:
```json
{
  "name": "go_memstats_mallocs_total",
  "help": "Total number of mallocs.",
  "type": "counter",
  "value": 11002486092
}
```

```json
{
  "name": "go_memstats_mcache_inuse_bytes",
  "help": "Number of bytes in use by mcache structures.",
  "type": "gauge",
  "value": 3472
}
```

```json
{
  "name": "node_cpu_seconds_total",
  "help": "Seconds the cpus spent in each mode.",
  "type": "counter",
  "value": 600118.2,
  "dimensions": {
    "cpu": "0",
    "mode": "idle"
  }
}
```

```json
{
  "name": "node_cpu_seconds_total",
  "help": "Seconds the cpus spent in each mode.",
  "type": "counter",
  "value": 967.03,
  "dimensions": {
    "cpu": "0",
    "mode": "iowait"
  }
}
```
