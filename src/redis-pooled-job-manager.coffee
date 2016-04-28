{Pool}           = require 'generic-pool'
redis            = require 'ioredis'
RedisNS          = require '@octoblu/redis-ns'
JobLogger        = require 'job-logger'
PooledJobManager = require 'meshblu-core-pooled-job-manager'

class RedisPooledJobManager
  constructor: (options={}) ->
    {jobLogIndexPrefix, jobLogQueue, jobLogRedisUri, jobLogSampleRate, jobLogType} = options
    {jobTimeoutSeconds, maxConnections, minConnections, idleTimeoutMillis, namespace, redisUri} = options

    minConnections ?= 1
    idleTimeoutMillis ?= 60000

    throw new Error('RedisPooledJobManager: jobLogIndexPrefix is required') unless jobLogIndexPrefix?
    throw new Error('RedisPooledJobManager: jobLogQueue is required') unless jobLogQueue?
    throw new Error('RedisPooledJobManager: jobLogRedisUri is required') unless jobLogRedisUri?
    throw new Error('RedisPooledJobManager: jobLogSampleRate is required') unless jobLogSampleRate?
    throw new Error('RedisPooledJobManager: jobLogType is required') unless jobLogType?
    throw new Error('RedisPooledJobManager: jobTimeoutSeconds is required') unless jobTimeoutSeconds?
    throw new Error('RedisPooledJobManager: maxConnections is required') unless maxConnections?
    throw new Error('RedisPooledJobManager: namespace is required') unless namespace?
    throw new Error('RedisPooledJobManager: redisUri is required') unless redisUri?

    @jobManager = new PooledJobManager
      timeoutSeconds: jobTimeoutSeconds
      jobLogger: @_createJobLogger {jobLogIndexPrefix, jobLogQueue, jobLogRedisUri, jobLogSampleRate, jobLogType}
      pool: @_createPool {maxConnections, minConnections, idleTimeoutMillis, namespace, redisUri}

  createResponse: (responseQueue, request, callback) =>
    @jobManager.createResponse responseQueue, request, callback

  do: (requestQueue, responseQueue, request, callback) =>
    @jobManager.do requestQueue, responseQueue, request, callback

  _createJobLogger: ({jobLogIndexPrefix, jobLogQueue, jobLogRedisUri, jobLogSampleRate, jobLogType}) =>
    return new JobLogger
      client: redis.createClient jobLogRedisUri
      indexPrefix: jobLogIndexPrefix
      jobLogQueue: jobLogQueue
      sampleRate: jobLogSampleRate
      type: jobLogType

  _createPool: ({maxConnections, minConnections, idleTimeoutMillis, namespace, redisUri}) =>
    return new Pool
      max: maxConnections
      min: minConnections
      idleTimeoutMillis: idleTimeoutMillis
      returnToHead: true # sets connection pool to stack instead of queue behavior
      create: (callback) =>
        client = new RedisNS namespace, redis.createClient(redisUri)

        client.on 'end', ->
          client.hasError = new Error 'ended'

        client.on 'error', (error) ->
          client.hasError = error
          callback error if callback?

        client.once 'ready', ->
          callback null, client
          callback = null

      destroy: (client) =>
        if client.disconnect?
          client.quit()
          client.disconnect false
          return

        client.end true

      validate: (client) => !client.hasError?

module.exports = RedisPooledJobManager
