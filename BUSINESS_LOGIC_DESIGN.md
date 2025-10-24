# PortfolioPulse 业务逻辑设计文档

## 🎯 简化版访问控制机制

### 1. 核心访问方案（仅两种认证方式）

#### 1.1 专属访问链接认证

```typescript
// 专属访问链接 - 融合最佳实践
interface FriendAccess {
  token: string;          // 唯一标识符
  nickname: string;       // 友好显示名称
  permissions: string[];  // 访问权限
  createdAt: Date;        // 创建时间
  lastAccess?: Date;      // 最后访问时间
  isActive: boolean;      // 是否激活
  trustScore: number;     // 信任分数（固定高分）
}

const generateFriendLink = (nickname: string) => {
  const token = `friend-${nickname}-${Date.now()}`;
  const friendAccess = {
    token,
    nickname,
    permissions: ['view_all', 'comment', 'interact'],
    createdAt: new Date(),
    isActive: true,
    trustScore: 85 // 具名朋友默认高信任度
  };

  // JWT会话管理
  const jwtToken = jwt.sign({
    sub: token,
    name: nickname,
    type: 'named_friend',
    permissions: friendAccess.permissions,
    exp: Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60) // 30天
  }, JWT_SECRET);

  return {
    url: `${SITE_URL}/welcome/${token}`,
    sessionToken: jwtToken
  };
};
```

#### 1.2 设备指纹识别认证

```typescript
// 设备指纹识别 - 集成信任评分
const generateDeviceFingerprint = () => {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  ctx.textBaseline = 'top';
  ctx.font = '14px Arial';
  ctx.fillText('Device fingerprint', 2, 2);

  const fingerprint = {
    userAgent: navigator.userAgent,
    language: navigator.language,
    platform: navigator.platform,
    screenResolution: `${screen.width}x${screen.height}`,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    canvas: canvas.toDataURL(),
    timestamp: Date.now()
  };

  return {
    id: btoa(JSON.stringify(fingerprint)).slice(0, 16),
    hash: crypto.createHash('sha256').update(JSON.stringify(fingerprint)).digest('hex').slice(0, 16)
  };
};

// 动态信任评分计算
const calculateDeviceTrustScore = (visitHistory: VisitRecord[]) => {
  let score = 30; // 设备用户基础分数

  // 访问频率正常性 (+25/-25)
  const avgInterval = calculateAverageInterval(visitHistory);
  if (avgInterval > 3600 && avgInterval < 86400 * 7) score += 25;
  else if (avgInterval < 60) score -= 25; // 疑似爬虫

  // 真实交互行为 (+30/-20)
  const interactionRate = calculateInteractionRate(visitHistory);
  if (interactionRate > 0.15) score += 30; // 高交互率
  else if (interactionRate === 0) score -= 20; // 无交互

  // 浏览时长合理性 (+15/-15)
  const avgReadingTime = calculateAverageReadingTime(visitHistory);
  if (avgReadingTime > 30 && avgReadingTime < 600) score += 15;
  else if (avgReadingTime < 5) score -= 15; // 过快浏览

  // 返回访问奖励 (+10)
  if (visitHistory.length > 3) score += 10;

  return Math.max(15, Math.min(100, score)); // 15-100分范围
};
```

### 2. 三级访问权限体系

#### 2.1 访问者类型定义（简化为三种）

```typescript
enum VisitorType {
  GUEST = 'guest',           // 匿名访客（无认证）
  DEVICE_USER = 'device',    // 设备用户（指纹认证，同等权限）
  NAMED_FRIEND = 'friend'    // 具名朋友（链接认证，同等权限）
}

// 注意：DEVICE_USER 和 NAMED_FRIEND 享有相同的内容访问权限
// 区别仅在于显示名称和社交体验
```

#### 2.2 内容分级展示策略

