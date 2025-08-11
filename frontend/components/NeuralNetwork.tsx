"use client";

import React, { useEffect, useRef } from "react";

interface Node {
  x: number;
  y: number;
  vx: number;
  vy: number;
  connections: number[];
  activity: number;
}

interface Connection {
  from: number;
  to: number;
  strength: number;
  activity: number;
}

const NeuralNetwork: React.FC = () => {
  const svgRef = useRef<SVGSVGElement>(null);
  const nodesRef = useRef<Node[]>([]);
  const connectionsRef = useRef<Connection[]>([]);
  const animationRef = useRef<number>();

  useEffect(() => {
    if (!svgRef.current) return;

    const svg = svgRef.current;
    const width = 800;
    const height = 400;

    svg.setAttribute("width", width.toString());
    svg.setAttribute("height", height.toString());

    // 初始化节点
    const nodes: Node[] = [];
    const nodeCount = 20;

    for (let i = 0; i < nodeCount; i++) {
      nodes.push({
        x: Math.random() * (width - 100) + 50,
        y: Math.random() * (height - 100) + 50,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        connections: [],
        activity: Math.random(),
      });
    }

    // 创建连接
    const connections: Connection[] = [];
    nodes.forEach((node, i) => {
      const connectionCount = Math.floor(Math.random() * 4) + 1;
      for (let j = 0; j < connectionCount; j++) {
        const targetIndex = Math.floor(Math.random() * nodeCount);
        if (targetIndex !== i && !node.connections.includes(targetIndex)) {
          node.connections.push(targetIndex);
          connections.push({
            from: i,
            to: targetIndex,
            strength: Math.random(),
            activity: 0,
          });
        }
      }
    });

    nodesRef.current = nodes;
    connectionsRef.current = connections;

    // 创建SVG元素
    const createElements = () => {
      svg.innerHTML = `
        <defs>
          <radialGradient id="nodeGradient" cx="50%" cy="50%" r="50%">
            <stop offset="0%" style="stop-color:#60a5fa;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#3b82f6;stop-opacity:0.3" />
          </radialGradient>
          <linearGradient id="connectionGradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" style="stop-color:#8b5cf6;stop-opacity:0.8" />
            <stop offset="100%" style="stop-color:#ec4899;stop-opacity:0.8" />
          </linearGradient>
          <filter id="glow">
            <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
      `;

      // 创建连接线
      connections.forEach((connection, index) => {
        const line = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "line"
        );
        line.setAttribute("id", `connection-${index}`);
        line.setAttribute("stroke", "url(#connectionGradient)");
        line.setAttribute("stroke-width", "2");
        line.setAttribute("opacity", "0.3");
        line.setAttribute("filter", "url(#glow)");
        svg.appendChild(line);
      });

      // 创建节点
      nodes.forEach((node, index) => {
        const circle = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "circle"
        );
        circle.setAttribute("id", `node-${index}`);
        circle.setAttribute("r", "6");
        circle.setAttribute("fill", "url(#nodeGradient)");
        circle.setAttribute("filter", "url(#glow)");
        svg.appendChild(circle);

        // 创建节点脉冲环
        const pulseRing = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "circle"
        );
        pulseRing.setAttribute("id", `pulse-${index}`);
        pulseRing.setAttribute("r", "6");
        pulseRing.setAttribute("fill", "none");
        pulseRing.setAttribute("stroke", "#60a5fa");
        pulseRing.setAttribute("stroke-width", "2");
        pulseRing.setAttribute("opacity", "0");
        svg.appendChild(pulseRing);
      });
    };

    createElements();

    // 动画循环
    const animate = () => {
      const nodes = nodesRef.current;
      const connections = connectionsRef.current;

      // 更新节点位置
      nodes.forEach((node, index) => {
        node.x += node.vx;
        node.y += node.vy;

        // 边界反弹
        if (node.x <= 10 || node.x >= width - 10) node.vx *= -1;
        if (node.y <= 10 || node.y >= height - 10) node.vy *= -1;

        // 更新活动度
        node.activity += (Math.random() - 0.5) * 0.1;
        node.activity = Math.max(0, Math.min(1, node.activity));

        // 更新DOM元素
        const nodeElement = svg.querySelector(`#node-${index}`);
        const pulseElement = svg.querySelector(`#pulse-${index}`);

        if (nodeElement) {
          nodeElement.setAttribute("cx", node.x.toString());
          nodeElement.setAttribute("cy", node.y.toString());
          nodeElement.setAttribute(
            "opacity",
            (0.5 + node.activity * 0.5).toString()
          );
        }

        if (pulseElement && node.activity > 0.8) {
          pulseElement.setAttribute("cx", node.x.toString());
          pulseElement.setAttribute("cy", node.y.toString());
          // 创建脉冲动画
          const animation = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "animate"
          );
          animation.setAttribute("attributeName", "r");
          animation.setAttribute("values", "6;20;6");
          animation.setAttribute("dur", "1s");
          animation.setAttribute("repeatCount", "1");

          const opacityAnimation = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "animate"
          );
          opacityAnimation.setAttribute("attributeName", "opacity");
          opacityAnimation.setAttribute("values", "0.8;0;0.8");
          opacityAnimation.setAttribute("dur", "1s");
          opacityAnimation.setAttribute("repeatCount", "1");

          pulseElement.appendChild(animation);
          pulseElement.appendChild(opacityAnimation);
        }
      });

      // 更新连接
      connections.forEach((connection, index) => {
        const fromNode = nodes[connection.from];
        const toNode = nodes[connection.to];

        if (fromNode && toNode) {
          const connectionElement = svg.querySelector(`#connection-${index}`);
          if (connectionElement) {
            connectionElement.setAttribute("x1", fromNode.x.toString());
            connectionElement.setAttribute("y1", fromNode.y.toString());
            connectionElement.setAttribute("x2", toNode.x.toString());
            connectionElement.setAttribute("y2", toNode.y.toString());

            // 连接活动度基于两个节点的活动度
            const activity = (fromNode.activity + toNode.activity) / 2;
            connection.activity = activity;

            connectionElement.setAttribute(
              "opacity",
              (0.2 + activity * 0.6).toString()
            );
            connectionElement.setAttribute(
              "stroke-width",
              (1 + activity * 3).toString()
            );

            // 如果连接很活跃，创建数据传输动画
            if (activity > 0.7) {
              const dataPoint = document.createElementNS(
                "http://www.w3.org/2000/svg",
                "circle"
              );
              dataPoint.setAttribute("r", "3");
              dataPoint.setAttribute("fill", "#fbbf24");
              dataPoint.setAttribute("filter", "url(#glow)");

              const animateMotion = document.createElementNS(
                "http://www.w3.org/2000/svg",
                "animateMotion"
              );
              animateMotion.setAttribute("dur", "1.5s");
              animateMotion.setAttribute("repeatCount", "1");
              animateMotion.setAttribute(
                "path",
                `M${fromNode.x},${fromNode.y} L${toNode.x},${toNode.y}`
              );

              const fadeOut = document.createElementNS(
                "http://www.w3.org/2000/svg",
                "animate"
              );
              fadeOut.setAttribute("attributeName", "opacity");
              fadeOut.setAttribute("values", "1;1;0");
              fadeOut.setAttribute("dur", "1.5s");
              fadeOut.setAttribute("repeatCount", "1");

              dataPoint.appendChild(animateMotion);
              dataPoint.appendChild(fadeOut);
              svg.appendChild(dataPoint);

              // 1.5秒后移除数据点
              setTimeout(() => {
                if (svg.contains(dataPoint)) {
                  svg.removeChild(dataPoint);
                }
              }, 1500);
            }
          }
        }
      });

      animationRef.current = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, []);

  return (
    <div className="relative w-full h-96 bg-gray-900/50 rounded-2xl p-6 border border-gray-700 overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-blue-900/20 via-purple-900/20 to-pink-900/20" />
      <div className="relative z-10">
        <h3 className="text-xl font-semibold text-white mb-2">
          Neural Network
        </h3>
        <p className="text-gray-300 text-sm mb-4">
          Dynamic AI neural network simulation with real-time data flow
        </p>
        <svg
          ref={svgRef}
          className="w-full h-80 border border-gray-600 rounded-lg bg-gray-800/30"
          style={{ maxWidth: "800px", maxHeight: "400px" }}
        />
        <div className="mt-4 flex items-center space-x-4 text-xs text-gray-400">
          <div className="flex items-center space-x-1">
            <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse" />
            <span>Neurons</span>
          </div>
          <div className="flex items-center space-x-1">
            <div className="w-2 h-2 bg-purple-400 rounded-full" />
            <span>Connections</span>
          </div>
          <div className="flex items-center space-x-1">
            <div className="w-2 h-2 bg-yellow-400 rounded-full animate-bounce" />
            <span>Data Flow</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NeuralNetwork;
