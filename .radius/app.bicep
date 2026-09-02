extension radius

param azureOpenAiDeploymentName string

param azureOpenAiEndpoint string

@secure()
param azureOpenAiKey string

param azureOpenAiImageDeploymentName string

param environment string

@secure()
param rabbitMqPassword string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource aksStoreDemoApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aks-store-demo'
  properties: {
    environment: environment
  }
}

resource mongoDb 'Radius.Data/mongoDatabases@2025-08-01-preview' = {
  name: 'mongo'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'docker-compose.yml#L2'
    database: 'orderdb'
  }
}

resource rabbitMq 'Radius.Messaging/rabbitMQ@2025-08-01-preview' = {
  name: 'rabbitmq'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'docker-compose.yml#L16'
    password: rabbitMqPassword
    queue: 'orders'
    username: 'username'
  }
}

resource aiCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'ai-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'docker-compose.yml#L199'
    data: {
      apiKey: {
        value: azureOpenAiKey
      }
    }
  }
}

resource rabbitMqCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'rabbitmq-client-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'docker-compose.yml#L20'
    data: {
      password: {
        value: rabbitMqPassword
      }
    }
  }
}

resource registryCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: '.radius/app.bicep'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource aiServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'ai-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/ai-service/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/ai-service?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource makelineServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'makeline-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/makeline-service?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource orderServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/order-service?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource productServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/product-service?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource storeAdminImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-admin-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/store-admin?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource storeFrontImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-front-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/store-front?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource virtualCustomerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-customer-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/virtual-customer?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource virtualWorkerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-worker-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/Dockerfile#L1'
    tag: '4b32885837f6'
    build: {
      source: 'git::https://github.com/sk593/aks-store-demo.git//src/virtual-worker?ref=4b32885837f60c6ed6a20a556ad81d4db8da57df'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource aiServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'ai-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/ai-service/main.py#L17'
    containers: {
      aiService: {
        image: aiServiceImage.properties.imageReference
        env: {
          AZURE_OPENAI_API_KEY: {
            valueFrom: {
              secretKeyRef: {
                secretName: aiCredentials.name
                key: 'apiKey'
              }
            }
          }
          AZURE_OPENAI_API_VERSION: {
            value: '2024-12-01-preview'
          }
          AZURE_OPENAI_DEPLOYMENT_NAME: {
            value: azureOpenAiDeploymentName
          }
          AZURE_OPENAI_ENDPOINT: {
            value: azureOpenAiEndpoint
          }
          AZURE_OPENAI_IMAGE_API_VERSION: {
            value: '2025-04-01-preview'
          }
          AZURE_OPENAI_IMAGE_DEPLOYMENT_NAME: {
            value: azureOpenAiImageDeploymentName
          }
          AZURE_OPENAI_IMAGE_ENDPOINT: {
            value: azureOpenAiEndpoint
          }
          USE_AZURE_OPENAI: {
            value: 'True'
          }
        }
        ports: {
          web: {
            containerPort: 5001
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 5001
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 5001
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource makelineServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/main.go#L21'
    containers: {
      makelineService: {
        image: makelineServiceImage.properties.imageReference
        env: {
          ORDER_DB_COLLECTION_NAME: {
            value: 'orders'
          }
          ORDER_DB_NAME: {
            value: 'orderdb'
          }
          ORDER_DB_URI: {
            valueFrom: {
              secretKeyRef: {
                secretName: mongoDb.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitMqCredentials.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitMq.properties.host}:${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3001
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/liveness'
            port: 3001
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3001
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource orderServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/app.js#L6'
    containers: {
      orderService: {
        image: orderServiceImage.properties.imageReference
        env: {
          ORDER_QUEUE_HOSTNAME: {
            value: rabbitMq.properties.host
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitMqCredentials.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: '${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3000
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 3000
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3000
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource productServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'product-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/src/main.rs#L5'
    containers: {
      productService: {
        image: productServiceImage.properties.imageReference
        env: {
          AI_SERVICE_URL: {
            value: 'http://${aiServiceContainer.properties.hosts.aiService}:5001/'
          }
        }
        ports: {
          web: {
            containerPort: 3002
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 3002
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3002
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource storeAdminContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/nginx.conf#L1'
    containers: {
      storeAdmin: {
        image: storeAdminImage.properties.imageReference
        command: [
          '/bin/sh'
          '-c'
        ]
        args: [
          '''
          set -e
          sed -i "s|http://makeline-service:3001|$MAKELINE_SERVICE_URL|g; s|http://order-service:3000|$ORDER_SERVICE_URL|g; s|http://product-service:3002|$PRODUCT_SERVICE_URL|g" /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
          '''
        ]
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts.makelineService}:3001'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts.orderService}:3000'
          }
          PRODUCT_SERVICE_URL: {
            value: 'http://${productServiceContainer.properties.hosts.productService}:3002'
          }
        }
        ports: {
          web: {
            containerPort: 8081
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8081
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 8081
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource storeFrontContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/nginx.conf#L1'
    containers: {
      storeFront: {
        image: storeFrontImage.properties.imageReference
        command: [
          '/bin/sh'
          '-c'
        ]
        args: [
          '''
          set -e
          sed -i "s|http://order-service:3000|$ORDER_SERVICE_URL|g; s|http://product-service:3002|$PRODUCT_SERVICE_URL|g" /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
          '''
        ]
        env: {
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts.orderService}:3000'
          }
          PRODUCT_SERVICE_URL: {
            value: 'http://${productServiceContainer.properties.hosts.productService}:3002'
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
          }
          periodSeconds: 30
          timeoutSeconds: 10
        }
      }
    }
  }
}

resource virtualCustomerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-customer'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/src/main.rs#L7'
    containers: {
      virtualCustomer: {
        image: virtualCustomerImage.properties.imageReference
        env: {
          ORDERS_PER_HOUR: {
            value: '30'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts.orderService}:3000/'
          }
        }
      }
    }
  }
}

resource virtualWorkerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-worker'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/src/main.rs#L6'
    containers: {
      virtualWorker: {
        image: virtualWorkerImage.properties.imageReference
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts.makelineService}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '20'
          }
        }
      }
    }
  }
}
