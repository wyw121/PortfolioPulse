#!/usr/bin/env node
/**
 * PortfolioPulse 文档同步状态检查脚本
 * 检查 .github/instructions/ 与 docs/ 之间的映射关系
 */

const fs = require("fs");
const path = require("path");

console.log("🔍 PortfolioPulse 文档同步检查");
console.log("======================================");

// 定义映射关系
const DOC_MAPPING = {
  ".github/instructions/project-overview.instructions.md":
    "docs/SYSTEM_ARCHITECTURE_ANALYSIS.md",
  ".github/instructions/frontend-development.instructions.md":
    "docs/TECHNICAL_IMPLEMENTATION_GUIDE.md",
  ".github/instructions/backend-development.instructions.md":
    "docs/TECHNICAL_IMPLEMENTATION_GUIDE.md",
  ".github/instructions/ui-style-system.instructions.md":
    "docs/PROJECT_STYLE_GUIDE.md",
  // 数据库设计已废弃,不再检查
  // ".github/instructions/database-design.instructions.md": "docs/BUSINESS_LOGIC_DESIGN.md",
  ".github/instructions/deployment-guide.instructions.md":
    "docs/BINARY_DEPLOYMENT_GUIDE.md",
  ".github/instructions/binary-deployment.instructions.md":
    "docs/MULTI_PROJECT_DEPLOYMENT.md",
};

// 获取项目根目录（假设脚本在 scripts/ 目录下）
const projectRoot = path.join(__dirname, "..");

// 检查文件存在性
console.log("📂 检查文件存在性...");
let missingFiles = 0;

for (const [instructionFile, docFile] of Object.entries(DOC_MAPPING)) {
  const instructionPath = path.join(projectRoot, instructionFile);
  const docPath = path.join(projectRoot, docFile);

  if (!fs.existsSync(instructionPath)) {
    console.log(`❌ 缺失AI指令: ${instructionFile}`);
    missingFiles++;
  }

  if (!fs.existsSync(docPath)) {
    console.log(`❌ 缺失技术文档: ${docFile}`);
    missingFiles++;
  }
}

if (missingFiles === 0) {
  console.log("✅ 所有文档文件都存在");
} else {
  console.log(`⚠️  发现 ${missingFiles} 个缺失文件`);
}

// 检查最后修改时间
console.log("");
console.log("⏰ 检查文档更新时间...");
let syncIssues = 0;

for (const [instructionFile, docFile] of Object.entries(DOC_MAPPING)) {
  const instructionPath = path.join(projectRoot, instructionFile);
  const docPath = path.join(projectRoot, docFile);

  if (fs.existsSync(instructionPath) && fs.existsSync(docPath)) {
    const instructionStat = fs.statSync(instructionPath);
    const docStat = fs.statSync(docPath);

    if (instructionStat.mtime > docStat.mtime) {
      console.log(`⚠️  可能需要同步: ${instructionFile} 比 ${docFile} 更新`);
      syncIssues++;
    }
  }
}

if (syncIssues === 0) {
  console.log("✅ 文档同步状态良好");
} else {
  console.log(`⚠️  发现 ${syncIssues} 个可能需要同步的文档`);
}

// 检查导航索引
console.log("");
console.log("🗂️ 检查导航索引...");
const indexFile = path.join(projectRoot, "docs/DOCUMENTATION_INDEX.md");
let missingInIndex = 0;

if (fs.existsSync(indexFile)) {
  console.log("✅ 文档索引存在: docs/DOCUMENTATION_INDEX.md");

  // 检查索引中是否包含所有指令文件
  const indexContent = fs.readFileSync(indexFile, "utf8");

  for (const instructionFile of Object.keys(DOC_MAPPING)) {
    const filename = path.basename(instructionFile);
    if (!indexContent.includes(filename)) {
      console.log(`⚠️  索引中缺失: ${filename}`);
      missingInIndex++;
    }
  }

  if (missingInIndex === 0) {
    console.log("✅ 索引文件完整");
  } else {
    console.log(`⚠️  索引需要更新 (${missingInIndex} 项缺失)`);
  }
} else {
  console.log("❌ 文档索引不存在: docs/DOCUMENTATION_INDEX.md");
  missingInIndex = 1;
}

// 检查 copilot-instructions.md 文件
const copilotInstructions = path.join(
  projectRoot,
  ".github/copilot-instructions.md"
);
if (!fs.existsSync(copilotInstructions)) {
  console.log("❌ 核心Copilot指令文件缺失: .github/copilot-instructions.md");
  missingFiles++;
}

// 总结报告
console.log("");
console.log("📊 检查总结");
console.log("======================================");
const totalIssues = missingFiles + syncIssues + missingInIndex;

if (totalIssues === 0) {
  console.log("🎉 文档架构完美！所有文档都已同步且完整。");
  process.exit(0);
} else {
  console.log(`⚠️  发现 ${totalIssues} 个问题，建议检查并更新相关文档。`);
  console.log("");
  console.log("💡 建议操作：");
  console.log("   1. 检查缺失的文件并创建");
  console.log("   2. 同步过期的文档内容");
  console.log("   3. 更新文档索引文件");
  console.log("");
  console.log("🔧 修复命令参考：");
  console.log("   npm run format               # 格式化代码");
  console.log("   cd scripts && npm run check  # 重新检查");
  process.exit(1);
}