```typescript
// 基于访客类型的内容可见性
interface ContentAccess {
  projects: {
    canViewList: boolean;      // 能否查看项目列表
    canViewDetails: boolean;   // 能否查看详细信息
    canViewCode: boolean;      // 能否查看代码链接
    showMetrics: boolean;      // 是否显示统计数据
  };
  learning: {
    canViewTitles: boolean;    // 能否查看学习记录标题
    canViewContent: boolean;   // 能否查看完整内容
    canViewProgress: boolean;  // 能否查看学习进度
  };
  interaction: {
    canComment: boolean;       // 能否评论
    canLike: boolean;         // 能否点赞
    canShare: boolean;        // 能否分享
  };
}

const getContentAccess = (visitor: VisitorProfile): ContentAccess => {
  switch (visitor.type) {
    case VisitorType.GUEST:
      return {
        projects: {
          canViewList: true,      // 可看项目列表框架
          canViewDetails: false,  // 不能看详细信息
          canViewCode: true,      // 可看代码链接（项目本身开源）
          showMetrics: false      // 不显示统计
        },
        learning: {
          canViewTitles: true,    // 可看标题和概要
          canViewContent: false,  // 看不到具体内容
          canViewProgress: false  // 看不到进度
        },
        interaction: {
          canComment: false,      // 不能评论
          canLike: false,         // 不能点赞
          canShare: true          // 可以分享
        }
      };

    case VisitorType.DEVICE_USER:
    case VisitorType.NAMED_FRIEND:
      return {
        projects: {
          canViewList: true,
          canViewDetails: true,   // 完整项目详情
          canViewCode: true,
          showMetrics: true       // 显示完整统计
        },
        learning: {
          canViewTitles: true,
          canViewContent: true,   // 完整学习内容
          canViewProgress: true   // 学习进度
        },
        interaction: {
          canComment: true,       // 可以评论
          canLike: true,          // 可以点赞
          canShare: true          // 可以分享
        }
      };

    default:
      return getContentAccess({ type: VisitorType.GUEST } as VisitorProfile);
  }
};
```

### 3. 权限升级引导界面

```tsx
// 访客权限升级提示组件
const AccessUpgradePrompt = ({ contentType, requiredLevel }: {
  contentType: 'project_detail' | 'learning_content' | 'comment_section';
  requiredLevel: VisitorType;
}) => {
  const currentVisitor = useVisitorStore(state => state.visitor);

  if (currentVisitor.type !== VisitorType.GUEST) return null;

  const upgradeOptions = [
    {
      type: 'device',
      title: '🎭 启用匿名模式',
      description: '自动识别你的设备，获得完整浏览体验',
      benefits: ['查看所有内容', '参与评论互动', '个性化推荐'],
      action: 'enableDeviceMode',
      isQuick: true
    },
    {
      type: 'friend',
      title: '👤 使用专属链接',
      description: '如果你有专属访问链接，获得具名身份',
      benefits: ['朋友知道是你', '完整访问权限', '个性化头像'],
      action: 'enterFriendCode',
      isQuick: false
    }
  ];

  return (
    <div className="access-upgrade-prompt">
      <div className="blocked-content-preview">
        <div className="content-frame">
          {/* 显示内容框架但模糊处理 */}
          <div className="blurred-content">
            <div className="placeholder-lines">
              <div className="line"></div>
              <div className="line short"></div>
              <div className="line"></div>
              <div className="line long"></div>
            </div>
          </div>

          <div className="unlock-overlay">
            <div className="unlock-message">
              <Lock size={24} />
              <h4>解锁完整内容</h4>
              <p>选择一种方式来查看{getContentTypeName(contentType)}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="upgrade-options">
        {upgradeOptions.map(option => (
          <div key={option.type} className="upgrade-option">
            <div className="option-header">
              <h5>{option.title}</h5>
              {option.isQuick && <span className="quick-badge">快速</span>}
            </div>
            <p className="option-description">{option.description}</p>
            <ul className="option-benefits">
              {option.benefits.map(benefit => (
                <li key={benefit}>✓ {benefit}</li>
              ))}
            </ul>
            <button
              onClick={() => handleUpgrade(option.action)}
              className="upgrade-btn"
            >
              {option.isQuick ? '一键启用' : '输入链接'}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
```

### 4. 反爬虫与访问控制策略

#### 4.1 多层防护机制

