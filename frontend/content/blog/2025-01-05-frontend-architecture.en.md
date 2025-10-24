---
title: Modern Frontend Architecture Design
description: From monolithic applications to micro-frontends, exploring the evolution and design principles of modern frontend architecture
date: 2025-01-05
category: architecture
tags:
  - Architecture
  - Micro-Frontend
  - Design Patterns
featured: false
readTime: 10 min
---

# Modern Frontend Architecture Design

As frontend application complexity continues to grow, architectural design becomes increasingly important. This article explores the evolution and best practices of modern frontend architecture.

## 🏗️ Architecture Evolution

### 1. Traditional Monolithic Applications

Early frontend applications were typically simple HTML + CSS + JavaScript:

```html
<!-- Traditional monolithic application -->
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="app"></div>
    <script src="jquery.js"></script>
    <script src="app.js"></script>
</body>
</html>
```

**Issues:**
- ❌ Hard to maintain
- ❌ Tightly coupled code
- ❌ Difficult team collaboration

### 2. Component-Based Architecture

React/Vue introduced component-based thinking:

```tsx
// Component-based architecture
function UserProfile({ userId }: { userId: string }) {
    const [user, setUser] = useState<User | null>(null);
    
    useEffect(() => {
        fetchUser(userId).then(setUser);
    }, [userId]);
    
    if (!user) return <Loading />;
    
    return (
        <div className="profile">
            <Avatar src={user.avatar} />
            <UserInfo user={user} />
        </div>
    );
}
```

**Benefits:**
- ✅ Reusable components
- ✅ Clear responsibility boundaries
- ✅ Easy to test and maintain

### 3. State Management Era

As applications grew more complex, state management became crucial:

```typescript
// Redux example
const userSlice = createSlice({
    name: 'user',
    initialState: {
        current: null,
        loading: false,
        error: null,
    },
    reducers: {
        fetchUserStart(state) {
            state.loading = true;
        },
        fetchUserSuccess(state, action) {
            state.current = action.payload;
            state.loading = false;
        },
        fetchUserFailure(state, action) {
            state.error = action.payload;
            state.loading = false;
        },
    },
});
```

### 4. Micro-Frontend Architecture

Modern large-scale applications adopt micro-frontend architecture:

```typescript
// Micro-frontend orchestration
const MicroFrontendApp = () => {
    return (
        <div className="app">
            <Header /> {/* Shared shell */}
            <div className="content">
                <MicroApp name="products" />
                <MicroApp name="checkout" />
                <MicroApp name="user-center" />
            </div>
            <Footer /> {/* Shared shell */}
        </div>
    );
};
```

## 🎯 Design Principles

### 1. Separation of Concerns

Separate different concerns into independent modules:

```typescript
// Bad - mixed concerns
function UserComponent() {
    const [user, setUser] = useState(null);
    
    // Data fetching
    useEffect(() => {
        fetch('/api/user')
            .then(res => res.json())
            .then(setUser);
    }, []);
    
    // Business logic
    const processUserData = (data) => {
        // Complex processing logic...
    };
    
    // UI rendering
    return <div>{/* ... */}</div>;
}

// Good - separated concerns
// hooks/useUser.ts
export function useUser(userId: string) {
    const [user, setUser] = useState(null);
    
    useEffect(() => {
        fetchUser(userId).then(setUser);
    }, [userId]);
    
    return user;
}

// utils/userProcessor.ts
export function processUserData(data: User) {
    // Processing logic
}

// components/UserComponent.tsx
function UserComponent({ userId }: Props) {
    const user = useUser(userId);
    const processed = processUserData(user);
    
    return <UserView data={processed} />;
}
```

### 2. Layered Architecture

Build clear layered structure:

```
┌─────────────────────────────────┐
│      Presentation Layer         │  ← Components, Views
├─────────────────────────────────┤
│      Business Logic Layer       │  ← Services, Hooks
├─────────────────────────────────┤
│      Data Access Layer          │  ← API Clients, Store
├─────────────────────────────────┤
│      Infrastructure Layer       │  ← Utils, Config
└─────────────────────────────────┘
```

### 3. Dependency Inversion

High-level modules shouldn't depend on low-level modules:

