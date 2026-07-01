#!/bin/sh
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
SCRIPT_PATH="$CURRENT_DIR/$(basename "$0")"
CUSTOM_BUSYBOX="$CURRENT_DIR/busybox"
WWW_DIR="/tmp/httpd"
CGI_DIR="$WWW_DIR/cgi-bin"
AUTH_FILE="$WWW_DIR/auth.key"

# ==================================================================
# 角色 1：服务管理命令集成 (start | stop)
# ==================================================================
case "$1" in
    "start")
        echo "正在启动小爱音箱FM服务..."
        kill -9 $(pidof httpd) > /dev/null 2>&1
        pkill -f "busybox httpd" > /dev/null 2>&1
        rm -rf "$WWW_DIR" 2>/dev/null

        if [ ! -f "$CUSTOM_BUSYBOX" ]; then
            echo "错误: 在 $CURRENT_DIR 中未找到 busybox 文件！"
            exit 1
        fi
        chmod +x "$CUSTOM_BUSYBOX" 2>/dev/null

        # 1. 创建静态网页和 CGI 环境
        mkdir -p "$CGI_DIR" 2>/dev/null
        
        # 处理芝麻开门密钥
        if [ "$2" = "-auth" ] && [ -n "$3" ]; then
            echo "$3" > "$AUTH_FILE"
            echo "🔒 已启用安全校验机制 (密钥: $3)"
        else
            rm -f "$AUTH_FILE" 2>/dev/null
            echo "🔓 未开启安全校验，允许任意访问"
        fi

        ln -sf "$SCRIPT_PATH" "$CGI_DIR/fm"
        $SCRIPT_PATH gen_html > "$WWW_DIR/index.html"

        # 2. 启动自定义的 httpd Web 服务器
        "$CUSTOM_BUSYBOX" httpd -p 0.0.0.0:80 -h "$WWW_DIR"

        # 获取内网 IPv4 地址
        LOCAL_IP=$("$CUSTOM_BUSYBOX" ifconfig 2>/dev/null | grep -oE 'inet addr:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' | head -1 | sed 's/inet addr://')
        [ -z "$LOCAL_IP" ] && LOCAL_IP=$(ip addr show 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
        [ -z "$LOCAL_IP" ] && LOCAL_IP="<未知IP>"

        echo "服务启动成功！"
        echo "🌐 请访问: http://${LOCAL_IP}"
        exit 0
        ;;
    "stop")
        echo "正在停止服务并清理进程..."
        pkill -f "$CUSTOM_BUSYBOX httpd" > /dev/null 2>&1
        kill -9 $(pidof httpd) > /dev/null 2>&1
        # 清理可能残留的旧后台进程
        pkill -f "$(basename "$SCRIPT_PATH") daemon" > /dev/null 2>&1
        rm -rf "$WWW_DIR" 2>/dev/null
        echo "服务已彻底关闭。"
        exit 0
        ;;
    "gen_html") true ;;
    "") true ;;
    *)
        echo "用法: $0 {start|stop} [-auth 密钥]"
        exit 1
        ;;
esac

