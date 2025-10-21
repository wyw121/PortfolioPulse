import { useEffect, useState } from "react";
import { getProjects, type Project } from "../lib/api";

export function ProjectGrid() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getProjects();
      setProjects(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "获取项目失败");
      console.error("Failed to fetch projects:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProjects();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="text-gray-600">加载中...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <div className="text-red-600 mb-4">加载失败: {error}</div>
        <button
          onClick={fetchProjects}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          重试
        </button>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {projects.map((project) => (
        <div
          key={project.id}
          className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
        >
          <h3 className="text-xl font-semibold mb-2">
            <a
              href={project.html_url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:text-blue-800"
            >
              {project.name}
            </a>
          </h3>

          <p className="text-gray-600 mb-4 line-clamp-3">
            {project.description}
          </p>

          <div className="flex items-center justify-between text-sm text-gray-500">
            <span className="bg-gray-100 px-2 py-1 rounded">
              {project.language}
            </span>

            <div className="flex items-center space-x-4">
              <span>⭐ {project.stargazers_count}</span>
              <span>🍴 {project.forks_count}</span>
            </div>
          </div>

          {project.topics && project.topics.length > 0 && (
            <div className="flex flex-wrap gap-1 mt-3">
              {project.topics.slice(0, 3).map((topic: string) => (
                <span
                  key={topic}
                  className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded"
                >
                  {topic}
                </span>
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
