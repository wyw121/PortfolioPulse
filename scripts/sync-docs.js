#!/usr/bin/env node

/**
 * 文档同步工具 - 确保 .github 指令文件与项目状态保持同步
 * 
 * 功能:
 * 1. 检查项目结构变化
 * 2. 更新对应的指令文件
 * 3. 生成文档更新报告
 * 4. 验证指令文件的有效性
 */

const fs = require('fs');
const path = require('path');

class DocumentationSyncer {
    constructor() {
        this.projectRoot = process.cwd();
        this.githubDir = path.join(this.projectRoot, '.github');
        this.instructionsDir = path.join(this.githubDir, 'instructions');
        this.docsDir = path.join(this.projectRoot, 'docs');
        
        this.changes = [];
        this.errors = [];
    }

    /**
     * 检查项目结构
     */
    checkProjectStructure() {
        console.log('🔍 检查项目结构...');
        
        const frontendViteExists = fs.existsSync(path.join(this.projectRoot, 'frontend-vite'));
        const frontendExists = fs.existsSync(path.join(this.projectRoot, 'frontend'));
        const backendExists = fs.existsSync(path.join(this.projectRoot, 'backend'));
        
        if (frontendViteExists && !frontendExists) {
            this.changes.push('检测到前端重构: Next.js → Vite');
        }
        
        if (backendExists) {
            const staticDir = path.join(this.projectRoot, 'backend', 'static');
            if (fs.existsSync(staticDir)) {
                this.changes.push('检测到后端静态文件服务');
            }
        }
        
        return {
            frontendType: frontendViteExists ? 'vite' : (frontendExists ? 'nextjs' : 'none'),
            hasBackendStatic: fs.existsSync(path.join(this.projectRoot, 'backend', 'static')),
            hasUnifiedDeploy: fs.existsSync(path.join(this.projectRoot, 'build.ps1'))
        };
    }

    /**
     * 更新指令文件
     */
    updateInstructionFiles(structure) {
        console.log('📝 更新指令文件...');
        
        // 更新前端指令文件
        const frontendInstruction = path.join(this.instructionsDir, 'frontend-development.instructions.md');
        if (fs.existsSync(frontendInstruction)) {
            let content = fs.readFileSync(frontendInstruction, 'utf8');
            
            if (structure.frontendType === 'vite' && content.includes('Next.js')) {
                // 需要更新为 Vite 版本
                this.changes.push('前端指令文件需要更新为 Vite 版本');
            }
        }
        
        // 更新后端指令文件
        const backendInstruction = path.join(this.instructionsDir, 'backend-development.instructions.md');
        if (fs.existsSync(backendInstruction)) {
            let content = fs.readFileSync(backendInstruction, 'utf8');
            
            if (structure.hasBackendStatic && !content.includes('静态文件服务')) {
                this.changes.push('后端指令文件需要添加静态文件服务信息');
            }
        }
    }

    /**
     * 验证指令文件
     */
    validateInstructionFiles() {
        console.log('✅ 验证指令文件...');
        
        const requiredFiles = [
            'project-overview.instructions.md',
            'frontend-development.instructions.md',
            'backend-development.instructions.md',
            'ui-style-system.instructions.md',
            'database-design.instructions.md'
        ];
        
        for (const file of requiredFiles) {
            const filePath = path.join(this.instructionsDir, file);
            if (!fs.existsSync(filePath)) {
                this.errors.push(`缺少指令文件: ${file}`);
            } else {
                const content = fs.readFileSync(filePath, 'utf8');
                if (!content.includes('applyTo:')) {
                    this.errors.push(`指令文件 ${file} 缺少 applyTo 配置`);
                }
            }
        }
    }

    /**
     * 生成同步报告
     */
    generateSyncReport() {
        const timestamp = new Date().toISOString().split('T')[0];
        const reportPath = path.join(this.docsDir, `DOC_SYNC_REPORT_${timestamp}.md`);
        
        let report = `# 文档同步报告 - ${timestamp}\n\n`;
        report += `## 🔄 检测到的变化\n\n`;
        
        if (this.changes.length > 0) {
            this.changes.forEach(change => {
                report += `- ✅ ${change}\n`;
            });
        } else {
            report += `- 📌 没有检测到结构变化\n`;
        }
        
        report += `\n## ❌ 发现的问题\n\n`;
        
        if (this.errors.length > 0) {
            this.errors.forEach(error => {
                report += `- ⚠️ ${error}\n`;
            });
        } else {
            report += `- ✅ 所有指令文件都是最新的\n`;
        }
        
        report += `\n## 📋 建议操作\n\n`;
        report += `1. 检查上述问题并修复\n`;
        report += `2. 更新相关指令文件\n`;
        report += `3. 运行 \`git add .github/\` 提交更改\n`;
        
        fs.writeFileSync(reportPath, report);
        console.log(`📋 同步报告已生成: ${reportPath}`);
        
        return reportPath;
    }

    /**
     * 执行同步
     */
    async sync() {
        try {
            console.log('🚀 开始文档同步...');
            
            const structure = this.checkProjectStructure();
            this.updateInstructionFiles(structure);
            this.validateInstructionFiles();
            
            const reportPath = this.generateSyncReport();
            
            console.log('✅ 文档同步完成!');
            console.log(`📊 变化: ${this.changes.length} 项`);
            console.log(`⚠️ 问题: ${this.errors.length} 项`);
            
            if (this.errors.length > 0) {
                console.log('\n需要手动修复的问题:');
                this.errors.forEach(error => console.log(`  - ${error}`));
                process.exit(1);
            }
            
        } catch (error) {
            console.error('❌ 同步失败:', error.message);
            process.exit(1);
        }
    }
}

// 执行同步
if (require.main === module) {
    const syncer = new DocumentationSyncer();
    syncer.sync();
}

module.exports = DocumentationSyncer;
