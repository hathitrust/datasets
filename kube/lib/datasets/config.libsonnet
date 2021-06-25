{
  _config+:: {
    datasets: {
      workers: {
        name: 'workers',
        app_config: {
          secret: 'config',
          # path to mount above configmap
          path: '/usr/src/app/config',
          # key from configmap to use for application config
          key: 'config.yml'
        }
      },
      redis: {
        name: 'redis',
        port: 6379,
      },
      runAs: {
        runAsUser: 140052,
        runAsGroup: 1089,
      }
    },
  },

  _images+:: {
    datasets: {
      workers: 'ghcr.io/hathitrust/datasets-unstable',
      redis: 'redis:6.2'
    },
  },
}