```typescript
// 智能反爬虫系统
class AntiCrawlerSystem {
  private suspiciousActivities = new Map<string, SuspiciousActivity>();

  // 请求频率限制
  async checkRateLimit(identifier: string, endpoint: string): Promise<boolean> {
    const key = `${identifier}:${endpoint}`;
    const requests = await this.redis.get(`rate_limit:${key}`);

    if (!requests) {
      await this.redis.setex(`rate_limit:${key}`, 60, '1');
      return true;
    }

    const count = parseInt(requests);
    if (count > this.getRateLimit(endpoint)) {
      await this.flagSuspiciousActivity(identifier, 'rate_limit_exceeded');
      return false;
    }

    await this.redis.incr(`rate_limit:${key}`);
    return true;
  }

  // 行为模式检测
  async detectBotBehavior(visitor: VisitorProfile, actions: InteractionEvent[]): Promise<boolean> {
    const patterns = {
      // 疑似机器人行为
      noJavaScript: !actions.some(a => a.type === 'client_script'),
      tooFastClicks: this.detectRapidClicking(actions),
      noScrolling: !actions.some(a => a.type === 'scroll'),
      linearPath: this.detectLinearNavigation(actions),
      noHover: !actions.some(a => a.type === 'hover'),
      sameUserAgent: await this.checkRepeatedUserAgent(visitor.metadata.deviceFingerprint)
    };

    const botScore = Object.values(patterns).filter(Boolean).length;
    const isBot = botScore >= 3;

    if (isBot) {
      await this.flagSuspiciousActivity(visitor.id, 'bot_behavior', { patterns, score: botScore });
    }

    return isBot;
  }

  // 内容保护
  async protectSensitiveContent(visitor: VisitorProfile): Promise<ContentAccess> {
    const trustScore = await this.calculateTrustScore(visitor.id);

    return {
      canViewProjects: trustScore > 30,
      canViewLearningRecords: trustScore > 20,
      canComment: trustScore > 50 && visitor.type !== VisitorType.ANONYMOUS_GUEST,
      canAccessDetailedInfo: trustScore > 70,
      contentLevel: this.getContentLevel(trustScore)
    };
  }
}
```

#### 4.2 渐进式内容展示

```typescript
// 基于信任度的内容分级
enum ContentLevel {
  PUBLIC = 'public',           // 公开内容
  TRUSTED = 'trusted',         // 可信访客内容
  FRIEND = 'friend',           // 朋友专享内容
  PRIVATE = 'private'          // 私人内容
}

const ContentFilter = {
  filterByTrustLevel: (content: any[], visitor: VisitorProfile) => {
    const access = visitor.metadata.contentAccess;

    return content.filter(item => {
      switch (item.level) {
        case ContentLevel.PUBLIC:
          return true;
        case ContentLevel.TRUSTED:
          return access.canViewProjects;
        case ContentLevel.FRIEND:
          return visitor.type === VisitorType.NAMED_FRIEND;
        case ContentLevel.PRIVATE:
          return visitor.type === VisitorType.OWNER;
        default:
          return false;
      }
    });
  }
};
```

### 5. 智能角色切换系统

#### 5.1 访客引导界面设计

```tsx
// 访客身份选择组件
const VisitorIdentitySelector = () => {
  const [currentVisitor, setCurrentVisitor] = useVisitorStore(state => state.visitor);
  const [showSelector, setShowSelector] = useState(false);

  const identityOptions = [
    {
      type: VisitorType.NAMED_FRIEND,
      icon: '👤',
      title: '使用专属链接',
      description: '如果你有专属访问链接，可以获得完整体验',
      action: 'enterFriendCode',
      benefits: ['评论互动', '查看详细内容', '个性化体验']
    },
    {
      type: VisitorType.DEVICE_USER,
      icon: '🎭',
      title: '匿名探索',
      description: '保持神秘身份浏览内容',
      action: 'continueAsAnonymous',
      benefits: ['快速浏览', '保护隐私', '无需额外步骤']
    },
    {
      type: VisitorType.ANONYMOUS_GUEST,
      icon: '👁️',
      title: '访客浏览',
      description: '查看基础公开内容',
      action: 'browseAsGuest',
      benefits: ['查看项目列表', '了解基本信息']
    }
  ];

  return (
    <div className="identity-selector">
      {/* 当前身份状态显示 */}
      <div className="current-identity">
        <div className="identity-badge">
          <span className="icon">{getVisitorIcon(currentVisitor.type)}</span>
          <span className="name">{currentVisitor.displayName}</span>
          <button
            className="change-btn"
            onClick={() => setShowSelector(true)}
          >
            切换身份
          </button>
        </div>
      </div>

      {/* 身份选择弹窗 */}
      {showSelector && (
        <Modal onClose={() => setShowSelector(false)}>
          <div className="identity-options">
            <h3>选择访问方式</h3>
            <p className="hint">你可以随时切换不同的访问方式来获得不同的体验</p>

            {identityOptions.map(option => (
              <div
                key={option.type}
                className={`identity-option ${currentVisitor.type === option.type ? 'active' : ''}`}
                onClick={() => handleIdentitySwitch(option.type)}
              >
                <div className="option-header">
                  <span className="icon">{option.icon}</span>
                  <h4>{option.title}</h4>
                </div>
                <p className="description">{option.description}</p>
                <ul className="benefits">
                  {option.benefits.map(benefit => (
                    <li key={benefit}>✓ {benefit}</li>
                  ))}
                </ul>
                {currentVisitor.type === option.type && (
                  <div className="current-badge">当前方式</div>
                )}
              </div>
            ))}
          </div>
        </Modal>
      )}
    </div>
  );
};
```

