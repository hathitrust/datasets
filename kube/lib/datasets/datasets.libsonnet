(import 'ksonnet-util/kausal.libsonnet') +
(import './external_ip_service.libsonnet') +
(import './config.libsonnet') +
{
  local deploy = $.apps.v1.deployment,
  local deployTemplate = $.apps.v1.deployment.spec.template.spec,
  local container = $.core.v1.container,
  local env = container.envType,
  local port = $.core.v1.containerPort,
  local volumeMount = $.core.v1.volumeMount,
  local volume = $.core.v1.volume,

  local config = $._config.datasets,
  local images = $._images.datasets,

  local htprepVolume = { name: 'htprep', nfs: { server: 'nas-ictc.sc.umdl.umich.edu', path: '/ifs/htprep' } },
  local htprepRedisVolume = { name: 'htprep-redis', nfs: { server: 'nas-ictc.sc.umdl.umich.edu', path: '/ifs/htprep/datasets/redis' } },
  local sdrVolume = { name: 'sdr', nfs: { server: 'nas-ictc.sc.umdl.umich.edu', path: '/ifs/sdr' } },

  local htprepRedisMount = { mountPath: '/data',    name: 'htprep-redis' },
  local htprepMount = { mountPath: '/htprep',    name: 'htprep' },
  local sdrMount = { mountPath: '/sdr',       name: 'sdr' },

  local securityContext = deployTemplate.securityContext.withRunAsUser(config.runAs.runAsUser)
                        + deployTemplate.securityContext.withRunAsGroup(config.runAs.runAsGroup),

  datasets: {

    workers: {

      local app_config = config.workers.app_config,

      local configVolume =
        volume.fromSecret(name=app_config.secret,secretName=app_config.secret),

      local configMount =
        volumeMount.new(name=app_config.secret,
            mountPath=app_config.path + "/" + app_config.key)
        + volumeMount.withSubPath( subPath=app_config.key),

      deployment: deploy.new(
        name=config.workers.name,
        replicas=1,
        containers=[
          container.new(config.workers.name, images.workers)
          + container.withCommand(['bundle','exec','rake','resque:pool'])
          + container.withVolumeMounts([htprepMount, sdrMount, configMount])

        ]
      )
      + deployTemplate.withVolumes([htprepVolume, sdrVolume, configVolume])
      + securityContext

    },

    redis: {
      deployment: deploy.new(
        name=config.redis.name,
        replicas=1,
        containers=[
          container.new(config.redis.name, images.redis)
          + container.withCommand(['redis-server','--appendonly','yes'])
          + container.withVolumeMounts([htprepRedisMount])
        ]
      )
      + deployTemplate.withVolumes([htprepRedisVolume])
      + securityContext
    },
  },
}
