async = require 'async'
RedisPooledJobManager = require '..'
RedisNS = require '@octoblu/redis-ns'
Redis = require 'ioredis'
JobManager = require 'meshblu-core-job-manager'

describe 'CreatePoolConnection', ->
  beforeEach 'redis', (done) ->
    @client = new RedisNS 'meshblu-test', new Redis 'redis://localhost:6379', dropBufferSupport: true
    @client.once 'ready', done
    @client.once 'error', done

  beforeEach 'jobManager', ->
    @jobManager = new JobManager {
      @client
      jobLogSampleRate: 0
      timeoutSeconds: 30
    }

  beforeEach 'sut', ->
    @sut = new RedisPooledJobManager {
      jobLogIndexPrefix: 'prefix'
      jobLogQueue: 'queue'
      jobLogRedisUri: 'redis://localhost:6379'
      jobLogSampleRate: 0
      jobLogType: 'type'
      jobTimeoutSeconds: 10
      maxConnections: 1
      minConnections: 1
      namespace: 'meshblu-test'
      redisUri: 'redis://localhost:6379'
    }

  describe '.do', ->
    beforeEach 'jobmanager', ->
      async.forever (callback) =>
        @jobManager.getRequest ['request'], (error, request) =>
          throw error if error?
          return callback() unless request?
          response =
            metadata:
              responseId: request.metadata.responseId
              code: 200

          @jobManager.createResponse 'response', response, callback

    beforeEach '.do', (done) ->
      request =
        metadata:
          jobType: 'GetStatus'

      @sut.do 'request', 'response', request, (error, @response) =>
        return done error if error?
        done()

    it 'should do the job', ->
      expect(@response).to.exist

  describe 'validateAsync', ->
    beforeEach (done) ->
      @sut.jobManager.pool.acquire (error, @client) =>
        return done error if error?
        @sut.jobManager.pool.release @client
        @sut.jobManager.pool.acquire (error, @client) =>
          done error

    it 'should get a client', ->
      expect(@client).to.exist