#### 5.2 智能引导提示系统

```tsx
// 智能提示组件
const SmartGuidance = () => {
  const visitor = useVisitorStore(state => state.visitor);
  const [dismissedTips, setDismissedTips] = useLocalStorage('dismissed_tips', []);

  const getRelevantTips = () => {
    const tips = [];

    // 匿名用户提示
    if (visitor.type === VisitorType.DEVICE_USER && !dismissedTips.includes('friend_link_tip')) {
      tips.push({
        id: 'friend_link_tip',
        type: 'info',
        title: '🔗 获得更好体验',
        content: '如果你有专属访问链接，可以切换身份来评论和查看更多内容',
        action: {
          text: '输入专属链接',
          handler: () => showFriendCodeInput()
        }
      });
    }

    // 访客用户提示
    if (visitor.type === VisitorType.ANONYMOUS_GUEST && !dismissedTips.includes('device_tip')) {
      tips.push({
        id: 'device_tip',
        type: 'upgrade',
        title: '🎭 匿名模式',
        content: '切换到匿名模式可以获得更个性化的浏览体验',
        action: {
          text: '启用匿名模式',
          handler: () => switchToDeviceMode()
        }
      });
    }

    // 朋友用户提示
    if (visitor.type === VisitorType.NAMED_FRIEND && visitor.metadata.visitCount === 1) {
      tips.push({
        id: 'welcome_friend',
        type: 'welcome',
        title: `🎉 欢迎 ${visitor.displayName}`,
        content: '你现在可以评论、查看详细内容，也可以随时切换到匿名模式保护隐私',
        action: {
          text: '开始探索',
          handler: () => dismissTip('welcome_friend')
        }
      });
    }

    return tips.filter(tip => !dismissedTips.includes(tip.id));
  };

  return (
    <div className="smart-guidance">
      {getRelevantTips().map(tip => (
        <TipCard key={tip.id} tip={tip} onDismiss={dismissTip} />
      ))}
    </div>
  );
};
```

#### 5.3 身份切换逻辑

```typescript
// 身份切换管理器
class IdentityManager {
  // 从匿名切换到具名
  async switchToNamedFriend(accessCode: string): Promise<SwitchResult> {
    const friendAccess = await this.validateFriendAccess(accessCode);

    if (!friendAccess) {
      return { success: false, message: '访问码无效或已过期' };
    }

    // 保留匿名用户的历史行为数据
    const currentVisitor = await this.getCurrentVisitor();
    const mergedHistory = await this.mergeVisitorHistory(currentVisitor.id, friendAccess.token);

    // 创建新的具名用户会话
    const namedVisitor: VisitorProfile = {
      id: friendAccess.token,
      type: VisitorType.NAMED_FRIEND,
      displayName: friendAccess.nickname,
      permissions: friendAccess.permissions,
      metadata: {
        ...currentVisitor.metadata,
        accessToken: friendAccess.token,
        previousAnonymousId: currentVisitor.id,
        mergedHistory
      }
    };

    await this.setCurrentVisitor(namedVisitor);

    return {
      success: true,
      message: `欢迎回来，${friendAccess.nickname}！`,
      visitor: namedVisitor
    };
  }

  // 从具名切换到匿名
  async switchToAnonymous(): Promise<SwitchResult> {
    const currentVisitor = await this.getCurrentVisitor();

    if (currentVisitor.type !== VisitorType.NAMED_FRIEND) {
      return { success: false, message: '当前不是具名用户' };
    }

    // 生成新的匿名身份，但保留部分历史
    const anonymousVisitor: VisitorProfile = {
      id: generateAnonymousId(),
      type: VisitorType.DEVICE_USER,
      displayName: `神秘访客 #${Math.random().toString(36).slice(-4)}`,
      permissions: ['view_public'],
      metadata: {
        deviceFingerprint: currentVisitor.metadata.deviceFingerprint,
        firstVisit: currentVisitor.metadata.firstVisit,
        lastVisit: new Date(),
        visitCount: currentVisitor.metadata.visitCount,
        previousNamedId: currentVisitor.id,
        canSwitchBack: true // 标记可以切换回具名身份
      }
    };

    await this.setCurrentVisitor(anonymousVisitor);

    return {
      success: true,
      message: '已切换到匿名模式',
      visitor: anonymousVisitor
    };
  }

  // 切换回之前的身份
  async switchBack(): Promise<SwitchResult> {
    const currentVisitor = await this.getCurrentVisitor();
    const previousId = currentVisitor.metadata.previousNamedId || currentVisitor.metadata.previousAnonymousId;

    if (!previousId) {
      return { success: false, message: '没有可切换的历史身份' };
    }

    const previousVisitor = await this.getVisitorById(previousId);
    if (!previousVisitor) {
      return { success: false, message: '历史身份已失效' };
    }

    await this.setCurrentVisitor(previousVisitor);

    return {
      success: true,
      message: `已切换回 ${previousVisitor.displayName}`,
      visitor: previousVisitor
    };
  }
}
```

#### 方案A：专属访问链接 (推荐)

```typescript
// 生成专属访问链接
// 格式：https://yourdomain.com/welcome/[UNIQUE_TOKEN]
// 示例：https://yourdomain.com/welcome/friend-xiaoming-2025
//      https://yourdomain.com/welcome/colleague-lisi-dev

