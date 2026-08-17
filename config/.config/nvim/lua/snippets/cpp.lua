-- lua/snippets/cpp.lua — 竞赛代码模板
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("cpp", {

  -- ===== 通用模板 =====

  -- 竞赛头文件
  s("cpp", fmt([[
#include <bits/stdc++.h>
using namespace std;
typedef long long ll;
const int MOD = 1e9 + 7;
const int INF = 0x3f3f3f3f;
const int MAXN = {};

int main() {{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    {}

    return 0;
}}
]], {
    i(1, "100005"),
    i(2),
  })),

  -- ===== 树状数组 =====

  s("bit", fmt([[
// 树状数组 — 单点修改 + 区间查询  O(log n)
int tree[MAXN], n;

int lowbit(int x) {{ return x & -x; }}

void add(int i, int val) {{
    while (i <= n) {{ tree[i] += val; i += lowbit(i); }}
}}

int query(int i) {{
    int sum = 0;
    while (i > 0) {{ sum += tree[i]; i -= lowbit(i); }}
    return sum;
}}

int range_sum(int l, int r) {{ return query(r) - query(l - 1); }}
]], {})),

  s("bitinv", fmt([[
// BIT 求逆序对（需先离散化）
ll swaps = 0;
for (int i = 0; i < n; i++) {{
    int x; cin >> x;
    swaps += i - query(x);
    add(x, 1);
}}
cout << swaps << endl;
]], {})),

  -- ===== 线段树 =====

  s("seg", fmt([[
// 线段树 Lazy 版 — 区间修改 + 区间查询
int A[MAXN];

struct SegNode {{
    int val, lazy;
}} seg[MAXN << 2];

void push_up(int rt) {{
    seg[rt].val = seg[rt << 1].val + seg[rt << 1 | 1].val;
}}

void push_down(int rt, int ln, int rn) {{
    if (seg[rt].lazy) {{
        seg[rt << 1].lazy += seg[rt].lazy;
        seg[rt << 1 | 1].lazy += seg[rt].lazy;
        seg[rt << 1].val += seg[rt].lazy * ln;
        seg[rt << 1 | 1].val += seg[rt].lazy * rn;
        seg[rt].lazy = 0;
    }}
}}

void build(int l, int r, int rt) {{
    seg[rt].lazy = 0;
    if (l == r) {{ seg[rt].val = A[l]; return; }}
    int m = (l + r) >> 1;
    build(l, m, rt << 1);
    build(m + 1, r, rt << 1 | 1);
    push_up(rt);
}}

// [L,R] += C
void update(int L, int R, int C, int l, int r, int rt) {{
    if (L <= l && r <= R) {{
        seg[rt].val += C * (r - l + 1);
        seg[rt].lazy += C;
        return;
    }}
    int m = (l + r) >> 1;
    push_down(rt, m - l + 1, r - m);
    if (L <= m) update(L, R, C, l, m, rt << 1);
    if (R > m)  update(L, R, C, m + 1, r, rt << 1 | 1);
    push_up(rt);
}}

int query(int L, int R, int l, int r, int rt) {{
    if (L <= l && r <= R) return seg[rt].val;
    if (L > r || R < l) return 0;
    int m = (l + r) >> 1;
    push_down(rt, m - l + 1, r - m);
    return query(L, R, l, m, rt << 1)
         + query(L, R, m + 1, r, rt << 1 | 1);
}}
]], {})),

  s("seg0", fmt([[
// 线段树 无 Lazy — 单点修改 + 区间查询
int A[MAXN];

struct SegNode {{ int val; }} seg[MAXN << 2];

void push_up(int rt) {{
    seg[rt].val = seg[rt << 1].val + seg[rt << 1 | 1].val;
}}

void build(int l, int r, int rt) {{
    if (l == r) {{ seg[rt].val = A[l]; return; }}
    int m = (l + r) >> 1;
    build(l, m, rt << 1);
    build(m + 1, r, rt << 1 | 1);
    push_up(rt);
}}

// A[pos] += C
void update(int pos, int C, int l, int r, int rt) {{
    if (l == r) {{ seg[rt].val += C; return; }}
    int m = (l + r) >> 1;
    if (pos <= m) update(pos, C, l, m, rt << 1);
    else          update(pos, C, m + 1, r, rt << 1 | 1);
    push_up(rt);
}}

int query(int L, int R, int l, int r, int rt) {{
    if (L <= l && r <= R) return seg[rt].val;
    if (L > r || R < l) return 0;
    int m = (l + r) >> 1;
    return query(L, R, l, m, rt << 1)
         + query(L, R, m + 1, r, rt << 1 | 1);
}}
]], {})),

  -- ===== 二分 =====

  s("bs", fmt([[
// 二分答案框架 — check(x) 须单调
ll l = {}, r = {}, ans = r;
while (l <= r) {{
    ll mid = (l + r) >> 1;
    if (check(mid)) {{
        ans = mid;
        r = mid - 1;   // 最小满足
    }} else {{
        l = mid + 1;
    }}
}}
return ans;
]], {
    i(1, "lo"),
    i(2, "hi"),
  })),

  s("bscheck", fmt([[
// 贪心判定：每段和 ≤ x 时，段数 ≤ m ?
int check(ll x) {{
    ll sum = 0; int cnt = 1;
    for (int i = 1; i <= n; i++) {{
        if (a[i] > x) return INF;
        if (sum + a[i] <= x) sum += a[i];
        else sum = a[i], cnt++;
    }}
    return cnt;
}}
]], {})),

  s("twoptr", fmt([[
// 双指针：有序数组 a[1..n], b[1..m] 中 a[i]+b[j] ≤ x 的对数
ll count_le(ll x) {{
    ll cnt = 0; int j = m;
    for (int i = 1; i <= n; i++) {{
        while (j > 0 && a[i] + b[j] > x) j--;
        cnt += j;
    }}
    return cnt;
}}
]], {})),

  -- ===== KMP =====

  s("kmp", fmt([[
// 预处理next数组
void pre() {{
    P[1] = 0;
    int j = 0;
    for (int i = 1; i < m; i++) {{
        while (j > 0 && B[j + 1] != B[i + 1])
            j = P[j];
        if (B[j + 1] == B[i + 1])
            j++;
        P[i + 1] = j;
    }}
}}

// KMP匹配（统计匹配次数）
int kmp_count() {{
    int ans = 0, j = 0;
    for (int i = 0; i < n; i++) {{
        while (j > 0 && B[j + 1] != A[i + 1])
            j = P[j];
        if (B[j + 1] == A[i + 1])
            j++;
        if (j == m) {{
            ans++;  // 匹配成功一次
            j = P[j];  // 允许重叠，继续匹配
        }}
    }}
    return ans;
}}
]], {})),

  -- ===== 快速幂 & 矩阵快速幂 =====

  s("qpow", fmt([[
ll qpow(ll a, ll n) {{
    ll res = 1;
    while (n) {{
        if (n & 1) res = res * a % MOD;
        a = a * a % MOD;
        n >>= 1;
    }}
    return res;
}}
]], {})),

  s("matmul", fmt([[
// 矩阵乘（cache 优化：i-k-j 循环顺序）
const int K = {};  // 矩阵维度

struct Matrix {{
    ll m[K][K];
    Matrix() {{ memset(m, 0, sizeof(m)); }}
}};

Matrix mul(Matrix a, Matrix b) {{
    Matrix c;
    for (int i = 0; i < K; i++)
        for (int k = 0; k < K; k++)
            if (a.m[i][k])
                for (int j = 0; j < K; j++)
                    c.m[i][j] = (c.m[i][j] + a.m[i][k] * b.m[k][j]) % MOD;
    return c;
}}
]], {
    i(1, "10"),
  })),

  s("matpow", fmt([[
// 矩阵快速幂
Matrix mat_pow(Matrix a, ll n) {{
    Matrix res;
    for (int i = 0; i < K; i++) res.m[i][i] = 1;
    while (n) {{
        if (n & 1) res = mul(res, a);
        a = mul(a, a);
        n >>= 1;
    }}
    return res;
}}
]], {})),

  -- ===== 数论 =====

  s("gcd", fmt([[
int gcd(int a, int b) {{ return b == 0 ? a : gcd(b, a % b); }}
]], {})),

  s("exgcd", fmt([[
// 扩展欧几里得：求 ax + by = gcd(a,b) 的一组解
ll ex_gcd(ll a, ll b, ll &x, ll &y) {{
    if (b == 0) {{ x = 1; y = 0; return a; }}
    ll d = ex_gcd(b, a % b, x, y);
    ll tmp = x; x = y; y = tmp - (a / b) * y;
    return d;
}}

// a 在模 m 下的逆元（gcd(a,m)==1）
ll mod_inv(ll a, ll m) {{
    ll x, y;
    ex_gcd(a, m, x, y);
    return (x % m + m) % m;
}}

// 费马小定理求逆元（MOD 为质数）
ll inv(ll x) {{ return qpow(x, MOD - 2); }}

// O(n) 线性求 1..n 的逆元
ll inv_arr[MAXN];
inv_arr[1] = 1;
for (int i = 2; i <= N; i++)
    inv_arr[i] = (MOD - MOD / i) * inv_arr[MOD % i] % MOD;
]], {})),

  -- ===== 中国剩余定理 =====

  s("crt", fmt([[
// 标准 CRT — 模数两两互质
ll crt(ll m[], ll a[], int n) {{
    ll M = 1, ans = 0;
    for (int i = 0; i < n; i++) M *= m[i];
    for (int i = 0; i < n; i++) {{
        ll Mi = M / m[i];
        ll xi = mod_inv(Mi % m[i], m[i]);
        ans = (ans + a[i] * Mi % M * xi) % M;
    }}
    return ans;
}}

// 扩展 CRT — 模数不互质（无解返回 -1）
ll ex_crt(ll m[], ll a[], int n) {{
    ll M = m[0], x = a[0];
    for (int i = 1; i < n; i++) {{
        ll c = ((a[i] - x) % m[i] + m[i]) % m[i];
        ll t, y;
        ll d = ex_gcd(M, m[i], t, y);
        if (c % d) return -1;
        t = (__int128)t * (c / d) % (m[i] / d);
        x = x + t * M;
        M = M / d * m[i];
        x = (x % M + M) % M;
    }}
    return x;
}}
]], {})),

  -- ===== Dijkstra 堆优化 =====

s("dij", fmt([[
// Dijkstra 堆优化 — 单源最短路 O(E log E)，无负权
const int MAXN = 100005, MAXM = 200005;

int head[MAXN], dist[MAXN], vis[MAXN], cnt;

struct Edge {{
    int to, dis, next;
}} edge[MAXM];

void add_edge(int u, int v, int w) {{
    edge[++cnt] = {{v, w, head[u]}};
    head[u] = cnt;
}}

struct Node {{
    int id, d;
    bool operator<(const Node &o) const {{ return d > o.d; }}
}};

void dijkstra(int s, int n) {{
    priority_queue<Node> q;
    for(int i = 1; i <= n; i++) {{
        dist[i] = INF;
        vis[i] = 0;
    }}
    dist[s] = 0;
    q.push({{s, 0}});

    while (!q.empty()) {{
        int now = q.top().id;
        q.pop();
        if (vis[now]) continue;
        vis[now] = 1;

        for (int i = head[now]; i; i = edge[i].next) {{
            int v = edge[i].to, w = edge[i].dis;
            if (dist[now] + w < dist[v]) {{
                dist[v] = dist[now] + w;
                q.push({{v, dist[v]}});
            }}
        }}
    }}
}}
]], {})),

  -- ===== 最短路径全家桶 =====

  s("floyd", fmt([[
// Floyd 全源最短路  O(n³)  k 在最外层！
int dis[MAXN][MAXN];  // 初始化 dis[i][i]=0, 无边=INF

void floyd(int n) {{
    for (int k = 1; k <= n; k++)
        for (int i = 1; i <= n; i++)
            for (int j = 1; j <= n; j++)
                if (dis[i][k] < INF && dis[k][j] < INF)
                    dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
}}
]], {})),

  s("spfa", fmt([[
// SPFA 队列优化 Bellman-Ford  平均 O(E)，可负权
int head[MAXN], dist[MAXN], inq[MAXN], cnt;

void spfa(int s, int n) {{
    queue<int> q;
    fill(dist, dist + n + 1, INF);
    dist[s] = 0; inq[s] = 1; q.push(s);

    while (!q.empty()) {{
        int u = q.front(); q.pop();
        inq[u] = 0;

        for (int i = head[u]; i; i = edge[i].next) {{
            int v = edge[i].to, w = edge[i].w;
            if (dist[u] + w < dist[v]) {{
                dist[v] = dist[u] + w;
                if (!inq[v]) {{ inq[v] = 1; q.push(v); }}
            }}
        }}
    }}
}}
]], {})),

  -- ===== 图论基础工具 =====

  s("fs", fmt([[
// 链式前向星 — 存图 + BFS + DFS
int head[MAXN], cnt;
struct Edge {{ int to, w, next; }} edge[MAXM];

void add_edge(int u, int v, int w) {{
    edge[++cnt] = {{v, w, head[u]}};
    head[u] = cnt;
}}

void bfs(int s) {{
    queue<int> q; q.push(s); vis[s] = 1;
    while (!q.empty()) {{
        int u = q.front(); q.pop();
        for (int i = head[u]; i; i = edge[i].next) {{
            int v = edge[i].to;
            if (!vis[v]) {{ vis[v] = 1; q.push(v); }}
        }}
    }}
}}

void dfs(int u) {{
    vis[u] = 1;
    for (int i = head[u]; i; i = edge[i].next) {{
        int v = edge[i].to;
        if (!vis[v]) dfs(v);
    }}
}}
]], {})),

})