```typescript
// Bad - direct dependency
class UserService {
    private api = new HttpClient();
    
    async getUser(id: string) {
        return this.api.get(`/users/${id}`);
    }
}

// Good - dependency injection
interface ApiClient {
    get<T>(url: string): Promise<T>;
}

class UserService {
    constructor(private api: ApiClient) {}
    
    async getUser(id: string) {
        return this.api.get<User>(`/users/${id}`);
    }
}
```

## 🔧 Technical Architecture

### 1. Monorepo Management

Use tools like Turborepo or Nx:

```json
{
  "name": "my-monorepo",
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test"
  }
}
```

### 2. Module Federation

Share code between micro-frontends using Webpack Module Federation:

```javascript
// webpack.config.js
module.exports = {
    plugins: [
        new ModuleFederationPlugin({
            name: 'app1',
            filename: 'remoteEntry.js',
            exposes: {
                './Button': './src/components/Button',
                './utils': './src/utils',
            },
            shared: {
                react: { singleton: true },
                'react-dom': { singleton: true },
            },
        }),
    ],
};
```

### 3. Service Worker & PWA

Enhance user experience with offline capabilities:

```typescript
// service-worker.ts
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open('v1').then((cache) => {
            return cache.addAll([
                '/',
                '/styles.css',
                '/script.js',
                '/images/logo.png',
            ]);
        })
    );
});

self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request).then((response) => {
            return response || fetch(event.request);
        })
    );
});
```

## 📊 Performance Optimization

### 1. Code Splitting

```typescript
// Route-based splitting
const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Products = lazy(() => import('./pages/Products'));

function App() {
    return (
        <Suspense fallback={<Loading />}>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/about" element={<About />} />
                <Route path="/products" element={<Products />} />
            </Routes>
        </Suspense>
    );
}
```

### 2. Resource Optimization

```typescript
// Image optimization
import Image from 'next/image';

function ProductCard({ product }) {
    return (
        <div>
            <Image
                src={product.image}
                alt={product.name}
                width={300}
                height={200}
                loading="lazy"
                placeholder="blur"
            />
        </div>
    );
}
```

### 3. State Management Optimization

```typescript
// Use selector to avoid unnecessary re-renders
const useUserName = () => {
    return useSelector((state: RootState) => state.user.name);
};

// Not
const useUser = () => {
    return useSelector((state: RootState) => state.user);
};
```

## 🚀 Future Trends

### 1. Server Components

React Server Components revolutionize rendering strategies:

```tsx
// app/page.tsx - Server Component
async function ProductList() {
    // Runs on server
    const products = await db.products.findMany();
    
    return (
        <div>
            {products.map(product => (
                <ProductCard key={product.id} product={product} />
            ))}
        </div>
    );
}
```

### 2. Edge Computing

Deploy applications to edge nodes for better performance:

```typescript
// Vercel Edge Function
export const config = {
    runtime: 'edge',
};

export default async function handler(req: Request) {
    const { searchParams } = new URL(req.url);
    const userId = searchParams.get('userId');
    
    const user = await fetchUser(userId);
    
    return new Response(JSON.stringify(user), {
        headers: { 'content-type': 'application/json' },
    });
}
```

### 3. Streaming SSR

Progressive rendering for better user experience:

```tsx
// app/layout.tsx
export default function Layout({ children }) {
    return (
        <html>
            <body>
                <Suspense fallback={<HeaderSkeleton />}>
                    <Header />
                </Suspense>
                
                <Suspense fallback={<ContentSkeleton />}>
                    {children}
                </Suspense>
                
                <Footer />
            </body>
        </html>
    );
}
```

## 📝 Summary

Modern frontend architecture emphasizes:

- ✅ **Modularity** - Clear component boundaries
- ✅ **Scalability** - Supports large team collaboration
- ✅ **Performance** - Optimized user experience
- ✅ **Maintainability** - Easy to extend and refactor

Choosing the right architecture depends on your project's specific needs. Start with simplicity and gradually evolve as complexity grows.

## 📚 References

- [Micro-Frontends](https://micro-frontends.org/)
- [React Server Components](https://react.dev/blog/2023/03/22/react-labs-what-we-have-been-working-on-march-2023#react-server-components)
- [Patterns.dev](https://www.patterns.dev/)