interface FriendAccess {
  token: string;          // 唯一标识符
  nickname: string;       // 友好显示名称
  permissions: string[];  // 访问权限
  createdAt: Date;        // 创建时间
  lastAccess?: Date;      // 最后访问时间
  isActive: boolean;      // 是否激活
}

// 后台管理生成链接
const generateFriendLink = (nickname: string, permissions: string[]) => {
  const token = `friend-${nickname}-${Date.now()}`;
  const friendAccess = {
    token,
    nickname,
    permissions,
    createdAt: new Date(),
    isActive: true
  };

  // 保存到数据库
  await saveFriendAccess(friendAccess);

  return `${SITE_URL}/welcome/${token}`;
};
```

#### 方案B：设备指纹识别 (辅助方案)

```typescript
// 设备指纹生成
const generateDeviceFingerprint = () => {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  ctx.textBaseline = 'top';
  ctx.font = '14px Arial';
  ctx.fillText('Device fingerprint', 2, 2);

  const fingerprint = {
    userAgent: navigator.userAgent,
    language: navigator.language,
    platform: navigator.platform,
    screenResolution: `${screen.width}x${screen.height}`,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    canvas: canvas.toDataURL(),
    timestamp: Date.now()
  };

  return btoa(JSON.stringify(fingerprint)).slice(0, 16);
};

// 访问验证
const validateAccess = async (token: string, deviceInfo: any) => {
  const friendAccess = await getFriendAccess(token);
  if (!friendAccess || !friendAccess.isActive) {
    return { valid: false, message: '链接已失效' };
  }

  // 记录访问
  await recordAccess(token, deviceInfo);

  return {
    valid: true,
    user: friendAccess,
    permissions: friendAccess.permissions
  };
};
```

### 6. 用户身份识别策略

#### 6.1 访问者类型定义

```typescript
enum VisitorType {
  OWNER = 'owner',           // 网站主人
  NAMED_FRIEND = 'friend',   // 具名朋友
  ANONYMOUS_GUEST = 'guest', // 匿名访客
  DEVICE_USER = 'device'     // 设备用户
}

