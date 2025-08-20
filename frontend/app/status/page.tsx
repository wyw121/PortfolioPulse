/**
 * 此页面已被移除
 */

export default function StatusPage() {
  return null;
}
      status: 'online',
      url: 'http://localhost:3001',
      lastCheck: new Date().toLocaleTimeString(),
    },
    {
      name: '后端API',
      status: 'checking',
      url: 'http://localhost:8000',
      lastCheck: '',
    },
  ]);

  const checkServiceStatus = async (service: ServiceStatus): Promise<ServiceStatus> => {
    const startTime = Date.now();

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${service.url}/api/health`, {
        method: 'GET',
        signal: controller.signal,
      });

      clearTimeout(timeoutId);
      const responseTime = Date.now() - startTime;

      return {
        ...service,
        status: response.ok ? 'online' : 'offline',
        lastCheck: new Date().toLocaleTimeString(),
        responseTime,
      };
    } catch {
      return {
        ...service,
        status: 'offline',
        lastCheck: new Date().toLocaleTimeString(),
        responseTime: Date.now() - startTime,
      };
    }
  };

  const checkAllServices = async () => {
    const updatedServices = await Promise.all(
      services.map(service => checkServiceStatus(service))
    );
    setServices(updatedServices);
  };

  useEffect(() => {
    const checkAllServicesOnMount = async () => {
      const updatedServices = await Promise.all(
        services.map(service => checkServiceStatus(service))
      );
      setServices(updatedServices);
    };

    checkAllServicesOnMount();
    const interval = setInterval(checkAllServicesOnMount, 10000); // 每10秒检查一次
    return () => clearInterval(interval);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'online': return 'text-green-500';
      case 'offline': return 'text-red-500';
      case 'checking': return 'text-yellow-500';
      default: return 'text-gray-500';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'online': return '🟢';
      case 'offline': return '🔴';
      case 'checking': return '🟡';
      default: return '⚪';
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 p-8">
      <div className="max-w-4xl mx-auto">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              🔧 系统状态监控
            </h1>
            <button
              onClick={checkAllServices}
              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
            >
              刷新状态
            </button>
          </div>

          <div className="space-y-4">
            {services.map((service, index) => (
              <div key={index} className="border border-gray-200 dark:border-gray-700 rounded-lg p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl">{getStatusIcon(service.status)}</span>
                    <div>
                      <h3 className="font-semibold text-gray-900 dark:text-white">
                        {service.name}
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {service.url}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className={`font-medium ${getStatusColor(service.status)}`}>
                      {service.status === 'online' ? '在线' :
                       service.status === 'offline' ? '离线' : '检查中...'}
                    </div>
                    {service.responseTime && (
                      <div className="text-sm text-gray-500">
                        {service.responseTime}ms
                      </div>
                    )}
                    <div className="text-xs text-gray-400">
                      最后检查: {service.lastCheck}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
            <h3 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
              📋 服务说明
            </h3>
            <ul className="text-sm text-blue-800 dark:text-blue-200 space-y-1">
              <li>• <strong>前端服务</strong>: Next.js 应用 (端口 3001)</li>
              <li>• <strong>后端API</strong>: Rust Axum 服务 (端口 8000)</li>
              <li>• 页面每10秒自动检查服务状态</li>
              <li>• 如果后端离线，项目页面会自动使用备用数据</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
