#!/bin/bash
# 文档同步状态检查脚本
# 检查 .github/instructions/ 与 docs/ 之间的映射关系

echo "🔍 PortfolioPulse 文档同步检查"
echo "======================================"

# 定义映射关系
declare -A DOC_MAPPING
DOC_MAPPING[".github/instructions/project-overview.instructions.md"]="docs/SYSTEM_ARCHITECTURE_ANALYSIS.md"
DOC_MAPPING[".github/instructions/frontend-development.instructions.md"]="docs/TECHNICAL_IMPLEMENTATION_GUIDE.md"
DOC_MAPPING[".github/instructions/backend-development.instructions.md"]="docs/TECHNICAL_IMPLEMENTATION_GUIDE.md"
DOC_MAPPING[".github/instructions/ui-style-system.instructions.md"]="docs/PROJECT_STYLE_GUIDE.md"
DOC_MAPPING[".github/instructions/database-design.instructions.md"]="docs/BUSINESS_LOGIC_DESIGN.md"
DOC_MAPPING[".github/instructions/deployment-guide.instructions.md"]="docs/BINARY_DEPLOYMENT_GUIDE.md"
DOC_MAPPING[".github/instructions/binary-deployment.instructions.md"]="docs/MULTI_PROJECT_DEPLOYMENT.md"

# 检查文件存在性
echo "📂 检查文件存在性..."
missing_files=0

for instruction_file in "${!DOC_MAPPING[@]}"; do
    doc_file="${DOC_MAPPING[$instruction_file]}"

    if [[ ! -f "$instruction_file" ]]; then
        echo "❌ 缺失AI指令: $instruction_file"
        ((missing_files++))
    fi

    if [[ ! -f "$doc_file" ]]; then
        echo "❌ 缺失技术文档: $doc_file"
        ((missing_files++))
    fi
done

if [[ $missing_files -eq 0 ]]; then
    echo "✅ 所有文档文件都存在"
else
    echo "⚠️  发现 $missing_files 个缺失文件"
fi

# 检查最后修改时间
echo ""
echo "⏰ 检查文档更新时间..."
sync_issues=0

for instruction_file in "${!DOC_MAPPING[@]}"; do
    doc_file="${DOC_MAPPING[$instruction_file]}"

    if [[ -f "$instruction_file" && -f "$doc_file" ]]; then
        instruction_time=$(stat -f "%m" "$instruction_file" 2>/dev/null || stat -c "%Y" "$instruction_file" 2>/dev/null)
        doc_time=$(stat -f "%m" "$doc_file" 2>/dev/null || stat -c "%Y" "$doc_file" 2>/dev/null)

        if [[ $instruction_time -gt $doc_time ]]; then
            echo "⚠️  可能需要同步: $instruction_file 比 $doc_file 更新"
            ((sync_issues++))
        fi
    fi
done

if [[ $sync_issues -eq 0 ]]; then
    echo "✅ 文档同步状态良好"
else
    echo "⚠️  发现 $sync_issues 个可能需要同步的文档"
fi

# 检查导航索引
echo ""
echo "🗂️ 检查导航索引..."
index_file="docs/DOCUMENTATION_INDEX.md"

if [[ -f "$index_file" ]]; then
    echo "✅ 文档索引存在: $index_file"

    # 检查索引中是否包含所有指令文件
    missing_in_index=0
    for instruction_file in "${!DOC_MAPPING[@]}"; do
        filename=$(basename "$instruction_file")
        if ! grep -q "$filename" "$index_file"; then
            echo "⚠️  索引中缺失: $filename"
            ((missing_in_index++))
        fi
    done

    if [[ $missing_in_index -eq 0 ]]; then
        echo "✅ 索引文件完整"
    else
        echo "⚠️  索引需要更新 ($missing_in_index 项缺失)"
    fi
else
    echo "❌ 文档索引不存在: $index_file"
fi

# 总结报告
echo ""
echo "📊 检查总结"
echo "======================================"
total_issues=$((missing_files + sync_issues + missing_in_index))

if [[ $total_issues -eq 0 ]]; then
    echo "🎉 文档架构完美！所有文档都已同步且完整。"
    exit 0
else
    echo "⚠️  发现 $total_issues 个问题，建议检查并更新相关文档。"
    echo ""
    echo "💡 建议操作："
    echo "   1. 检查缺失的文件并创建"
    echo "   2. 同步过期的文档内容"
    echo "   3. 更新文档索引文件"
    exit 1
fi