interface VisitorProfile {
  id: string;
  type: VisitorType;
  displayName: string;       // 显示名称
  avatar?: string;           // 头像
  permissions: Permission[];
  metadata: {
    deviceFingerprint?: string;
    firstVisit: Date;
    lastVisit: Date;
    visitCount: number;
    accessToken?: string;
  };
}
```

#### 6.2 智能身份识别

```typescript
const identifyVisitor = async (request: Request): Promise<VisitorProfile> => {
  // 1. 检查专属访问链接
  const pathToken = request.params.token;
  if (pathToken && pathToken.startsWith('friend-')) {
    const friendAccess = await getFriendAccess(pathToken);
    if (friendAccess?.isActive) {
      return {
        id: friendAccess.token,
        type: VisitorType.NAMED_FRIEND,
        displayName: friendAccess.nickname,
        permissions: friendAccess.permissions,
        metadata: {
          accessToken: pathToken,
          firstVisit: friendAccess.createdAt,
          lastVisit: new Date(),
          visitCount: friendAccess.visitCount || 1
        }
      };
    }
  }

  // 2. 检查设备指纹
  const deviceFingerprint = generateDeviceFingerprint(request);
  const existingDevice = await getDeviceUser(deviceFingerprint);

  if (existingDevice) {
    return {
      id: existingDevice.id,
      type: VisitorType.DEVICE_USER,
      displayName: `访客 ${existingDevice.id.slice(-4)}`,
      permissions: ['view_public'],
      metadata: {
        deviceFingerprint,
        firstVisit: existingDevice.createdAt,
        lastVisit: new Date(),
        visitCount: existingDevice.visitCount + 1
      }
    };
  }

  // 3. 创建新的匿名访客
  const newGuest = await createGuestUser(deviceFingerprint);
  return newGuest;
};
```

### 7. 优化版评论与内容系统

#### 7.1 简化评论机制（无审核版）

```typescript
// 基于反爬虫信任度的评论系统
interface OptimizedCommentSystem {
  canComment: (visitor: VisitorProfile) => boolean;
  getDisplayInfo: (visitor: VisitorProfile) => CommentDisplayInfo;
  shouldAutoApprove: (visitor: VisitorProfile, trustScore: number) => boolean;
}

const optimizedCommentSystem: OptimizedCommentSystem = {
  // 评论权限 - 基于信任度而非用户类型
  canComment: (visitor) => {
    const trustScore = visitor.metadata.trustScore || 0;

    // 信任分数大于30分即可评论（过滤掉明显的爬虫）
    return trustScore >= 30 && visitor.type !== VisitorType.ANONYMOUS_GUEST;
  },

  // 显示信息 - 保持神秘感和个性化
  getDisplayInfo: (visitor) => {
    switch (visitor.type) {
      case VisitorType.OWNER:
        return {
          name: '博主',
          avatar: '👑',
          badge: 'owner',
          color: 'blue'
        };
      case VisitorType.NAMED_FRIEND:
        return {
          name: visitor.displayName,
          avatar: visitor.displayName[0].toUpperCase(),
          badge: 'friend',
          color: 'green'
        };
      case VisitorType.DEVICE_USER:
        return {
          name: `神秘访客 #${visitor.id.slice(-4)}`,
          avatar: '🎭',
          badge: 'mystery',
          color: 'purple'
        };
      default:
        return {
          name: '匿名访客',
          avatar: '👤',
          badge: 'guest',
          color: 'gray'
        };
    }
  },

  // 自动审核 - 基于信任度无需人工审核
  shouldAutoApprove: (visitor, trustScore) => {
    // 具名朋友直接通过
    if (visitor.type === VisitorType.NAMED_FRIEND) return true;

    // 高信任度设备用户直接通过
    if (visitor.type === VisitorType.DEVICE_USER && trustScore >= 70) return true;

    // 其他情况需要简单的内容检查（而非人工审核）
    return false;
  }
};
```

#### 7.2 内容过滤与保护

```typescript
// 智能内容过滤器
class ContentFilter {
  // 基于关键词和模式的自动过滤
  static autoFilter(content: string, visitor: VisitorProfile): FilterResult {
    const suspiciousPatterns = [
      /https?:\/\/[^\s]+/g,           // 外链检测
      /<[^>]+>/g,                     // HTML标签检测
      /(.)\1{10,}/g,                  // 重复字符检测
      /^.{500,}$/,                    // 超长内容检测
    ];

    let riskScore = 0;
    const flags = [];

    suspiciousPatterns.forEach((pattern, index) => {
      if (pattern.test(content)) {
        riskScore += [10, 15, 20, 5][index];
        flags.push(['external_link', 'html_injection', 'spam_pattern', 'long_content'][index]);
      }
    });

    // 基于访客信任度调整风险阈值
    const trustScore = visitor.metadata.trustScore || 0;
    const riskThreshold = trustScore > 70 ? 50 : trustScore > 50 ? 30 : 20;

    return {
      approved: riskScore < riskThreshold,
      riskScore,
      flags,
      filteredContent: this.sanitizeContent(content)
    };
  }

