RedisPooledJobManager = require '../'

describe 'RedisPooledJobManager', ->
  describe 'when instantiated without a jobLogIndexPrefix', ->
    it 'should throw an exception', ->
      expect(=> new RedisPooledJobManager).to.throw 'RedisPooledJobManager: jobLogIndexPrefix is required'

  describe 'when instantiated without a jobLogQueue', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'

      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: jobLogQueue is required'

  describe 'when instantiated without a jobLogRedisUri', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'

      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: jobLogRedisUri is required'

  describe 'when instantiated without a jobLogSampleRate', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'

      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: jobLogSampleRate is required'

  describe 'when instantiated without a jobLogType', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0

      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: jobLogType is required'

  describe 'when instantiated without a jobTimeoutSeconds', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0
        jobLogType: 'the-type'

      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: jobTimeoutSeconds is required'

  describe 'when instantiated without a maxConnections', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0
        jobLogType: 'the-type'
        jobTimeoutSeconds: 3
      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: maxConnections is required'

  describe 'when instantiated without a namespace', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0
        jobLogType: 'the-type'
        jobTimeoutSeconds: 3
        maxConnections: 1
      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: namespace is required'

  describe 'when instantiated without a redisUri', ->
    it 'should throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0
        jobLogType: 'the-type'
        jobTimeoutSeconds: 3
        maxConnections: 1
        namespace: 'ns'
      expect(=> new RedisPooledJobManager options).to.throw 'RedisPooledJobManager: redisUri is required'

  describe 'when instantiated with everything', ->
    it 'should not throw an exception', ->
      options =
        jobLogIndexPrefix: 'meshblu'
        jobLogQueue: 'this-queue'
        jobLogRedisUri: 'redis://localhost:6379'
        jobLogSampleRate: 0
        jobLogType: 'the-type'
        jobTimeoutSeconds: 3
        maxConnections: 1
        namespace: 'ns'
        redisUri: 'redis://localhost:6379'
      new RedisPooledJobManager options
      expect(=> new RedisPooledJobManager options).not.to.throw()