# ==================================================================
# 角色 2：纯 HTML
# ==================================================================
if [ "$1" = "gen_html" ]; then
    cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>小爱音箱FM</title>
    <style>
        :root { --bg: #f4f6f9; --card: #ffffff; --primary: #1067ee; --text: #333; --txt-muted: #666; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: var(--bg); color: var(--text); margin: 0; padding: 20px; display: flex; flex-direction: column; align-items: center; }
        .container { width: 100%; max-width: 500px; }
        h1 { text-align: center; font-size: 1.5rem; color: #222; margin-bottom: 20px; }
        .section { background: var(--card); border-radius: 16px; padding: 18px; margin-bottom: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .section-title { font-size: 1rem; font-weight: bold; margin-bottom: 12px; color: var(--txt-muted); border-left: 4px solid var(--primary); padding-left: 8px; }
        .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
        .btn { background: #f0f2f5; border: none; padding: 12px 8px; border-radius: 10px; font-size: 0.9rem; font-weight: 500; cursor: pointer; text-align: center; transition: all 0.2s; -webkit-tap-highlight-color: transparent; }
        .btn:active { background: #e2e5ec; transform: scale(0.95); }
        .btn.primary { background: var(--primary); color: white; }
        .btn.primary:active { background: #0d56c6; }
        .btn.danger { background: #ff3b30; color: white; }
        .btn.danger:active { background: #d32f2f; }
        
        .vol-container { display: flex; align-items: center; gap: 12px; margin-top: 15px; position: relative; }
        input[type="range"] { flex: 1; height: 8px; border-radius: 4px; background: #ddd; -webkit-appearance: none; outline: none; transition: all 0.2s; }
        input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; width: 20px; height: 20px; border-radius: 50%; background: var(--primary); cursor: pointer; transition: transform 0.1s; }
        input[type="range"]:hover::-webkit-slider-thumb, input[type="range"]:focus::-webkit-slider-thumb { transform: scale(1.3); box-shadow: 0 0 10px rgba(16,103,238,0.4); }
        .vol-display { font-size: 1.1rem; font-weight: bold; color: var(--primary); width: 45px; text-align: right; transition: all 0.2s; }
        input[type="range"]:focus + .vol-display, input[type="range"]:hover + .vol-display { color: #ff9500; transform: scale(1.15); }
        
        /* 文本与复合输入框样式 */
        input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 10px; font-size: 0.95rem; outline: none; background: #f9f9f9; transition: all 0.2s; box-sizing: border-box; }
        input[type="password"]:focus { border-color: var(--primary); box-shadow: 0 0 5px rgba(16,103,238,0.3); background: #fff; }
        
        .input-group { display: flex; gap: 10px; }
        .input-group .btn { padding: 12px 16px; white-space: nowrap; }

        /* 自定义下拉框组件样式 */
        .custom-select-wrapper { position: relative; flex: 1; display: flex; align-items: center; background: #f9f9f9; border: 1px solid #ddd; border-radius: 10px; transition: all 0.2s; }
        .custom-select-wrapper:focus-within { border-color: var(--primary); box-shadow: 0 0 5px rgba(16,103,238,0.3); background: #fff; }
        .custom-select-wrapper input { flex: 1; border: none; background: transparent; padding: 12px; outline: none; border-radius: 10px 0 0 10px; font-size: 0.95rem; width: 100%; min-width: 0; }
        .drop-icon { padding: 0 12px; color: #999; cursor: pointer; font-size: 0.8rem; display: flex; align-items: center; justify-content: center; height: 100%; }
        
        .dropdown-content { display: none; position: absolute; top: calc(100% + 5px); left: 0; right: 0; background: #fff; max-height: 220px; overflow-y: auto; box-shadow: 0 8px 24px rgba(0,0,0,0.15); border-radius: 8px; z-index: 100; border: 1px solid #eee; }
        .dropdown-content.show { display: block; }
        .dropdown-item { padding: 12px 16px; font-size: 0.9rem; color: #333; border-bottom: 1px solid #f5f5f5; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .dropdown-item:last-child { border-bottom: none; }
        .dropdown-item:active { background: #f0f6ff; color: var(--primary); }
        @media (hover: hover) { .dropdown-item:hover { background: #f0f6ff; color: var(--primary); } }

        .toast { position: fixed; bottom: 30px; background: rgba(0,0,0,0.8); color: white; padding: 8px 16px; border-radius: 20px; font-size: 0.85rem; opacity: 0; transition: opacity 0.3s; pointer-events: none; z-index: 999; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📻 小爱音箱FM面板</h1>

        <div class="section">
            <div class="section-title">安全校验</div>
            <input type="password" id="authKey" placeholder="输入 芝麻开门 (未设置可留空)">
        </div>
        
        <div class="section">
            <div class="section-title">播控主开关</div>
            <div style="display: flex; gap: 12px;">
                <button class="btn primary" style="flex: 1; padding: 14px;" onclick="sendCmd('p')">▶ 播放 清晨音乐台</button>
                <button class="btn danger" style="flex: 1; padding: 14px;" onclick="sendCmd('s')">■ 停止播放</button>
            </div>
        </div>

        <div class="section">
            <div class="section-title">频道选择 / 自定义源</div>
            <div class="input-group">
                <div class="custom-select-wrapper" id="selectWrapper">
                    <input type="text" id="mediaInput" placeholder="选频道或填URL" autocomplete="off" 
                           oninput="filterDropdown()" onclick="openDropdown(event)">
                    <div class="drop-icon" onclick="toggleAll(event)">▼</div>
                    <div id="customDropdown" class="dropdown-content"></div>
                </div>
                <button class="btn primary" onclick="playMedia()">▶ 播放</button>
            </div>
        </div>

        <div class="section">
            <div class="section-title">固定音量滑块</div>
            <div class="vol-container">
                <span style="font-size: 0.85rem; color: #999;">MIN</span>
                <input type="range" min="5" max="100" step="5" value="50" id="volSlider" oninput="updateLabel(this.value)" onchange="sendCmd(this.value + '%')">
                <span class="vol-display" id="volVal">50%</span>
            </div>
            <div class="section-title">音量微调</div>
            <div class="grid" style="margin-bottom: 15px;">
                <button class="btn" onclick="sendCmd('-')">🔉 音量 －</button>
                <button class="btn" onclick="sendCmd('+')">🔊 音量 ＋</button>
            </div>
        </div>
    </div>
    
    <div class="toast" id="toast">指令已发送</div>

    <script>
        const presetMap = {
            "CCTV-1 综合": "1", "CCTV-2 财经": "2", "CCTV-3 综艺": "3",
            "CCTV-4 中文国际": "4", "CCTV-5 体育": "5", "CCTV-6 电影": "6",
            "CCTV-7 国防军事": "7", "CCTV-8 电视剧": "8", "CCTV-9 纪录": "9",
            "CCTV-10 科教": "10", "CCTV-11 戏曲": "11", "CCTV-12 社会与法": "12",
            "CCTV-13 新闻": "13", "CCTV-14 少儿": "14", "CCTV-15 音乐": "15",
            "CCTV-16 奥林匹克": "16", "CCTV-17 农业农村": "17"
        };
        const presets = Object.keys(presetMap);

        document.addEventListener("DOMContentLoaded", () => {
            const savedAuth = localStorage.getItem('lx06_auth_key');
            if(savedAuth) document.getElementById('authKey').value = savedAuth;
            
            document.getElementById('authKey').addEventListener('input', (e) => {
                localStorage.setItem('lx06_auth_key', e.target.value.trim());
            });

            // 点击页面空白处关闭下拉框
            document.addEventListener('click', (e) => {
                if (!document.getElementById('selectWrapper').contains(e.target)) {
                    document.getElementById('customDropdown').classList.remove('show');
                }
            });
        });

        // 渲染下拉列表
        function renderDropdown(filterText = '') {
            const history = JSON.parse(localStorage.getItem('lx06_custom_urls') || '[]');
            const allItems = [...presets, ...history];
            
            const filtered = allItems.filter(item => 
                item.toLowerCase().includes(filterText.toLowerCase())
            );
            
            const drop = document.getElementById('customDropdown');
            drop.innerHTML = '';
            
            if (filtered.length === 0) {
                drop.classList.remove('show');
                return;
            }

            filtered.forEach(item => {
                const div = document.createElement('div');
                div.className = 'dropdown-item';
                div.innerText = item;
                div.onclick = (e) => {
                    document.getElementById('mediaInput').value = item;
                    drop.classList.remove('show');
                    e.stopPropagation();
                };
                drop.appendChild(div);
            });
            drop.classList.add('show');
        }

        // 输入框获取焦点或点击时，显示相关结果
        function openDropdown(e) {
            e.stopPropagation();
            renderDropdown(document.getElementById('mediaInput').value);
        }

        // 实时过滤
        function filterDropdown() {
            renderDropdown(document.getElementById('mediaInput').value);
        }

        // 点击右侧箭头，清空输入框并展示全部
        function toggleAll(e) {
            e.stopPropagation();
            const drop = document.getElementById('customDropdown');
            if (drop.classList.contains('show')) {
                drop.classList.remove('show');
            } else {
                document.getElementById('mediaInput').value = '';
                renderDropdown('');
                document.getElementById('mediaInput').focus();
            }
        }

        function saveCustomUrl(url) {
            let history = JSON.parse(localStorage.getItem('lx06_custom_urls') || '[]');
            if(!history.includes(url) && !presetMap[url]) {
                history.unshift(url); 
                if(history.length > 100) history.pop();
                localStorage.setItem('lx06_custom_urls', JSON.stringify(history));
            }
        }

        function updateLabel(val) {
            document.getElementById('volVal').innerText = val + '%';
        }
        
        function sendCmd(param) {
            if(param.includes('%')) {
                updateLabel(parseInt(param));
                document.getElementById('volSlider').value = parseInt(param);
            }
            
            const authKey = document.getElementById('authKey').value.trim();
            const reqUrl = '/cgi-bin/fm?cmd=' + encodeURIComponent(param) + '&auth=' + encodeURIComponent(authKey);
            
            fetch(reqUrl)
                .then(res => res.text())
                .then(text => {
                    if(text.includes("Auth Failed")) showToast("❌ 芝麻开门失败，拒绝执行！");
                    else showToast("✅ 指令已发送");
                })
                .catch(() => showToast("❌ 发送失败，请检查网络"));
        }

        function playMedia() {
            const val = document.getElementById('mediaInput').value.trim();
            if(!val) { 
                showToast("请选择频道或输入直链"); 
                return; 
            }
            
            // 播放后自动收起下拉框
            document.getElementById('customDropdown').classList.remove('show');
            
            if (presetMap[val]) {
                sendCmd(presetMap[val]);
            } else {
                saveCustomUrl(val);
                sendCmd('playurl_' + val);
            }
        }
        
        function showToast(msg) {
            const t = document.getElementById('toast');
            t.innerText = msg; t.style.opacity = 1;
            setTimeout(() => t.style.opacity = 0, 1500);
        }
    </script>
</body>
</html>
EOF
    exit 0
fi

# ==================================================================
# 角色 3：CGI 模式 (直发指令，绝不破坏现有媒体播放)
# ==================================================================
# 提取指令 (cmd) 和密钥 (auth)
cmd_raw=$(echo "$QUERY_STRING" | awk -F'cmd=' '{print $2}' | awk -F'&' '{print $1}')
auth_raw=$(echo "$QUERY_STRING" | awk -F'auth=' '{print $2}' | awk -F'&' '{print $1}')

# 芝麻开门 校验逻辑
if [ -s "$AUTH_FILE" ]; then
    real_auth=$(cat "$AUTH_FILE")
    decoded_auth=$(echo "$auth_raw" | sed 's/%2B/+/g' | sed 's/%2b/+/g' | sed 's/%25/%/g')
    if [ "$decoded_auth" != "$real_auth" ]; then
        printf "Content-Type: text/plain\r\n\r\nAuth Failed\r\n" 2>/dev/null
        exit 0
    fi
fi

# 扩充 URL 解码能力
path=$(echo "$cmd_raw" | sed 's/%2B/+/g' | sed 's/%2b/+/g' | sed 's/%3A/:/gi' | sed 's/%2F/\//gi' | sed 's/%3F/?/gi' | sed 's/%3D/=/gi' | sed 's/%26/\&/gi' | sed 's/%25/%/g')

# 定义一个处理播放流链接的内部函数
play_url() {
    kill -9 $(pidof miplayer) > /dev/null 2>&1
    miplayer -f "$1" > /dev/null 2>&1 &
}

case "$path" in
    # 调音量分支
    "+") amixer sset "mysoftvol" 2%+ > /dev/null 2>&1 & ;;
    "-") amixer sset "mysoftvol" 2%- > /dev/null 2>&1 & ;;
    *[1-9]% | *[1-9][0-9]% | *100% )
        clean_vol=$(echo "$path" | tr -cd '0-9')
        amixer sset "mysoftvol" "${clean_vol}%" > /dev/null 2>&1 &
        ;;
    # 播放及换台分支
    "p")  play_url "https://lhttp.qingting.fm/live/4915/64k.mp3" ;;
    "1")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv1_2.m3u8" ;;
    "2")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv2_2.m3u8" ;;
    "3")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv3_2.m3u8" ;;
    "4")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv4_2.m3u8" ;;
    "5")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv5_2.m3u8" ;;
    "6")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv6_2.m3u8" ;;
    "7")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv7_2.m3u8" ;;
    "8")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv8_2.m3u8" ;;
    "9")  play_url "https://piccpndali.v.myalicdn.com/audio/cctv9_2.m3u8" ;;
    "10") play_url "https://piccpndali.v.myalicdn.com/audio/cctv10_2.m3u8" ;;
    "11") play_url "https://piccpndali.v.myalicdn.com/audio/cctv11_2.m3u8" ;;
    "12") play_url "https://piccpndali.v.myalicdn.com/audio/cctv12_2.m3u8" ;;
    "13") play_url "https://piccpndali.v.myalicdn.com/audio/cctv13_2.m3u8" ;;
    "14") play_url "https://piccpndali.v.myalicdn.com/audio/cctv14_2.m3u8" ;;
    "15") play_url "https://piccpndali.v.myalicdn.com/audio/cctv15_2.m3u8" ;;
    "16") play_url "https://piccpndali.v.myalicdn.com/audio/cctv16_2.m3u8" ;;
    "17") play_url "https://piccpndali.v.myalicdn.com/audio/cctv17_2.m3u8" ;;
    
    # 自定义直链播放分支
    "playurl_"*)
        custom_stream_url="${path#playurl_}"
        play_url "$custom_stream_url"
        ;;
        
    "s")
        kill -9 $(pidof miplayer) > /dev/null 2>&1
        ;;
    *)   true ;;
esac

printf "Content-Type: text/plain\r\nContent-Length: 0\r\nConnection: close\r\n\r\n" 2>/dev/null
exit 0