  static sanitizeContent(content: string): string {
    return content
      .replace(/<[^>]+>/g, '')          // 移除HTML标签
      .replace(/https?:\/\/[^\s]+/g, '[链接]') // 替换外链
      .trim();
  }
}
```

#### 7.3 学习记录开放策略

```typescript
// 学习记录访问控制 - 开放式设计
interface LearningRecordAccess {
  canView: (visitor: VisitorProfile, record: LearningRecord) => boolean;
  getVisibleFields: (visitor: VisitorProfile) => string[];
  canInteract: (visitor: VisitorProfile) => InteractionPermissions;
}

const learningRecordAccess: LearningRecordAccess = {
  // 查看权限 - 基本开放，仅过滤明显爬虫
  canView: (visitor, record) => {
    const trustScore = visitor.metadata.trustScore || 0;

    // 基础内容对所有真实访客开放
    if (record.visibility === 'public') return trustScore >= 20;

    // 详细内容需要更高信任度
    if (record.visibility === 'detailed') return trustScore >= 50;

    // 私人记录仅主人可见
    if (record.visibility === 'private') return visitor.type === VisitorType.OWNER;

    return true;
  },

  // 可见字段 - 根据访客类型动态调整
  getVisibleFields: (visitor) => {
    const baseFields = ['title', 'summary', 'tags', 'createdAt'];

    if (visitor.metadata.trustScore >= 50) {
      return [...baseFields, 'content', 'progress', 'resources'];
    }

    if (visitor.type === VisitorType.NAMED_FRIEND) {
      return [...baseFields, 'content', 'progress'];
    }

    return baseFields;
  },

  // 交互权限 - 点赞、收藏等
  canInteract: (visitor) => {
    const trustScore = visitor.metadata.trustScore || 0;

    return {
      canLike: trustScore >= 30,
      canBookmark: visitor.type !== VisitorType.ANONYMOUS_GUEST,
      canShare: trustScore >= 40,
      canComment: trustScore >= 30 && visitor.type !== VisitorType.ANONYMOUS_GUEST
    };
  }
};
```

#### 7.4 用户体验优化界面

```tsx
// 动态权限提示组件
const PermissionHint = ({ requiredAction, visitor }: PermissionHintProps) => {
  const [showHint, setShowHint] = useState(false);

  const getHintContent = () => {
    const trustScore = visitor.metadata.trustScore || 0;

    switch (requiredAction) {
      case 'comment':
        if (visitor.type === VisitorType.ANONYMOUS_GUEST) {
          return {
            icon: '💬',
            title: '想要评论？',
            content: '切换到匿名模式或使用专属链接即可参与讨论',
            actions: [
              { text: '匿名模式', action: 'switchToDevice' },
              { text: '输入链接', action: 'enterFriendCode' }
            ]
          };
        }

        if (trustScore < 30) {
          return {
            icon: '🤖',
            title: '评论暂时受限',
            content: '系统检测到异常行为，请正常浏览一段时间后重试',
            actions: [{ text: '了解详情', action: 'showTrustInfo' }]
          };
        }
        break;

      case 'detailed_content':
        return {
          icon: '🔍',
          title: '查看详细内容',
          content: '使用专属链接或提高信任度可查看更多详细信息',
          actions: [
            { text: '输入专属链接', action: 'enterFriendCode' }
          ]
        };
    }

    return null;
  };

  const hintContent = getHintContent();

  if (!hintContent) return null;

  return (
    <div className="permission-hint">
      <Tooltip content={
        <div className="hint-tooltip">
          <div className="hint-header">
            <span className="icon">{hintContent.icon}</span>
            <h4>{hintContent.title}</h4>
          </div>
          <p>{hintContent.content}</p>
          <div className="hint-actions">
            {hintContent.actions.map(action => (
              <button
                key={action.action}
                onClick={() => handleAction(action.action)}
                className="hint-action-btn"
              >
                {action.text}
              </button>
            ))}
          </div>
        </div>
      }>
        <button className="permission-hint-trigger">
          <Lock size={16} />
          <span>受限内容</span>
        </button>
      </Tooltip>
    </div>
  );
};
```

### 8. 角色切换用户引导流程

#### 8.1 首次访问引导

```tsx
// 新用户欢迎流程
const WelcomeFlow = () => {
  const [step, setStep] = useState(0);
  const [userChoice, setUserChoice] = useState(null);

  const welcomeSteps = [
    {
      title: '欢迎来到我的个人空间 👋',
      content: '这里记录了我的项目动态和学习历程',
      image: '/images/welcome-hero.png'
    },
    {
      title: '选择你的探索方式',
      content: '你可以随时切换不同的访问方式',
      component: <IdentitySelector onSelect={setUserChoice} />
    },
    {
      title: '开始探索',
      content: '根据你的选择，为你推荐最适合的内容',
      component: <PersonalizedRecommendation userChoice={userChoice} />
    }
  ];

  return (
    <Modal className="welcome-flow">
      <div className="flow-container">
        <div className="progress-bar">
          <div
            className="progress-fill"
            style={{ width: `${((step + 1) / welcomeSteps.length) * 100}%` }}
          />
        </div>

        <div className="step-content">
          <h2>{welcomeSteps[step].title}</h2>
          <p>{welcomeSteps[step].content}</p>

          {welcomeSteps[step].image && (
            <img src={welcomeSteps[step].image} alt="Welcome" />
          )}

          {welcomeSteps[step].component}
        </div>

        <div className="flow-actions">
          {step > 0 && (
            <button onClick={() => setStep(step - 1)}>上一步</button>
          )}

          {step < welcomeSteps.length - 1 ? (
            <button
              onClick={() => setStep(step + 1)}
              disabled={step === 1 && !userChoice}
            >
              下一步
            </button>
          ) : (
            <button onClick={() => completeWelcome()}>
              开始探索
            </button>
          )}

          <button className="skip-btn" onClick={() => skipWelcome()}>
            跳过引导
          </button>
        </div>
      </div>
    </Modal>
  );
};
```

#### 8.2 角色切换完整流程设计

```tsx
// 角色切换管理组件
const RoleSwitchManager = () => {
  const [currentVisitor, setCurrentVisitor] = useVisitorStore();
  const [switchMode, setSwitchMode] = useState<'expand' | 'contract' | null>(null);

  // 角色切换场景映射
  const switchScenarios = {
    // 匿名 → 具名 (扩展权限)
    anonymous_to_named: {
      type: 'expand',
      title: '🔓 获得完整体验',
      description: '输入专属链接，解锁评论和详细内容',
      benefits: ['参与讨论评论', '查看完整内容', '个性化显示', '历史记录保存'],
      component: <FriendCodeInput onSuccess={handleNamedUpgrade} />
    },

    // 设备用户 → 具名 (身份确认)
    device_to_named: {
      type: 'expand',
      title: '👤 显示真实身份',
      description: '使用专属链接，让大家知道你是谁',
      benefits: ['朋友知道是你', '评论免审核', '个性化头像', '专属标识'],
      component: <FriendCodeInput onSuccess={handleNamedUpgrade} />
    },

    // 具名 → 匿名 (隐私保护)
    named_to_anonymous: {
      type: 'contract',
      title: '🎭 切换匿名模式',
      description: '保护隐私，以神秘访客身份浏览',
      benefits: ['保护隐私', '神秘感互动', '减少社交压力', '随时切换回来'],
      component: <AnonymousConfirm onConfirm={handleAnonymousSwitch} />
    },

    // 访客 → 设备用户 (基础升级)
    guest_to_device: {
      type: 'expand',
      title: '🎯 启用个性化',
      description: '获得更好的浏览体验',
      benefits: ['记住浏览历史', '个性化推荐', '互动功能', '稳定身份'],
      component: <DeviceModeConfirm onConfirm={handleDeviceUpgrade} />
    }
  };

  return (
    <div className="role-switch-manager">
      {/* 角色切换界面实现 */}
    </div>
  );
};
```

#### 8.3 专属链接输入优化

```tsx
// 多格式支持的专属链接输入
const FriendCodeInput = ({ onSuccess }) => {
  const [code, setCode] = useState('');
  const [isValidating, setIsValidating] = useState(false);

  const extractAccessCode = (input: string): string => {
    // 支持完整URL: https://site.com/welcome/friend-xxx-xxx
    const urlMatch = input.match(/\/welcome\/([^/?]+)/);
    if (urlMatch) return urlMatch[1];

    // 支持纯token: friend-xxx-xxx
    if (input.startsWith('friend-')) return input;

    return input.trim();
  };

  return (
    <div className="friend-code-input">
      {/* 智能输入界面 */}
    </div>
  );
};
```
---

*本文档详细定义了PortfolioPulse的业务逻辑，包括访问控制、权限管理、用户交互等核心功能的具体实现方案。*
