#!/bin/sh
#===============================================================================
# 小爱音箱 FM 控制面板 (一体化脚本)
# 功能：提供 Web 控制界面，可播放自定义流媒体、管理音量、切换频道等。
# 使用：
#   ./fm.sh start [-auth 密钥]   # 启动服务
#   ./fm.sh stop                 # 停止服务
#===============================================================================

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
SCRIPT_PATH="$CURRENT_DIR/$(basename "$0")"
CUSTOM_BUSYBOX="$CURRENT_DIR/busybox"
WWW_DIR="/tmp/httpd"
CGI_DIR="$WWW_DIR/cgi-bin"
AUTH_FILE="$WWW_DIR/auth.key"

# ==================================================================
# 角色 1：服务管理 (start | stop)
# ==================================================================
case "$1" in
    "start")
        echo "正在启动小爱音箱FM服务..."
        # 彻底清理旧进程和文件
        kill -9 $(pidof httpd) > /dev/null 2>&1
        pkill -f "busybox httpd" > /dev/null 2>&1
        rm -rf "$WWW_DIR" 2>/dev/null

        if [ ! -f "$CUSTOM_BUSYBOX" ]; then
            echo "错误: 在 $CURRENT_DIR 中未找到 busybox 文件！"
            exit 1
        fi
        chmod +x "$CUSTOM_BUSYBOX" 2>/dev/null

        # 1. 创建 Web 目录结构和环境
        mkdir -p "$CGI_DIR" 2>/dev/null
        
        # 处理认证密钥
        if [ "$2" = "-auth" ] && [ -n "$3" ]; then
            echo "$3" > "$AUTH_FILE"
            echo "🔒 已启用安全校验机制 (密钥: $3)"
        else
            rm -f "$AUTH_FILE" 2>/dev/null
            echo "🔓 未开启安全校验，允许任意访问"
        fi

        # 2. 生成电台列表文件 fmlist.txt（方便日后维护）
        cat > "$WWW_DIR/fmlist.txt" << 'EOF'
网络台-两广之声音乐台,https://lhttp-hw.qtfm.cn/live/20500149/64k.mp3
网络台-怀集音乐之声,https://lhttp-hw.qtfm.cn/live/4804/64k.mp3
网络台-清晨音乐台,https://lhttp-hw.qtfm.cn/live/4915/64k.mp3
网络台-国际新闻,https://lhttp-hw.qtfm.cn/live/20500172/64k.mp3
网络台-AsiaFM 亚洲粤语台,https://lhttp-hw.qtfm.cn/live/15318569/64k.mp3
网络台-新闻听天下,https://lhttp-hw.qtfm.cn/live/20500169/64k.mp3
网络台-顺德音乐之声,https://lhttp-hw.qtfm.cn/live/20500150/64k.mp3
网络台-动听音乐台,https://lhttp-hw.qtfm.cn/live/5022107/64k.mp3
网络台-星河音乐,https://lhttp-hw.qtfm.cn/live/20210755/64k.mp3
网络台-AsiaFM HD音乐台,https://lhttp-hw.qtfm.cn/live/15318341/64k.mp3
网络台-80后音悦台,https://lhttp-hw.qtfm.cn/live/20207761/64k.mp3
网络台-AsiaFM 亚洲经典台,https://lhttp-hw.qtfm.cn/live/5021912/64k.mp3
网络台-郁南音乐台,https://lhttp-hw.qtfm.cn/live/20026/64k.mp3
网络台-AsiaFM 亚洲音乐台,https://lhttp-hw.qtfm.cn/live/5022405/64k.mp3
网络台-AsiaFM 亚洲天空台,https://lhttp-hw.qtfm.cn/live/20071/64k.mp3
网络台-海上财经,https://lhttp-hw.qtfm.cn/live/20500170/64k.mp3
网络台-体坛速听,https://lhttp-hw.qtfm.cn/live/20500171/64k.mp3
网络台-AsiaFM 亚洲热歌台,https://lhttp-hw.qtfm.cn/live/20500208/64k.mp3
网络台-中国校园之声,https://lhttp-hw.qtfm.cn/live/20091/64k.mp3
网络台-云梦音乐台,https://lhttp-hw.qtfm.cn/live/20500187/64k.mp3
网络台-河南经典FM,https://lhttp-hw.qtfm.cn/live/20207762/64k.mp3
网络台-青苹果音乐台,https://lhttp-hw.qtfm.cn/live/4576/64k.mp3
网络台-西江之声,https://lhttp-hw.qtfm.cn/live/5022379/64k.mp3
网络台-湾区音乐台,https://lhttp-hw.qtfm.cn/live/20500163/64k.mp3
网络台-天籁古典,https://lhttp-hw.qtfm.cn/live/20210756/64k.mp3
网络台-90后潮流音悦台,https://lhttp-hw.qtfm.cn/live/20207760/64k.mp3
网络台-CityFM城市音乐台,https://lhttp-hw.qtfm.cn/live/20500153/64k.mp3
网络台-民谣音乐台,https://lhttp-hw.qtfm.cn/live/20207763/64k.mp3
网络台-Tiktok网络电台,https://lhttp-hw.qtfm.cn/live/5062/64k.mp3
网络台-中国交通网络应急广播,https://lhttp-hw.qtfm.cn/live/20212320/64k.mp3
网络台-古典音乐厅,https://lhttp-hw.qtfm.cn/live/20500181/64k.mp3
网络台-麻辣966,https://lhttp-hw.qtfm.cn/live/20212393/64k.mp3
网络台-萤火虫网络电台,https://lhttp-hw.qtfm.cn/live/4998/64k.mp3
网络台-阿基米德故事会,https://lhttp-hw.qtfm.cn/live/20500182/64k.mp3
网络台-520电台-520星恋情感电台,https://lhttp-hw.qtfm.cn/live/15318191/64k.mp3
网络台-爵士FM,https://lhttp-hw.qtfm.cn/live/20207764/64k.mp3
网络台-听·越剧,https://lhttp-hw.qtfm.cn/live/20500178/64k.mp3
网络台-891线上音乐台,https://lhttp-hw.qtfm.cn/live/20500215/64k.mp3
网络台-鱼佬音乐坊,https://lhttp-hw.qtfm.cn/live/20500158/64k.mp3
网络台-乐享音乐,https://lhttp-hw.qtfm.cn/live/4913/64k.mp3
网络台-摇滚天空台,https://lhttp-hw.qtfm.cn/live/20207765/64k.mp3
网络台-科技情报站,https://lhttp-hw.qtfm.cn/live/20500175/64k.mp3
网络台-卷卷猫电台,https://lhttp-hw.qtfm.cn/live/20500038/64k.mp3
网络台-听梦想FM,https://lhttp-hw.qtfm.cn/live/4917/64k.mp3
网络台-Radio Impetus 心动电台,https://lhttp-hw.qtfm.cn/live/20500161/64k.mp3
网络台-声音控电台,https://lhttp-hw.qtfm.cn/live/15318519/64k.mp3
网络台-新梦想之声,https://lhttp-hw.qtfm.cn/live/5021905/64k.mp3
网络台-源声态汽车音乐电台,https://lhttp-hw.qtfm.cn/live/20500021/64k.mp3
网络台-上海天气台,https://lhttp-hw.qtfm.cn/live/20500176/64k.mp3
网络台-海浪电台,https://lhttp-hw.qtfm.cn/live/20500180/64k.mp3
网络台-芒果5G（原和鸣）,https://lhttp-hw.qtfm.cn/live/20211693/64k.mp3
CCTV-1 综合,https://piccpndali.v.myalicdn.com/audio/cctv1_2.m3u8
CCTV-2 财经,https://piccpndali.v.myalicdn.com/audio/cctv2_2.m3u8
CCTV-3 综艺,https://piccpndali.v.myalicdn.com/audio/cctv3_2.m3u8
CCTV-4 中文国际,https://piccpndali.v.myalicdn.com/audio/cctv4_2.m3u8
CCTV-5 体育,https://piccpndali.v.myalicdn.com/audio/cctv5_2.m3u8
CCTV-6 电影,https://piccpndali.v.myalicdn.com/audio/cctv6_2.m3u8
CCTV-7 国防军事,https://piccpndali.v.myalicdn.com/audio/cctv7_2.m3u8
CCTV-8 电视剧,https://piccpndali.v.myalicdn.com/audio/cctv8_2.m3u8
CCTV-9 纪录,https://piccpndali.v.myalicdn.com/audio/cctv9_2.m3u8
CCTV-10 科教,https://piccpndali.v.myalicdn.com/audio/cctv10_2.m3u8
CCTV-11 戏曲,https://piccpndali.v.myalicdn.com/audio/cctv11_2.m3u8
CCTV-12 社会与法,https://piccpndali.v.myalicdn.com/audio/cctv12_2.m3u8
CCTV-13 新闻,https://piccpndali.v.myalicdn.com/audio/cctv13_2.m3u8
CCTV-14 少儿,https://piccpndali.v.myalicdn.com/audio/cctv14_2.m3u8
CCTV-15 音乐,https://piccpndali.v.myalicdn.com/audio/cctv15_2.m3u8
CCTV-16 奥林匹克,https://piccpndali.v.myalicdn.com/audio/cctv16_2.m3u8
CCTV-17 农业农村,https://piccpndali.v.myalicdn.com/audio/cctv17_2.m3u8
北京-北京新闻广播,https://lhttp-hw.qtfm.cn/live/339/64k.mp3
北京-北京交通广播,https://lhttp-hw.qtfm.cn/live/336/64k.mp3
北京-北京文艺广播,https://lhttp-hw.qtfm.cn/live/333/64k.mp3
北京-北京体育广播,https://lhttp-hw.qtfm.cn/live/335/64k.mp3
北京-959年代音乐怀旧好声音,https://lhttp-hw.qtfm.cn/live/5021381/64k.mp3
北京-北京音乐广播,https://lhttp-hw.qtfm.cn/live/332/64k.mp3
北京-北京城市广播,https://lhttp-hw.qtfm.cn/live/345/64k.mp3
北京-怀旧音乐广播895,https://lhttp-hw.qtfm.cn/live/20211619/64k.mp3
北京-京津冀之声,https://lhttp-hw.qtfm.cn/live/5022463/64k.mp3
北京-流行音乐广播999正青春,https://lhttp-hw.qtfm.cn/live/20211620/64k.mp3
北京-北京大兴人民广播电台FM986,https://lhttp-hw.qtfm.cn/live/5021739/64k.mp3
天津-天津滨海100.5,https://lhttp-hw.qtfm.cn/live/20003/64k.mp3
天津-经典FM1008,https://lhttp-hw.qtfm.cn/live/20212227/64k.mp3
河北-河北新闻广播,https://lhttp-hw.qtfm.cn/live/1644/64k.mp3
河北-河北音乐广播,https://lhttp-hw.qtfm.cn/live/1649/64k.mp3
河北-河北交通广播,https://lhttp-hw.qtfm.cn/live/1646/64k.mp3
河北-经典音乐 FM90.5,https://lhttp-hw.qtfm.cn/live/20212269/64k.mp3
河北-邯郸新闻综合广播,https://lhttp-hw.qtfm.cn/live/5072/64k.mp3
河北-石家庄新闻广播,https://lhttp-hw.qtfm.cn/live/1652/64k.mp3
河北-河北综合广播,https://lhttp-hw.qtfm.cn/live/20500111/64k.mp3
河北-怀旧金曲964,https://lhttp-hw.qtfm.cn/live/5021555/64k.mp3
河北-石家庄交通广播,https://lhttp-hw.qtfm.cn/live/1655/64k.mp3
河北-献县人民广播电台,https://lhttp-hw.qtfm.cn/live/5022603/64k.mp3
河北-邯郸交通广播,https://lhttp-hw.qtfm.cn/live/3950/64k.mp3
河北-武安融媒综合广播,https://lhttp-hw.qtfm.cn/live/5022474/64k.mp3
河北-任丘融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/5022470/64k.mp3
河北-邯郸都市生活广播,https://lhttp-hw.qtfm.cn/live/3951/64k.mp3
河北-定州交通音乐广播,https://lhttp-hw.qtfm.cn/live/20211638/64k.mp3
河北-秦皇岛交通广播,https://lhttp-hw.qtfm.cn/live/20849/64k.mp3
河北-畅行951,https://lhttp-hw.qtfm.cn/live/3948/64k.mp3
河北-石家庄音乐广播,https://lhttp-hw.qtfm.cn/live/1654/64k.mp3
河北-衡水交通广播925,https://lhttp-hw.qtfm.cn/live/5021940/64k.mp3
河北-秦皇岛新闻综合广播,https://lhttp-hw.qtfm.cn/live/20855/64k.mp3
河北-衡水湖城之声961,https://lhttp-hw.qtfm.cn/live/5021857/64k.mp3
河北-河北旅游文化广播,https://lhttp-hw.qtfm.cn/live/1651/64k.mp3
河北-保定新闻广播,https://lhttp-hw.qtfm.cn/live/5022440/64k.mp3
河北-年代965经典音乐广播,https://lhttp-hw.qtfm.cn/live/5022038/64k.mp3
河北-河北故事广播,https://lhttp-hw.qtfm.cn/live/1645/64k.mp3
河北-保定交通广播,https://lhttp-hw.qtfm.cn/live/20168/64k.mp3
河北-河北文艺广播,https://lhttp-hw.qtfm.cn/live/4868/64k.mp3
河北-秦皇岛1038私家车广播,https://lhttp-hw.qtfm.cn/live/20859/64k.mp3
河北-河北农民广播,https://lhttp-hw.qtfm.cn/live/1650/64k.mp3
河北-秦皇岛音乐广播,https://lhttp-hw.qtfm.cn/live/20835/64k.mp3
河北-张家口交通广播,https://lhttp-hw.qtfm.cn/live/5021910/64k.mp3
河北-汽车音乐台,https://lhttp-hw.qtfm.cn/live/5021743/64k.mp3
河北-廊坊飞扬105,https://lhttp-hw.qtfm.cn/live/20211678/64k.mp3
河北-沧州音乐广播FM103.6,https://lhttp-hw.qtfm.cn/live/5021902/64k.mp3
河北-唐山新闻综合,https://lhttp-hw.qtfm.cn/live/1657/64k.mp3
河北-河间市融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/15318503/64k.mp3
河北-唐山交通文艺,https://lhttp-hw.qtfm.cn/live/1659/64k.mp3
河北-承德综合广播,https://lhttp-hw.qtfm.cn/live/20500052/64k.mp3
河北-保定1058飞扬调频汽车音乐广播,https://lhttp-hw.qtfm.cn/live/5021803/64k.mp3
河北-邢台综合广播,https://lhttp-hw.qtfm.cn/live/20211628/64k.mp3
河北-保定城市服务广播 1016为爱停留,https://lhttp-hw.qtfm.cn/live/20406/64k.mp3
河北-涉县交通音乐广播,https://lhttp-hw.qtfm.cn/live/20211631/64k.mp3
河北-河北生活广播,https://lhttp-hw.qtfm.cn/live/4867/64k.mp3
河北-石家庄经济广播,https://lhttp-hw.qtfm.cn/live/1653/64k.mp3
河北-邯郸音乐广播,https://lhttp-hw.qtfm.cn/live/4601/64k.mp3
河北-魏县鸭梨音乐广播,https://lhttp-hw.qtfm.cn/live/20212412/64k.mp3
河北-976承德交通文艺广播,https://lhttp-hw.qtfm.cn/live/15318216/64k.mp3
河北-FM93.0霸州汽车音乐广播,https://lhttp-hw.qtfm.cn/live/20211658/64k.mp3
河北-FM99.8保定经济广播,https://lhttp-hw.qtfm.cn/live/20166/64k.mp3
河北-张家口986音乐广播,https://lhttp-hw.qtfm.cn/live/5021801/64k.mp3
河北-张家口旅游广播,https://lhttp-hw.qtfm.cn/live/5021507/64k.mp3
河北-邢台交通音乐广播,https://lhttp-hw.qtfm.cn/live/15318481/64k.mp3
河北-沧州交通广播,https://lhttp-hw.qtfm.cn/live/3954/64k.mp3
河北-唐山音乐广播,https://lhttp-hw.qtfm.cn/live/4871/64k.mp3
河北-沧州1058汽车音乐广播,https://lhttp-hw.qtfm.cn/live/5021914/64k.mp3
河北-衡水综合广播,https://lhttp-hw.qtfm.cn/live/5022040/64k.mp3
河北-青春调频 FM105.4,https://lhttp-hw.qtfm.cn/live/20212203/64k.mp3
河北-久久金曲 FM99.9,https://lhttp-hw.qtfm.cn/live/20211694/64k.mp3
河北-泊头人民广播电台,https://lhttp-hw.qtfm.cn/live/20500164/64k.mp3
河北-FM873犀牛电台,https://lhttp-hw.qtfm.cn/live/20211668/64k.mp3
河北-沧州1023都市广播,https://lhttp-hw.qtfm.cn/live/5022536/64k.mp3
河北-唐山小说娱乐广播,https://lhttp-hw.qtfm.cn/live/1660/64k.mp3
河北-肥乡人民广播电台,https://lhttp-hw.qtfm.cn/live/20500104/64k.mp3
河北-承德旅游生活广播,https://lhttp-hw.qtfm.cn/live/15318158/64k.mp3
河北-肃宁融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500183/64k.mp3
河北-邢台经济生活广播,https://lhttp-hw.qtfm.cn/live/15318265/64k.mp3
河北-秦皇岛生活广播,https://lhttp-hw.qtfm.cn/live/20857/64k.mp3
河北-FM98.6邢台信都融媒广播,https://lhttp-hw.qtfm.cn/live/20500196/64k.mp3
河北-年代995,https://lhttp-hw.qtfm.cn/live/20500202/64k.mp3
河北-张家口1074综合广播,https://lhttp-hw.qtfm.cn/live/15318285/64k.mp3
河北-唐山经济生活广播,https://lhttp-hw.qtfm.cn/live/15318431/64k.mp3
河北-辛集融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/5021959/64k.mp3
河北-欢乐调频,https://lhttp-hw.qtfm.cn/live/15318317/64k.mp3
河北-沧州新闻广播,https://lhttp-hw.qtfm.cn/live/5021901/64k.mp3
河北-fm901磁县融媒综合广播,https://lhttp-hw.qtfm.cn/live/20500116/64k.mp3
河北-怀来人民广播电台 FM95.4,https://lhttp-hw.qtfm.cn/live/5022643/64k.mp3
河北-交通933,https://lhttp-hw.qtfm.cn/live/20211627/64k.mp3
河北-曲阳融媒FM90.4,https://lhttp-hw.qtfm.cn/live/20500219/64k.mp3
河北-FM106峰峰人民广播电台,https://lhttp-hw.qtfm.cn/live/20500109/64k.mp3
河北-FM106.2邢台信都融媒广播,https://lhttp-hw.qtfm.cn/live/20500096/64k.mp3
河北-崇礼综合广播,https://lhttp-hw.qtfm.cn/live/20500100/64k.mp3
河北-丰宁调频101,https://lhttp-hw.qtfm.cn/live/20211322/64k.mp3
河北-FM963景县融媒综合广播,https://lhttp-hw.qtfm.cn/live/20500192/64k.mp3
河北-广平融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500131/64k.mp3
上海-上海新闻广播,https://lhttp-hw.qtfm.cn/live/270/64k.mp3
上海-第一财经广播,https://lhttp-hw.qtfm.cn/live/276/64k.mp3
上海-上海流行音乐LoveRadio,https://lhttp-hw.qtfm.cn/live/273/64k.mp3
上海-上海动感101,https://lhttp-hw.qtfm.cn/live/274/64k.mp3
上海-上海五星体育,https://lhttp-hw.qtfm.cn/live/4928/64k.mp3
上海-长三角之声,https://lhttp-hw.qtfm.cn/live/275/64k.mp3
上海-上海交通广播电台,https://lhttp-hw.qtfm.cn/live/266/64k.mp3
上海-上海经典947,https://lhttp-hw.qtfm.cn/live/267/64k.mp3
上海-上海戏曲广播,https://lhttp-hw.qtfm.cn/live/269/64k.mp3
上海-上海沸点100音乐广播,https://lhttp-hw.qtfm.cn/live/5022341/64k.mp3
上海-上海KFM981,https://lhttp-hw.qtfm.cn/live/5022023/64k.mp3
上海-上海故事广播,https://lhttp-hw.qtfm.cn/live/268/64k.mp3
上海-闵行人民广播电台,https://lhttp-hw.qtfm.cn/live/20202/64k.mp3
上海-东上海之声FM106.5,https://lhttp-hw.qtfm.cn/live/21355/64k.mp3
上海-金山区广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/4022/64k.mp3
山西-FM107太原交通广播,https://lhttp-hw.qtfm.cn/live/4900/64k.mp3
山西-880山西交通广播,https://lhttp-hw.qtfm.cn/live/20007/64k.mp3
山西-FM1044太原经济广播,https://lhttp-hw.qtfm.cn/live/4018/64k.mp3
山西-太原老年之声广播,https://lhttp-hw.qtfm.cn/live/20211701/64k.mp3
山西-山西音乐广播,https://lhttp-hw.qtfm.cn/live/4932/64k.mp3
山西-山西综合广播FM904,https://lhttp-hw.qtfm.cn/live/20491/64k.mp3
山西-FM912太原综合广播,https://lhttp-hw.qtfm.cn/live/20006/64k.mp3
山西-山西健康之声,https://lhttp-hw.qtfm.cn/live/20470/64k.mp3
山西-FM101.5山西文艺广播,https://lhttp-hw.qtfm.cn/live/20485/64k.mp3
山西-958电台山西经济广播,https://lhttp-hw.qtfm.cn/live/20501/64k.mp3
山西-运城文艺广播,https://lhttp-hw.qtfm.cn/live/1191/64k.mp3
山西-山西故事广播,https://lhttp-hw.qtfm.cn/live/5022511/64k.mp3
山西-大同广播电视台新闻综合广播,https://lhttp-hw.qtfm.cn/live/20211690/64k.mp3
山西-阳泉综合广播,https://lhttp-hw.qtfm.cn/live/15318568/64k.mp3
山西-长治综合广播,https://lhttp-hw.qtfm.cn/live/5021874/64k.mp3
山西-运城综合广播,https://lhttp-hw.qtfm.cn/live/1190/64k.mp3
山西-大同交通广播,https://lhttp-hw.qtfm.cn/live/5022396/64k.mp3
山西-山西农村广播,https://lhttp-hw.qtfm.cn/live/1186/64k.mp3
山西-阳泉交通广播,https://lhttp-hw.qtfm.cn/live/15318165/64k.mp3
山西-FM1026太原音乐广播,https://lhttp-hw.qtfm.cn/live/1185/64k.mp3
山西-晋城新闻综合广播FM1072,https://lhttp-hw.qtfm.cn/live/1188/64k.mp3
山西-FM961喜人乐播,https://lhttp-hw.qtfm.cn/live/20210885/64k.mp3
山西-大同经济文艺广播,https://lhttp-hw.qtfm.cn/live/20211689/64k.mp3
山西-晋城交通广播,https://lhttp-hw.qtfm.cn/live/1189/64k.mp3
山西-金荔枝经典流行音乐,https://lhttp-hw.qtfm.cn/live/15318194/64k.mp3
山西-长治交通广播,https://lhttp-hw.qtfm.cn/live/5021851/64k.mp3
山西-阳泉最爱音乐台,https://lhttp-hw.qtfm.cn/live/20211652/64k.mp3
山西-平定综合广播FM101.1,https://lhttp-hw.qtfm.cn/live/5022407/64k.mp3
山西-FM104.1北岳之声,https://lhttp-hw.qtfm.cn/live/20212209/64k.mp3
山西-FM98.0屯留广播,https://lhttp-hw.qtfm.cn/live/20211667/64k.mp3
山西-FM88.7垣曲人民 广播电台,https://lhttp-hw.qtfm.cn/live/20500090/64k.mp3
山西-晋城音乐广播魅力1021,https://lhttp-hw.qtfm.cn/live/5021761/64k.mp3
山西-摩天102,https://lhttp-hw.qtfm.cn/live/20212394/64k.mp3
内蒙古-FM94.9包头综合广播,https://lhttp-hw.qtfm.cn/live/1889/64k.mp3
内蒙古-内蒙古交通之声,https://lhttp-hw.qtfm.cn/live/1884/64k.mp3
内蒙古-内蒙古音乐之声,https://lhttp-hw.qtfm.cn/live/1886/64k.mp3
内蒙古-赤峰综合广播,https://lhttp-hw.qtfm.cn/live/1896/64k.mp3
内蒙古-包头交通广播,https://lhttp-hw.qtfm.cn/live/1890/64k.mp3
内蒙古-赤峰交通广播,https://lhttp-hw.qtfm.cn/live/1899/64k.mp3
内蒙古-呼和浩特城市生活广播,https://lhttp-hw.qtfm.cn/live/5021547/64k.mp3
内蒙古-内蒙古新闻广播,https://lhttp-hw.qtfm.cn/live/1881/64k.mp3
内蒙古-内蒙古评书曲艺广播,https://lhttp-hw.qtfm.cn/live/1887/64k.mp3
内蒙古-包头文艺广播,https://lhttp-hw.qtfm.cn/live/21259/64k.mp3
内蒙古-包头汽车音乐广播,https://lhttp-hw.qtfm.cn/live/1892/64k.mp3
内蒙古-鄂尔多斯交通文体广播,https://lhttp-hw.qtfm.cn/live/20352/64k.mp3
内蒙古-内蒙古经济生活广播,https://lhttp-hw.qtfm.cn/live/1885/64k.mp3
内蒙古-内蒙古蒙古语广播,https://lhttp-hw.qtfm.cn/live/1882/64k.mp3
内蒙古-呼和浩特广播电视台文艺广播,https://lhttp-hw.qtfm.cn/live/5021437/64k.mp3
内蒙古-呼和浩特新闻综合广播,https://lhttp-hw.qtfm.cn/live/5021543/64k.mp3
内蒙古-赤峰1024,https://lhttp-hw.qtfm.cn/live/1898/64k.mp3
内蒙古-赤峰蒙古语综合广播,https://lhttp-hw.qtfm.cn/live/1897/64k.mp3
内蒙古-FM896鄂尔多斯之声,https://lhttp-hw.qtfm.cn/live/20350/64k.mp3
内蒙古-内蒙古绿野之声广播,https://lhttp-hw.qtfm.cn/live/1888/64k.mp3
内蒙古-呼和浩特交通广播,https://lhttp-hw.qtfm.cn/live/5021545/64k.mp3
内蒙古-内蒙古新闻综合广播,https://lhttp-hw.qtfm.cn/live/1883/64k.mp3
内蒙古-内蒙古草原之声广播,https://lhttp-hw.qtfm.cn/live/20973/64k.mp3
内蒙古-乌海综合广播,https://lhttp-hw.qtfm.cn/live/15318706/64k.mp3
内蒙古-阿拉善汉语综合广播,https://lhttp-hw.qtfm.cn/live/5022521/64k.mp3
内蒙古-包头广播电视台FM105.9,https://lhttp-hw.qtfm.cn/live/1891/64k.mp3
内蒙古-阿拉善蒙语综合广播,https://lhttp-hw.qtfm.cn/live/5022555/64k.mp3
内蒙古-乌海交通音乐广播,https://lhttp-hw.qtfm.cn/live/15318704/64k.mp3
内蒙古-巴彦淖尔广播电视台 综合广播,https://lhttp-hw.qtfm.cn/live/1893/64k.mp3
内蒙古-鄂尔多斯蒙语综合广播,https://lhttp-hw.qtfm.cn/live/20348/64k.mp3
内蒙古-103.9HappyRadio,https://lhttp-hw.qtfm.cn/live/4910/64k.mp3
内蒙古-呼和浩特蒙古语综合广播,https://lhttp-hw.qtfm.cn/live/20500043/64k.mp3
内蒙古-科左中旗广播电视台,https://lhttp-hw.qtfm.cn/live/20211584/64k.mp3
内蒙古-巴彦淖尔文艺生活广播,https://lhttp-hw.qtfm.cn/live/1894/64k.mp3
内蒙古-巴彦淖尔交通广播,https://lhttp-hw.qtfm.cn/live/1895/64k.mp3
内蒙古-阿荣旗广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20500193/64k.mp3
辽宁-沈阳之声,https://lhttp-hw.qtfm.cn/live/20024/64k.mp3
辽宁-辽宁交通广播FM97.5,https://lhttp-hw.qtfm.cn/live/20025/64k.mp3
辽宁-辽宁都市广播,https://lhttp-hw.qtfm.cn/live/1099/64k.mp3
辽宁-大连体育广播,https://lhttp-hw.qtfm.cn/live/1085/64k.mp3
辽宁-沈阳交通广播FM98.6,https://lhttp-hw.qtfm.cn/live/1101/64k.mp3
辽宁-抚顺交通广播,https://lhttp-hw.qtfm.cn/live/1094/64k.mp3
辽宁-沈阳生活广播,https://lhttp-hw.qtfm.cn/live/1102/64k.mp3
辽宁-辽宁资讯广播fm90.6大连分台,https://lhttp-hw.qtfm.cn/live/5022018/64k.mp3
辽宁-辽阳交通文艺广播,https://lhttp-hw.qtfm.cn/live/5022030/64k.mp3
辽宁-丹东综合广播,https://lhttp-hw.qtfm.cn/live/1090/64k.mp3
辽宁-大连都市广播,https://lhttp-hw.qtfm.cn/live/1086/64k.mp3
辽宁-辽宁乡村广播,https://lhttp-hw.qtfm.cn/live/20018/64k.mp3
辽宁-FM106.9海城综合广播,https://lhttp-hw.qtfm.cn/live/15318107/64k.mp3
辽宁-庄河广播FM97.0,https://lhttp-hw.qtfm.cn/live/5022473/64k.mp3
辽宁-瓦房店广播电视台新闻综合广播,https://lhttp-hw.qtfm.cn/live/20500094/64k.mp3
辽宁-辽宁经济广播,https://lhttp-hw.qtfm.cn/live/20019/64k.mp3
辽宁-大连1067,https://lhttp-hw.qtfm.cn/live/1084/64k.mp3
辽宁-辽宁经典音乐广播,https://lhttp-hw.qtfm.cn/live/20021/64k.mp3
辽宁-大连1043,https://lhttp-hw.qtfm.cn/live/15318307/64k.mp3
辽宁-朝阳县人民广播电台FM104,https://lhttp-hw.qtfm.cn/live/20212211/64k.mp3
辽宁-朝阳交通广播,https://lhttp-hw.qtfm.cn/live/20719/64k.mp3
辽宁-普兰店FM90.8,https://lhttp-hw.qtfm.cn/live/20212414/64k.mp3
辽宁-抚顺综合广播,https://lhttp-hw.qtfm.cn/live/20158/64k.mp3
辽宁-丹东交通广播,https://lhttp-hw.qtfm.cn/live/1091/64k.mp3
辽宁-辽宁综合广播——辽宁之声,https://lhttp-hw.qtfm.cn/live/1103/64k.mp3
辽宁-FM105.6,https://lhttp-hw.qtfm.cn/live/5022520/64k.mp3
辽宁-朝阳新闻综合广播,https://lhttp-hw.qtfm.cn/live/20715/64k.mp3
辽宁-东港融媒综合广播,https://lhttp-hw.qtfm.cn/live/5022186/64k.mp3
辽宁-辽阳综合广播,https://lhttp-hw.qtfm.cn/live/5022447/64k.mp3
辽宁-桓仁广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022699/64k.mp3
辽宁-绥中综合广播,https://lhttp-hw.qtfm.cn/live/20211705/64k.mp3
辽宁-大连广播电视台老友之声广播,https://lhttp-hw.qtfm.cn/live/1088/64k.mp3
辽宁-朝阳经济广播,https://lhttp-hw.qtfm.cn/live/5021880/64k.mp3
辽宁-新民人民广播电台,https://lhttp-hw.qtfm.cn/live/5022535/64k.mp3
辽宁-黑山人民广播电台,https://lhttp-hw.qtfm.cn/live/20500119/64k.mp3
辽宁-凌源广播电台,https://lhttp-hw.qtfm.cn/live/15318298/64k.mp3
辽宁-建平广播电视台,https://lhttp-hw.qtfm.cn/live/15318332/64k.mp3
吉林-长春交通之声,https://lhttp-hw.qtfm.cn/live/4967/64k.mp3
吉林-吉林新闻综合广播,https://lhttp-hw.qtfm.cn/live/4953/64k.mp3
吉林-吉林资讯广播,https://lhttp-hw.qtfm.cn/live/3978/64k.mp3
吉林-吉林交通广播,https://lhttp-hw.qtfm.cn/live/4945/64k.mp3
吉林-吉林市广播电视台经济广播,https://lhttp-hw.qtfm.cn/live/1823/64k.mp3
吉林-长春广播电视台 FM88.0,https://lhttp-hw.qtfm.cn/live/4850/64k.mp3
吉林-吉林市交通台 FM939,https://lhttp-hw.qtfm.cn/live/1819/64k.mp3
吉林-吉林旅游广播,https://lhttp-hw.qtfm.cn/live/20487/64k.mp3
吉林-延边新闻广播,https://lhttp-hw.qtfm.cn/live/5022488/64k.mp3
吉林-延边交通文艺广播,https://lhttp-hw.qtfm.cn/live/4889/64k.mp3
吉林-吉林音乐广播,https://lhttp-hw.qtfm.cn/live/1831/64k.mp3
吉林-吉林乡村广播,https://lhttp-hw.qtfm.cn/live/3977/64k.mp3
吉林-白山交通广播FM950,https://lhttp-hw.qtfm.cn/live/5083/64k.mp3
吉林-长春广播电视台 FM99.6,https://lhttp-hw.qtfm.cn/live/5015/64k.mp3
吉林-아리랑모바일방송,https://lhttp-hw.qtfm.cn/live/5022144/64k.mp3
吉林-松原交通文艺广播,https://lhttp-hw.qtfm.cn/live/20212256/64k.mp3
吉林-1063城市生活广播,https://lhttp-hw.qtfm.cn/live/4984/64k.mp3
吉林-吉林市音乐广播,https://lhttp-hw.qtfm.cn/live/20211679/64k.mp3
吉林-通化交通文艺广播,https://lhttp-hw.qtfm.cn/live/20500120/64k.mp3
吉林-长春新闻广播,https://lhttp-hw.qtfm.cn/live/5013/64k.mp3
吉林-吉林经济广播FM95.3AM846,https://lhttp-hw.qtfm.cn/live/3976/64k.mp3
吉林-吉林教育广播,https://lhttp-hw.qtfm.cn/live/3980/64k.mp3
吉林-1046延边旅游生活广播,https://lhttp-hw.qtfm.cn/live/5022438/64k.mp3
吉林-长春广播电视台 乐在90,https://lhttp-hw.qtfm.cn/live/5014/64k.mp3
吉林-延吉交通之声,https://lhttp-hw.qtfm.cn/live/15318331/64k.mp3
吉林-辉南综合广播,https://lhttp-hw.qtfm.cn/live/20211566/64k.mp3
吉林-吉林健康娱乐广播,https://lhttp-hw.qtfm.cn/live/4952/64k.mp3
吉林-901综合文艺广播,https://lhttp-hw.qtfm.cn/live/20211585/64k.mp3
吉林-四平交通文艺台,https://lhttp-hw.qtfm.cn/live/5022465/64k.mp3
吉林-公主岭交通之声,https://lhttp-hw.qtfm.cn/live/20212386/64k.mp3
吉林-梅河口人民广播电台城市之声,https://lhttp-hw.qtfm.cn/live/20500115/64k.mp3
吉林-梨树电台北方交通之声,https://lhttp-hw.qtfm.cn/live/5022538/64k.mp3
吉林-四平综合广播,https://lhttp-hw.qtfm.cn/live/15318197/64k.mp3
吉林-松原新闻综合广播,https://lhttp-hw.qtfm.cn/live/5079/64k.mp3
吉林-魅力FM1008,https://lhttp-hw.qtfm.cn/live/5021975/64k.mp3
吉林-CBS 파워라디오 [Music FM],https://lhttp-hw.qtfm.cn/live/15318233/64k.mp3
吉林-松原大众生活广播,https://lhttp-hw.qtfm.cn/live/5082/64k.mp3
吉林-伊通人民广播电台,https://lhttp-hw.qtfm.cn/live/20500154/64k.mp3
黑龙江-黑龙江交通广播,https://lhttp-hw.qtfm.cn/live/4973/64k.mp3
黑龙江-哈尔滨文艺广播,https://lhttp-hw.qtfm.cn/live/20083/64k.mp3
黑龙江-哈尔滨音乐广播,https://lhttp-hw.qtfm.cn/live/839/64k.mp3
黑龙江-龙广都市女性台,https://lhttp-hw.qtfm.cn/live/4968/64k.mp3
黑龙江-龙广新闻台,https://lhttp-hw.qtfm.cn/live/4974/64k.mp3
黑龙江-哈尔滨交通广播,https://lhttp-hw.qtfm.cn/live/838/64k.mp3
黑龙江-黑龙江生活广播,https://lhttp-hw.qtfm.cn/live/4970/64k.mp3
黑龙江-黑龙江老年少儿广播,https://lhttp-hw.qtfm.cn/live/4972/64k.mp3
黑龙江-黑龙江高校广播,https://lhttp-hw.qtfm.cn/live/4976/64k.mp3
黑龙江-哈尔滨广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20077/64k.mp3
黑龙江-黑龙江音乐广播,https://lhttp-hw.qtfm.cn/live/4969/64k.mp3
黑龙江-牡丹江综合广播,https://lhttp-hw.qtfm.cn/live/5022434/64k.mp3
黑龙江-哈尔滨经济广播,https://lhttp-hw.qtfm.cn/live/837/64k.mp3
黑龙江-牡丹江交通广播,https://lhttp-hw.qtfm.cn/live/5022354/64k.mp3
黑龙江-冰城1026哈尔滨古典音乐广播,https://lhttp-hw.qtfm.cn/live/5022338/64k.mp3
黑龙江-大庆交通广播,https://lhttp-hw.qtfm.cn/live/20500061/64k.mp3
黑龙江-齐齐哈尔综合广播,https://lhttp-hw.qtfm.cn/live/20500133/64k.mp3
黑龙江-牡丹江经济广播,https://lhttp-hw.qtfm.cn/live/5022435/64k.mp3
黑龙江-鸡西交通广播,https://lhttp-hw.qtfm.cn/live/20500087/64k.mp3
黑龙江-大兴安岭综合广播,https://lhttp-hw.qtfm.cn/live/20500057/64k.mp3
黑龙江-大庆综合广播,https://lhttp-hw.qtfm.cn/live/20500060/64k.mp3
黑龙江-佳木斯经济广播,https://lhttp-hw.qtfm.cn/live/20500027/64k.mp3
黑龙江-大庆音乐广播,https://lhttp-hw.qtfm.cn/live/20500212/64k.mp3
黑龙江-佳木斯文艺交通广播,https://lhttp-hw.qtfm.cn/live/20500022/64k.mp3
黑龙江-鸡西综合广播,https://lhttp-hw.qtfm.cn/live/20500089/64k.mp3
黑龙江-黑河人民广播电台,https://lhttp-hw.qtfm.cn/live/5073/64k.mp3
黑龙江-冰城融媒体电台,https://lhttp-hw.qtfm.cn/live/20212259/64k.mp3
江苏-江苏新闻广播,https://lhttp-hw.qtfm.cn/live/4944/64k.mp3
江苏-江苏经典流行音乐,https://lhttp-hw.qtfm.cn/live/4938/64k.mp3
江苏-江苏交通广播,https://lhttp-hw.qtfm.cn/live/4054/64k.mp3
江苏-苏州音乐广播,https://lhttp-hw.qtfm.cn/live/2803/64k.mp3
江苏-苏州交通广播,https://lhttp-hw.qtfm.cn/live/2806/64k.mp3
江苏-苏州新闻广播,https://lhttp-hw.qtfm.cn/live/2808/64k.mp3
江苏-无锡新闻广播,https://lhttp-hw.qtfm.cn/live/2777/64k.mp3
江苏-无锡音乐广播,https://lhttp-hw.qtfm.cn/live/2779/64k.mp3
江苏-无锡梁溪之声,https://lhttp-hw.qtfm.cn/live/2782/64k.mp3
江苏-江苏音乐广播PlayFM897,https://lhttp-hw.qtfm.cn/live/4936/64k.mp3
江苏-徐州新闻综合广播,https://lhttp-hw.qtfm.cn/live/4922/64k.mp3
江苏-南京音乐广播,https://lhttp-hw.qtfm.cn/live/4963/64k.mp3
江苏-常熟新闻广播,https://lhttp-hw.qtfm.cn/live/2792/64k.mp3
江苏-无锡都市生活广播,https://lhttp-hw.qtfm.cn/live/2783/64k.mp3
江苏-常熟广播声动1008,https://lhttp-hw.qtfm.cn/live/2791/64k.mp3
江苏-江苏故事广播,https://lhttp-hw.qtfm.cn/live/20012/64k.mp3
江苏-南通交通广播,https://lhttp-hw.qtfm.cn/live/5021533/64k.mp3
江苏-徐州经典音乐FM942,https://lhttp-hw.qtfm.cn/live/15318160/64k.mp3
江苏-江苏财经广播,https://lhttp-hw.qtfm.cn/live/20015/64k.mp3
江苏-苏州儿童广播,https://lhttp-hw.qtfm.cn/live/2807/64k.mp3
江苏-苏州生活广播,https://lhttp-hw.qtfm.cn/live/2801/64k.mp3
江苏-南通音乐广播,https://lhttp-hw.qtfm.cn/live/21275/64k.mp3
江苏-997金陵之声,https://lhttp-hw.qtfm.cn/live/5056/64k.mp3
江苏-无锡交通广播,https://lhttp-hw.qtfm.cn/live/2780/64k.mp3
江苏-扬州新闻广播,https://lhttp-hw.qtfm.cn/live/5000/64k.mp3
江苏-澎湃907,https://lhttp-hw.qtfm.cn/live/2789/64k.mp3
江苏-江苏新闻综合广播,https://lhttp-hw.qtfm.cn/live/5055/64k.mp3
江苏-南通新闻广播,https://lhttp-hw.qtfm.cn/live/21277/64k.mp3
江苏-徐州音乐广播FM91.9,https://lhttp-hw.qtfm.cn/live/4923/64k.mp3
江苏-常州新闻广播,https://lhttp-hw.qtfm.cn/live/2798/64k.mp3
江苏-徐州交通广播,https://lhttp-hw.qtfm.cn/live/4924/64k.mp3
江苏-江苏文艺广播,https://lhttp-hw.qtfm.cn/live/20013/64k.mp3
江苏-无锡经济广播,https://lhttp-hw.qtfm.cn/live/2778/64k.mp3
江苏-常州音乐广播,https://lhttp-hw.qtfm.cn/live/2799/64k.mp3
江苏-江苏健康广播,https://lhttp-hw.qtfm.cn/live/20014/64k.mp3
江苏-宁听FM885,https://lhttp-hw.qtfm.cn/live/20500075/64k.mp3
江苏-FM89.1吴江综合广播,https://lhttp-hw.qtfm.cn/live/5022050/64k.mp3
江苏-宿迁交通广播,https://lhttp-hw.qtfm.cn/live/5004/64k.mp3
江苏-无锡新闻综合广播,https://lhttp-hw.qtfm.cn/live/2776/64k.mp3
江苏-FM104镇江综合广播,https://lhttp-hw.qtfm.cn/live/3984/64k.mp3
江苏-张家港市融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/5021877/64k.mp3
江苏-常州交通广播,https://lhttp-hw.qtfm.cn/live/2796/64k.mp3
江苏-如东新闻综合广播,https://lhttp-hw.qtfm.cn/live/20579/64k.mp3
江苏-979丹阳之声,https://lhttp-hw.qtfm.cn/live/20207749/64k.mp3
江苏-常州经济广播,https://lhttp-hw.qtfm.cn/live/2794/64k.mp3
江苏-淮安新闻综合,https://lhttp-hw.qtfm.cn/live/4589/64k.mp3
江苏-靖江交通音乐广播,https://lhttp-hw.qtfm.cn/live/15318120/64k.mp3
江苏-邳州人民广播电台,https://lhttp-hw.qtfm.cn/live/2809/64k.mp3
江苏-扬州交通广播,https://lhttp-hw.qtfm.cn/live/2804/64k.mp3
江苏-苏州戏曲广播,https://lhttp-hw.qtfm.cn/live/20211622/64k.mp3
江苏-淮安交通文艺,https://lhttp-hw.qtfm.cn/live/4586/64k.mp3
江苏-连云港交通广播,https://lhttp-hw.qtfm.cn/live/2775/64k.mp3
江苏-大丰FM95.1,https://lhttp-hw.qtfm.cn/live/20211708/64k.mp3
江苏-FM98.8 盐城综合广播,https://lhttp-hw.qtfm.cn/live/20330/64k.mp3
江苏-FM96.3镇江文艺广播,https://lhttp-hw.qtfm.cn/live/4605/64k.mp3
江苏-盐城广播FM88.2,https://lhttp-hw.qtfm.cn/live/20332/64k.mp3
江苏-扬州电台江都广播,https://lhttp-hw.qtfm.cn/live/5022636/64k.mp3
江苏-扬州YESFM949,https://lhttp-hw.qtfm.cn/live/2805/64k.mp3
江苏-宜兴交通台,https://lhttp-hw.qtfm.cn/live/3982/64k.mp3
江苏-FM96.7,https://lhttp-hw.qtfm.cn/live/20211632/64k.mp3
江苏-FM88.8镇江交通广播,https://lhttp-hw.qtfm.cn/live/3985/64k.mp3
江苏-东台广电FM96.3,https://lhttp-hw.qtfm.cn/live/20212392/64k.mp3
江苏-金湖人民广播电台,https://lhttp-hw.qtfm.cn/live/15318464/64k.mp3
江苏-滨海1029,https://lhttp-hw.qtfm.cn/live/20207779/64k.mp3
江苏-FM90.5镇江经济广播,https://lhttp-hw.qtfm.cn/live/5006/64k.mp3
江苏-阜宁人民广播,https://lhttp-hw.qtfm.cn/live/20207753/64k.mp3
江苏-宿豫人民广播电台,https://lhttp-hw.qtfm.cn/live/5005/64k.mp3
江苏-淮安FM104.2,https://lhttp-hw.qtfm.cn/live/4588/64k.mp3
江苏-淮安经济生活,https://lhttp-hw.qtfm.cn/live/4587/64k.mp3
江苏-盐城音乐广播,https://lhttp-hw.qtfm.cn/live/5022380/64k.mp3
江苏-如皋汽车广播,https://lhttp-hw.qtfm.cn/live/20207734/64k.mp3
江苏-宿迁汽车音乐台,https://lhttp-hw.qtfm.cn/live/21265/64k.mp3
江苏-淮安经典992,https://lhttp-hw.qtfm.cn/live/15318398/64k.mp3
江苏-南通私家车广播,https://lhttp-hw.qtfm.cn/live/21327/64k.mp3
江苏-仪征人民广播电台 FM94.3,https://lhttp-hw.qtfm.cn/live/15318182/64k.mp3
江苏-海门交通音乐电台,https://lhttp-hw.qtfm.cn/live/5022640/64k.mp3
江苏-淮安车生活广播,https://lhttp-hw.qtfm.cn/live/5021970/64k.mp3
江苏-886武进之声,https://lhttp-hw.qtfm.cn/live/20150/64k.mp3
江苏-盐城交通广播,https://lhttp-hw.qtfm.cn/live/20326/64k.mp3
江苏-太仓人民广播电台,https://lhttp-hw.qtfm.cn/live/20207759/64k.mp3
江苏-睢宁县融媒体中心综合广播 FM93.1,https://lhttp-hw.qtfm.cn/live/20500191/64k.mp3
江苏-通州人民广播电台,https://lhttp-hw.qtfm.cn/live/20211586/64k.mp3
江苏-宝应人民广播电台,https://lhttp-hw.qtfm.cn/live/5022457/64k.mp3
江苏-昆山人民广播电台,https://lhttp-hw.qtfm.cn/live/20500128/64k.mp3
江苏-盱眙县融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500051/64k.mp3
江苏-赣榆区融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500216/64k.mp3
江苏-沛县综合广播,https://lhttp-hw.qtfm.cn/live/20500173/64k.mp3
浙江-FM93浙江交通之声,https://lhttp-hw.qtfm.cn/live/4522/64k.mp3
浙江-杭州交通91.8电台,https://lhttp-hw.qtfm.cn/live/1133/64k.mp3
浙江-浙江之声,https://lhttp-hw.qtfm.cn/live/4518/64k.mp3
浙江-西湖之声,https://lhttp-hw.qtfm.cn/live/1163/64k.mp3
浙江-浙江FM99.6,https://lhttp-hw.qtfm.cn/live/4521/64k.mp3
浙江-嘉兴交通广播,https://lhttp-hw.qtfm.cn/live/1135/64k.mp3
浙江-浙江经济广播,https://lhttp-hw.qtfm.cn/live/4519/64k.mp3
浙江-浙江音乐调频,https://lhttp-hw.qtfm.cn/live/4866/64k.mp3
浙江-FM103.5湖州经济广播,https://lhttp-hw.qtfm.cn/live/2812/64k.mp3
浙江-FM104.5旅游之声,https://lhttp-hw.qtfm.cn/live/4524/64k.mp3
浙江-嘉兴综合广播,https://lhttp-hw.qtfm.cn/live/1154/64k.mp3
浙江-杭州FM90.7,https://lhttp-hw.qtfm.cn/live/15318146/64k.mp3
浙江-宁波新闻综合广播,https://lhttp-hw.qtfm.cn/live/1138/64k.mp3
浙江-宁波经济广播,https://lhttp-hw.qtfm.cn/live/1152/64k.mp3
浙江-宁波交通广播,https://lhttp-hw.qtfm.cn/live/1140/64k.mp3
浙江-东阳城市广播,https://lhttp-hw.qtfm.cn/live/21181/64k.mp3
浙江-嘉兴音乐广播,https://lhttp-hw.qtfm.cn/live/1136/64k.mp3
浙江-1003温州音乐之声,https://lhttp-hw.qtfm.cn/live/1149/64k.mp3
浙江-FM105湖州之声,https://lhttp-hw.qtfm.cn/live/2810/64k.mp3
浙江-温州交通广播,https://lhttp-hw.qtfm.cn/live/1156/64k.mp3
浙江-瑞安人民广播,https://lhttp-hw.qtfm.cn/live/1143/64k.mp3
浙江-杭州之声,https://lhttp-hw.qtfm.cn/live/1134/64k.mp3
浙江-永康人民广播电台,https://lhttp-hw.qtfm.cn/live/5022570/64k.mp3
浙江-1047 Nice FM,https://lhttp-hw.qtfm.cn/live/20033/64k.mp3
浙江-FM998 舟山新闻综合广播,https://lhttp-hw.qtfm.cn/live/1160/64k.mp3
浙江-桐乡之声,https://lhttp-hw.qtfm.cn/live/5021791/64k.mp3
浙江-台州交通广播,https://lhttp-hw.qtfm.cn/live/1146/64k.mp3
浙江-温州新闻广播,https://lhttp-hw.qtfm.cn/live/1155/64k.mp3
浙江-义乌新闻广播,https://lhttp-hw.qtfm.cn/live/20537/64k.mp3
浙江-慈溪经典车电台,https://lhttp-hw.qtfm.cn/live/5021401/64k.mp3
浙江-湖州交通文艺广播,https://lhttp-hw.qtfm.cn/live/2811/64k.mp3
浙江-100.1 PLAY FM,https://lhttp-hw.qtfm.cn/live/20035/64k.mp3
浙江-温州经济广播,https://lhttp-hw.qtfm.cn/live/1157/64k.mp3
浙江-FM93.6绍兴综合广播,https://lhttp-hw.qtfm.cn/live/5052/64k.mp3
浙江-中波954老朋友广播,https://lhttp-hw.qtfm.cn/live/1132/64k.mp3
浙江-温岭1036电台,https://lhttp-hw.qtfm.cn/live/4567/64k.mp3
浙江-义乌交通广播,https://lhttp-hw.qtfm.cn/live/20533/64k.mp3
浙江-台州新闻综合 ,https://lhttp-hw.qtfm.cn/live/1145/64k.mp3
浙江-宁波音乐广播私家车986,https://lhttp-hw.qtfm.cn/live/1142/64k.mp3
浙江-乐清人民广播电台,https://lhttp-hw.qtfm.cn/live/20204/64k.mp3
浙江-1052LoveRadio,https://lhttp-hw.qtfm.cn/live/5022061/64k.mp3
浙江-台州音乐广播,https://lhttp-hw.qtfm.cn/live/1144/64k.mp3
浙江-柯桥调频广播电台FM106.8,https://lhttp-hw.qtfm.cn/live/2422/64k.mp3
浙江-FM96大潮之声,https://lhttp-hw.qtfm.cn/live/5022556/64k.mp3
浙江-FM97 舟山交通音乐广播,https://lhttp-hw.qtfm.cn/live/1161/64k.mp3
浙江-嵊州电台FM100.3,https://lhttp-hw.qtfm.cn/live/20500010/64k.mp3
浙江-诸暨人民广播电台,https://lhttp-hw.qtfm.cn/live/5022482/64k.mp3
浙江-FM89.8临海人民广播电台,https://lhttp-hw.qtfm.cn/live/5022437/64k.mp3
浙江-1008可乐台,https://lhttp-hw.qtfm.cn/live/1153/64k.mp3
浙江-FM94.1绍兴交通广播,https://lhttp-hw.qtfm.cn/live/5053/64k.mp3
浙江-FM989宁海新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022406/64k.mp3
浙江-衢州新闻综合广播,https://lhttp-hw.qtfm.cn/live/20444/64k.mp3
浙江-新昌人民广播电台,https://lhttp-hw.qtfm.cn/live/20212423/64k.mp3
浙江-萧山人民广播电台,https://lhttp-hw.qtfm.cn/live/20500184/64k.mp3
浙江-1022永嘉人民广播电台,https://lhttp-hw.qtfm.cn/live/15318231/64k.mp3
浙江-玉环广播电台,https://lhttp-hw.qtfm.cn/live/20212390/64k.mp3
浙江-FM93.8,https://lhttp-hw.qtfm.cn/live/1158/64k.mp3
浙江-FM103.5绍兴音乐广播,https://lhttp-hw.qtfm.cn/live/5054/64k.mp3
浙江-天台电台FM91.1,https://lhttp-hw.qtfm.cn/live/5022200/64k.mp3
浙江-FM954龙游电台,https://lhttp-hw.qtfm.cn/live/15318359/64k.mp3
浙江-衢州交通音乐广播,https://lhttp-hw.qtfm.cn/live/20442/64k.mp3
浙江-FM97.3太湖之声,https://lhttp-hw.qtfm.cn/live/5022311/64k.mp3
浙江-96.4临安人民广播电台,https://lhttp-hw.qtfm.cn/live/20005/64k.mp3
浙江-杭州华语之声,https://lhttp-hw.qtfm.cn/live/20505/64k.mp3
浙江-三门广播电台,https://lhttp-hw.qtfm.cn/live/15318638/64k.mp3
浙江-FM106.5德清之声,https://lhttp-hw.qtfm.cn/live/5022033/64k.mp3
浙江-FM105平阳电台,https://lhttp-hw.qtfm.cn/live/5022624/64k.mp3
浙江-浦江人民广播电台,https://lhttp-hw.qtfm.cn/live/5021924/64k.mp3
浙江-FM101仙居融媒体广播,https://lhttp-hw.qtfm.cn/live/5021908/64k.mp3
浙江-兰溪电台FM90.8,https://lhttp-hw.qtfm.cn/live/5022526/64k.mp3
安徽-安徽交通广播,https://lhttp-hw.qtfm.cn/live/1949/64k.mp3
安徽-安徽综合广播,https://lhttp-hw.qtfm.cn/live/4919/64k.mp3
安徽-宿州文艺广播,https://lhttp-hw.qtfm.cn/live/5022400/64k.mp3
安徽-安庆综合广播,https://lhttp-hw.qtfm.cn/live/1965/64k.mp3
安徽-安徽音乐广播,https://lhttp-hw.qtfm.cn/live/1947/64k.mp3
安徽-芜湖综合广播,https://lhttp-hw.qtfm.cn/live/5029/64k.mp3
安徽-芜湖交通经济广播,https://lhttp-hw.qtfm.cn/live/5027/64k.mp3
安徽-安徽生活广播,https://lhttp-hw.qtfm.cn/live/1948/64k.mp3
安徽-安徽农村广播,https://lhttp-hw.qtfm.cn/live/1950/64k.mp3
安徽-经典983电台,https://lhttp-hw.qtfm.cn/live/20211575/64k.mp3
安徽-宿州新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022399/64k.mp3
安徽-黄山新闻综合广播,https://lhttp-hw.qtfm.cn/live/1968/64k.mp3
安徽-安徽老年广播,https://lhttp-hw.qtfm.cn/live/1951/64k.mp3
安徽-滁州旅游交通广播,https://lhttp-hw.qtfm.cn/live/5020/64k.mp3
安徽-合肥故事广播,https://lhttp-hw.qtfm.cn/live/1961/64k.mp3
安徽-铜陵新闻综合广播,https://lhttp-hw.qtfm.cn/live/21303/64k.mp3
安徽-安徽戏曲广播,https://lhttp-hw.qtfm.cn/live/1952/64k.mp3
安徽-合肥新闻综合广播,https://lhttp-hw.qtfm.cn/live/20212380/64k.mp3
安徽-MUSIC876,https://lhttp-hw.qtfm.cn/live/1975/64k.mp3
安徽-颍上FM962,https://lhttp-hw.qtfm.cn/live/20500039/64k.mp3
安徽-合肥交通广播,https://lhttp-hw.qtfm.cn/live/1960/64k.mp3
安徽-亳州新闻综合广播,https://lhttp-hw.qtfm.cn/live/20207787/64k.mp3
安徽-安庆交通音乐广播,https://lhttp-hw.qtfm.cn/live/1966/64k.mp3
安徽-烈山电台南湖之声,https://lhttp-hw.qtfm.cn/live/15318117/64k.mp3
安徽-阜阳综合广播,https://lhttp-hw.qtfm.cn/live/1970/64k.mp3
安徽-宣城交通1061,https://lhttp-hw.qtfm.cn/live/5023/64k.mp3
安徽-芜湖音乐故事广播,https://lhttp-hw.qtfm.cn/live/5028/64k.mp3
安徽-安徽经济广播,https://lhttp-hw.qtfm.cn/live/4916/64k.mp3
安徽-FM963界首之声（界首新闻综合广播）,https://lhttp-hw.qtfm.cn/live/20207785/64k.mp3
安徽-天长人民广播电台,https://lhttp-hw.qtfm.cn/live/4854/64k.mp3
安徽-临泉交通音乐广播,https://lhttp-hw.qtfm.cn/live/15318699/64k.mp3
安徽-池州新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022373/64k.mp3
安徽-怀远之声,https://lhttp-hw.qtfm.cn/live/5021993/64k.mp3
安徽-安徽旅游广播高速之声,https://lhttp-hw.qtfm.cn/live/15318219/64k.mp3
安徽-淮北交通广播,https://lhttp-hw.qtfm.cn/live/20211647/64k.mp3
安徽-淮北综合广播,https://lhttp-hw.qtfm.cn/live/20211648/64k.mp3
安徽-黄山交通旅游广播,https://lhttp-hw.qtfm.cn/live/1969/64k.mp3
安徽-阜阳经济广播,https://lhttp-hw.qtfm.cn/live/5022571/64k.mp3
安徽-滁州综合广播,https://lhttp-hw.qtfm.cn/live/5019/64k.mp3
安徽-包河之声电台,https://lhttp-hw.qtfm.cn/live/5022668/64k.mp3
安徽-太和县广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/15318579/64k.mp3
安徽-铜陵交通生活广播,https://lhttp-hw.qtfm.cn/live/21305/64k.mp3
安徽-宣城广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022/64k.mp3
安徽-滁州文艺广播,https://lhttp-hw.qtfm.cn/live/15318404/64k.mp3
安徽-淮南音乐故事广播,https://lhttp-hw.qtfm.cn/live/5021669/64k.mp3
安徽-阜阳交通广播,https://lhttp-hw.qtfm.cn/live/1971/64k.mp3
安徽-天井湖之声FM1024,https://lhttp-hw.qtfm.cn/live/5021979/64k.mp3
安徽-淮南交通广播,https://lhttp-hw.qtfm.cn/live/4843/64k.mp3
安徽-固镇人民广播电台,https://lhttp-hw.qtfm.cn/live/20500125/64k.mp3
安徽-亳州交通音乐广播,https://lhttp-hw.qtfm.cn/live/20212419/64k.mp3
安徽-池州交通旅游广播(fm96.6),https://lhttp-hw.qtfm.cn/live/4839/64k.mp3
福建-福建新闻广播,https://lhttp-hw.qtfm.cn/live/1731/64k.mp3
福建-泉州904交通之声,https://lhttp-hw.qtfm.cn/live/15318189/64k.mp3
福建-厦门音乐广播,https://lhttp-hw.qtfm.cn/live/1739/64k.mp3
福建-泉州广播电视台889新闻综合广播,https://lhttp-hw.qtfm.cn/live/15318346/64k.mp3
福建-厦门综合广播,https://lhttp-hw.qtfm.cn/live/1737/64k.mp3
福建-厦门经济交通广播,https://lhttp-hw.qtfm.cn/live/1738/64k.mp3
福建-福建987私家车广播,https://lhttp-hw.qtfm.cn/live/1736/64k.mp3
福建-福建经济广播,https://lhttp-hw.qtfm.cn/live/1732/64k.mp3
福建-厦门闽南之声广播,https://lhttp-hw.qtfm.cn/live/1740/64k.mp3
福建-泉州刺桐之声,https://lhttp-hw.qtfm.cn/live/5022360/64k.mp3
福建-893音乐广播,https://lhttp-hw.qtfm.cn/live/4846/64k.mp3
福建-福建交通广播,https://lhttp-hw.qtfm.cn/live/1733/64k.mp3
福建-福州人民广播电台左海之声,https://lhttp-hw.qtfm.cn/live/3937/64k.mp3
福建-福建音乐广播,https://lhttp-hw.qtfm.cn/live/4585/64k.mp3
福建-福州交通之声,https://lhttp-hw.qtfm.cn/live/5026/64k.mp3
福建-福州新闻广播,https://lhttp-hw.qtfm.cn/live/5025/64k.mp3
福建-漳州人民广播电台综合广播,https://lhttp-hw.qtfm.cn/live/1742/64k.mp3
福建-海峡之声广播电台,https://lhttp-hw.qtfm.cn/live/1744/64k.mp3
福建-FM94厦门旅游广播,https://lhttp-hw.qtfm.cn/live/1741/64k.mp3
福建-FM881南安广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5021731/64k.mp3
福建-龙岩旅游之声,https://lhttp-hw.qtfm.cn/live/20711/64k.mp3
福建-龙岩电台综合广播,https://lhttp-hw.qtfm.cn/live/20709/64k.mp3
福建-三明新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022100/64k.mp3
福建-漳州人民广播电台交通广播,https://lhttp-hw.qtfm.cn/live/1743/64k.mp3
福建-厦门892集美广播,https://lhttp-hw.qtfm.cn/live/5022479/64k.mp3
福建-永安广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/15318388/64k.mp3
福建-中国华艺广播公司,https://lhttp-hw.qtfm.cn/live/20500139/64k.mp3
福建-安溪人民广播电台,https://lhttp-hw.qtfm.cn/live/5022135/64k.mp3
福建-漳浦广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022658/64k.mp3
福建-沙溪之声995,https://lhttp-hw.qtfm.cn/live/5021998/64k.mp3
福建-云霄人民广播电台,https://lhttp-hw.qtfm.cn/live/20500106/64k.mp3
福建-尤溪1066,https://lhttp-hw.qtfm.cn/live/5022498/64k.mp3
福建-诏安广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20500186/64k.mp3
江西-江西新闻广播,https://lhttp-hw.qtfm.cn/live/1809/64k.mp3
江西-江西音乐广播,https://lhttp-hw.qtfm.cn/live/1802/64k.mp3
江西-南昌交通广播,https://lhttp-hw.qtfm.cn/live/1804/64k.mp3
江西-赣州综合广播,https://lhttp-hw.qtfm.cn/live/20266/64k.mp3
江西-江西都市广播FM106.5,https://lhttp-hw.qtfm.cn/live/1810/64k.mp3
江西-江西旅游广播FM97.4,https://lhttp-hw.qtfm.cn/live/20133/64k.mp3
江西-江西交通广播,https://lhttp-hw.qtfm.cn/live/1811/64k.mp3
江西-江西潮台969,https://lhttp-hw.qtfm.cn/live/20500092/64k.mp3
江西-南康交通广播,https://lhttp-hw.qtfm.cn/live/5021869/64k.mp3
江西-934上饶新闻综合广播,https://lhttp-hw.qtfm.cn/live/1808/64k.mp3
江西-九江交通广播,https://lhttp-hw.qtfm.cn/live/5021918/64k.mp3
江西-FM103.2鹰潭交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022036/64k.mp3
江西-江西民生广播,https://lhttp-hw.qtfm.cn/live/1813/64k.mp3
江西-瓷都交通音乐广播,https://lhttp-hw.qtfm.cn/live/5021829/64k.mp3
江西-九江新闻综合900红调频,https://lhttp-hw.qtfm.cn/live/5022729/64k.mp3
江西-江西绿色985,https://lhttp-hw.qtfm.cn/live/4606/64k.mp3
江西-萍乡交通文艺广播,https://lhttp-hw.qtfm.cn/live/5022409/64k.mp3
江西-FM94.5赣州交通音乐广播,https://lhttp-hw.qtfm.cn/live/4942/64k.mp3
江西-新余交通广播,https://lhttp-hw.qtfm.cn/live/20093/64k.mp3
江西-景德镇新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022025/64k.mp3
江西-江西财经广播（成功992）,https://lhttp-hw.qtfm.cn/live/5021665/64k.mp3
江西-萍乡电台综合广播FM106.8,https://lhttp-hw.qtfm.cn/live/5022455/64k.mp3
江西-吉安庐陵之声,https://lhttp-hw.qtfm.cn/live/20500091/64k.mp3
江西-丰城之声FM88.4,https://lhttp-hw.qtfm.cn/live/20500071/64k.mp3
江西-上饶交通音乐广播,https://lhttp-hw.qtfm.cn/live/20211707/64k.mp3
江西-新余新闻广播,https://lhttp-hw.qtfm.cn/live/20178/64k.mp3
江西-九江文化旅游广播,https://lhttp-hw.qtfm.cn/live/20212210/64k.mp3
江西-广丰909音乐电台,https://lhttp-hw.qtfm.cn/live/5022381/64k.mp3
江西-FM99.2赣州农村科教广播,https://lhttp-hw.qtfm.cn/live/4941/64k.mp3
江西-宜春交通音乐广播,https://lhttp-hw.qtfm.cn/live/20212206/64k.mp3
江西-FM104.8鹰潭新闻综合频率,https://lhttp-hw.qtfm.cn/live/5022035/64k.mp3
江西-赣北之声FM94.2,https://lhttp-hw.qtfm.cn/live/5022648/64k.mp3
江西-高安电台942,https://lhttp-hw.qtfm.cn/live/20500014/64k.mp3
江西-宜春新闻综合广播,https://lhttp-hw.qtfm.cn/live/20212205/64k.mp3
山东-济南新闻广播,https://lhttp-hw.qtfm.cn/live/1667/64k.mp3
山东-济南经济广播,https://lhttp-hw.qtfm.cn/live/1668/64k.mp3
山东-青岛新闻广播,https://lhttp-hw.qtfm.cn/live/1673/64k.mp3
山东-山东广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20234/64k.mp3
山东-青岛交通广播,https://lhttp-hw.qtfm.cn/live/1676/64k.mp3
山东-济南交通广播,https://lhttp-hw.qtfm.cn/live/1669/64k.mp3
山东-济南故事广播,https://lhttp-hw.qtfm.cn/live/1672/64k.mp3
山东-山东经济广播,https://lhttp-hw.qtfm.cn/live/20236/64k.mp3
山东-青岛广播爱车940,https://lhttp-hw.qtfm.cn/live/5022537/64k.mp3
山东-都市101经济广播,https://lhttp-hw.qtfm.cn/live/3995/64k.mp3
山东-山东经典音乐广播,https://lhttp-hw.qtfm.cn/live/20240/64k.mp3
山东-山东交通广播,https://lhttp-hw.qtfm.cn/live/20242/64k.mp3
山东-崂山921,https://lhttp-hw.qtfm.cn/live/20212426/64k.mp3
山东-FM92.6 综合广播,https://lhttp-hw.qtfm.cn/live/20176/64k.mp3
山东-山东体育休闲广播·山东旅游广播,https://lhttp-hw.qtfm.cn/live/20246/64k.mp3
山东-淄博私家车广播  FM106.7,https://lhttp-hw.qtfm.cn/live/1679/64k.mp3
山东-山东音乐广播,https://lhttp-hw.qtfm.cn/live/1665/64k.mp3
山东-临沂综合广播,https://lhttp-hw.qtfm.cn/live/3992/64k.mp3
山东-淄博综合广播,https://lhttp-hw.qtfm.cn/live/1678/64k.mp3
山东-胶州875,https://lhttp-hw.qtfm.cn/live/20211644/64k.mp3
山东-济南音乐广播FM88.7,https://lhttp-hw.qtfm.cn/live/1671/64k.mp3
山东-青岛经济广播,https://lhttp-hw.qtfm.cn/live/1674/64k.mp3
山东-FM95.2青岛故事广播,https://lhttp-hw.qtfm.cn/live/4956/64k.mp3
山东-青岛文艺广播,https://lhttp-hw.qtfm.cn/live/1675/64k.mp3
山东-山东文艺广播,https://lhttp-hw.qtfm.cn/live/20238/64k.mp3
山东-936私家车广播,https://lhttp-hw.qtfm.cn/live/1670/64k.mp3
山东-东营交通音乐广播FM98.4,https://lhttp-hw.qtfm.cn/live/20142/64k.mp3
山东-济宁交通广播,https://lhttp-hw.qtfm.cn/live/20087/64k.mp3
山东-FM107潍坊交通广播,https://lhttp-hw.qtfm.cn/live/4014/64k.mp3
山东-即墨融媒综合广播,https://lhttp-hw.qtfm.cn/live/20807/64k.mp3
山东-高密955,https://lhttp-hw.qtfm.cn/live/20212417/64k.mp3
山东-聊城交通广播,https://lhttp-hw.qtfm.cn/live/5022263/64k.mp3
山东-经典音乐广播FM94.8,https://lhttp-hw.qtfm.cn/live/20500097/64k.mp3
山东-枣庄综合广播,https://lhttp-hw.qtfm.cn/live/1686/64k.mp3
山东-烟台音乐广播FM105.9,https://lhttp-hw.qtfm.cn/live/1683/64k.mp3
山东-FM898汽车音乐广播,https://lhttp-hw.qtfm.cn/live/5022382/64k.mp3
山东-聊城新闻广播,https://lhttp-hw.qtfm.cn/live/5022264/64k.mp3
山东-青岛音乐体育广播,https://lhttp-hw.qtfm.cn/live/1677/64k.mp3
山东-淄博交通音乐广播,https://lhttp-hw.qtfm.cn/live/1680/64k.mp3
山东-烟台综合广播FM101,https://lhttp-hw.qtfm.cn/live/1682/64k.mp3
山东-枣庄交通文艺广播,https://lhttp-hw.qtfm.cn/live/1688/64k.mp3
山东-烟台交通广播FM103,https://lhttp-hw.qtfm.cn/live/1684/64k.mp3
山东-威海新闻电台,https://lhttp-hw.qtfm.cn/live/20669/64k.mp3
山东-临沂交通旅游广播,https://lhttp-hw.qtfm.cn/live/3993/64k.mp3
山东-FM88.1潍坊音乐广播,https://lhttp-hw.qtfm.cn/live/15318631/64k.mp3
山东-滕州广播电视台FM99.8,https://lhttp-hw.qtfm.cn/live/5022611/64k.mp3
山东-潍坊新闻广播,https://lhttp-hw.qtfm.cn/live/20320/64k.mp3
山东-动感955,https://lhttp-hw.qtfm.cn/live/1689/64k.mp3
山东-财富932私家车广播,https://lhttp-hw.qtfm.cn/live/3994/64k.mp3
山东-潍坊1008城市之声,https://lhttp-hw.qtfm.cn/live/20211696/64k.mp3
山东-潍坊982广播电台,https://lhttp-hw.qtfm.cn/live/4865/64k.mp3
山东-菏泽交通广播,https://lhttp-hw.qtfm.cn/live/20212294/64k.mp3
山东-聊城经济广播,https://lhttp-hw.qtfm.cn/live/5022262/64k.mp3
山东-潍坊933经济广播,https://lhttp-hw.qtfm.cn/live/20839/64k.mp3
山东-FM90.7威海音乐广播,https://lhttp-hw.qtfm.cn/live/15318612/64k.mp3
山东-FM96.1邹城之声,https://lhttp-hw.qtfm.cn/live/20207732/64k.mp3
山东-菏泽新闻广播,https://lhttp-hw.qtfm.cn/live/20212293/64k.mp3
山东-FM92.4安丘924,https://lhttp-hw.qtfm.cn/live/20212216/64k.mp3
山东-泰安人民广播电台,https://lhttp-hw.qtfm.cn/live/20500185/64k.mp3
山东-FM101.8济宁综合广播,https://lhttp-hw.qtfm.cn/live/4901/64k.mp3
山东-枣庄经济生活广播,https://lhttp-hw.qtfm.cn/live/1687/64k.mp3
山东-105.7滨州文艺音乐广播,https://lhttp-hw.qtfm.cn/live/21341/64k.mp3
山东-FM107济宁生活广播,https://lhttp-hw.qtfm.cn/live/4008/64k.mp3
山东-临沂音乐广播,https://lhttp-hw.qtfm.cn/live/4017/64k.mp3
山东-东营生活广播,https://lhttp-hw.qtfm.cn/live/20211580/64k.mp3
山东-FM88.8故事广播,https://lhttp-hw.qtfm.cn/live/20500098/64k.mp3
山东-泰安交通广播,https://lhttp-hw.qtfm.cn/live/20500142/64k.mp3
山东-FM93.1滨州交通音乐广播,https://lhttp-hw.qtfm.cn/live/20519/64k.mp3
山东-无棣人民广播电台,https://lhttp-hw.qtfm.cn/live/5022198/64k.mp3
山东-曹县融媒体中心综合广播FM93.3,https://lhttp-hw.qtfm.cn/live/5022340/64k.mp3
山东-滨州综合广播,https://lhttp-hw.qtfm.cn/live/5021395/64k.mp3
山东-经典流行音乐动感904,https://lhttp-hw.qtfm.cn/live/20211680/64k.mp3
山东-青州人民广播电台,https://lhttp-hw.qtfm.cn/live/5022633/64k.mp3
山东-临朐广播电视台FM102.3,https://lhttp-hw.qtfm.cn/live/20500033/64k.mp3
山东-东营综合广播,https://lhttp-hw.qtfm.cn/live/20144/64k.mp3
山东-菏泽音乐广播,https://lhttp-hw.qtfm.cn/live/21175/64k.mp3
山东-济南生活广播,https://lhttp-hw.qtfm.cn/live/20500122/64k.mp3
山东-庆云人民广播电台,https://lhttp-hw.qtfm.cn/live/5022403/64k.mp3
山东-FM928历城音乐广播,https://lhttp-hw.qtfm.cn/live/20500194/64k.mp3
山东-寿光市融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500211/64k.mp3
山东-岁月如歌940,https://lhttp-hw.qtfm.cn/live/20500117/64k.mp3
山东-广饶人民广播电台FM103.9,https://lhttp-hw.qtfm.cn/live/20500036/64k.mp3
山东-威海交通广播,https://lhttp-hw.qtfm.cn/live/20671/64k.mp3
山东-枣庄93.4,https://lhttp-hw.qtfm.cn/live/20500134/64k.mp3
山东-FM97.4济南都市广播,https://lhttp-hw.qtfm.cn/live/5022333/64k.mp3
山东-临淄人民广播电台,https://lhttp-hw.qtfm.cn/live/20212204/64k.mp3
山东-年代882,https://lhttp-hw.qtfm.cn/live/20500197/64k.mp3
山东-金乡之声,https://lhttp-hw.qtfm.cn/live/20500085/64k.mp3
山东-周村区广播电视台,https://lhttp-hw.qtfm.cn/live/20500132/64k.mp3
山东-仙境之声,https://lhttp-hw.qtfm.cn/live/20500112/64k.mp3
山东-淄川1055广播,https://lhttp-hw.qtfm.cn/live/20211598/64k.mp3
山东-利津广播电视台FM106.2,https://lhttp-hw.qtfm.cn/live/20500138/64k.mp3
山东-牡丹之声手机广播,https://lhttp-hw.qtfm.cn/live/15318316/64k.mp3
山东-阳信人民广播电台,https://lhttp-hw.qtfm.cn/live/5021991/64k.mp3
山东-成武人民广播电台,https://lhttp-hw.qtfm.cn/live/20211637/64k.mp3
山东-蒙阴人民广播电台,https://lhttp-hw.qtfm.cn/live/15318571/64k.mp3
山东-章丘之声,https://lhttp-hw.qtfm.cn/live/20212207/64k.mp3
山东-滨城综合广播,https://lhttp-hw.qtfm.cn/live/20500168/64k.mp3
河南-怀旧好声音,https://lhttp-hw.qtfm.cn/live/1223/64k.mp3
河南-郑州新闻广播,https://lhttp-hw.qtfm.cn/live/1220/64k.mp3
河南-河南交通广播,https://lhttp-hw.qtfm.cn/live/1209/64k.mp3
河南-河南新闻广播,https://lhttp-hw.qtfm.cn/live/1215/64k.mp3
河南-1042南阳新闻广播,https://lhttp-hw.qtfm.cn/live/1213/64k.mp3
河南-悦动936南阳城市广播,https://lhttp-hw.qtfm.cn/live/15318502/64k.mp3
河南-流行音乐先锋·90My Radio,https://lhttp-hw.qtfm.cn/live/1206/64k.mp3
河南-郑州经济广播,https://lhttp-hw.qtfm.cn/live/1221/64k.mp3
河南-洛阳音乐广播,https://lhttp-hw.qtfm.cn/live/1226/64k.mp3
河南-洛阳交通广播,https://lhttp-hw.qtfm.cn/live/1227/64k.mp3
河南-河南音乐广播,https://lhttp-hw.qtfm.cn/live/1208/64k.mp3
河南-私家车999,https://lhttp-hw.qtfm.cn/live/1219/64k.mp3
河南-郑州交通广播,https://lhttp-hw.qtfm.cn/live/1211/64k.mp3
河南-安阳交通广播,https://lhttp-hw.qtfm.cn/live/2138/64k.mp3
河南-周口综合广播,https://lhttp-hw.qtfm.cn/live/20212215/64k.mp3
河南-洛阳综合广播,https://lhttp-hw.qtfm.cn/live/1225/64k.mp3
河南-南阳交通广播,https://lhttp-hw.qtfm.cn/live/1212/64k.mp3
河南-开封交通旅游广播,https://lhttp-hw.qtfm.cn/live/1214/64k.mp3
河南-FM88.7民歌悠扬,https://lhttp-hw.qtfm.cn/live/15318585/64k.mp3
河南-河南娱乐976,https://lhttp-hw.qtfm.cn/live/21317/64k.mp3
河南-991新乡综合广播,https://lhttp-hw.qtfm.cn/live/1228/64k.mp3
河南-1077新乡交通广播,https://lhttp-hw.qtfm.cn/live/1229/64k.mp3
河南-郑州音乐广播,https://lhttp-hw.qtfm.cn/live/4921/64k.mp3
河南-经典958,https://lhttp-hw.qtfm.cn/live/20500053/64k.mp3
河南-河南农村广播,https://lhttp-hw.qtfm.cn/live/1218/64k.mp3
河南-焦作交通旅游广播,https://lhttp-hw.qtfm.cn/live/20805/64k.mp3
河南-许昌广播电视台交通广播FM92.6,https://lhttp-hw.qtfm.cn/live/5022095/64k.mp3
河南-安阳新闻应急广播,https://lhttp-hw.qtfm.cn/live/15318224/64k.mp3
河南-FM893周口交通广播,https://lhttp-hw.qtfm.cn/live/15318700/64k.mp3
河南-私家车音乐877,https://lhttp-hw.qtfm.cn/live/4569/64k.mp3
河南-驻马店综合广播,https://lhttp-hw.qtfm.cn/live/5022118/64k.mp3
河南-光山90.1,https://lhttp-hw.qtfm.cn/live/20500029/64k.mp3
河南-濮阳经典调频1038,https://lhttp-hw.qtfm.cn/live/5021461/64k.mp3
河南-FM98.2巩义新闻广播,https://lhttp-hw.qtfm.cn/live/5022551/64k.mp3
河南-安阳1008音乐广播,https://lhttp-hw.qtfm.cn/live/2123/64k.mp3
河南-商丘新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022443/64k.mp3
河南-河南经济广播,https://lhttp-hw.qtfm.cn/live/1216/64k.mp3
河南-济源新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022142/64k.mp3
河南-鹤壁综合广播,https://lhttp-hw.qtfm.cn/live/5022055/64k.mp3
河南-驻马店经济广播,https://lhttp-hw.qtfm.cn/live/5022119/64k.mp3
河南-濮阳新闻广播,https://lhttp-hw.qtfm.cn/live/20207739/64k.mp3
河南-项城936,https://lhttp-hw.qtfm.cn/live/15318335/64k.mp3
河南-河南教育广播,https://lhttp-hw.qtfm.cn/live/1207/64k.mp3
河南-声动890信阳综合广播,https://lhttp-hw.qtfm.cn/live/5021977/64k.mp3
河南-长垣综合广播FM95.7,https://lhttp-hw.qtfm.cn/live/15318663/64k.mp3
河南-平舆FM981,https://lhttp-hw.qtfm.cn/live/20209342/64k.mp3
河南-商丘交通1007,https://lhttp-hw.qtfm.cn/live/5021932/64k.mp3
河南-漯河综合广播,https://lhttp-hw.qtfm.cn/live/5022660/64k.mp3
河南-FM99.6信阳交通广播,https://lhttp-hw.qtfm.cn/live/15318156/64k.mp3
河南-三门峡综合广播,https://lhttp-hw.qtfm.cn/live/5022134/64k.mp3
河南-河南电台乐龄1056,https://lhttp-hw.qtfm.cn/live/20208/64k.mp3
河南-鹤壁交通广播FM99.4,https://lhttp-hw.qtfm.cn/live/5022089/64k.mp3
河南-汝州人民广播电台,https://lhttp-hw.qtfm.cn/live/5022650/64k.mp3
河南-焦作新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022557/64k.mp3
河南-快乐903私家车广播,https://lhttp-hw.qtfm.cn/live/5021919/64k.mp3
河南-经典916,https://lhttp-hw.qtfm.cn/live/20207782/64k.mp3
河南-FM91.8郑州私家车广播,https://lhttp-hw.qtfm.cn/live/1222/64k.mp3
河南-平顶山交通广播,https://lhttp-hw.qtfm.cn/live/5022421/64k.mp3
河南-平顶山新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022420/64k.mp3
河南-南乐融媒广播,https://lhttp-hw.qtfm.cn/live/20500136/64k.mp3
河南-南阳好朋友892汽车音乐电台,https://lhttp-hw.qtfm.cn/live/5022725/64k.mp3
河南-许昌广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022092/64k.mp3
河南-林州广播电台,https://lhttp-hw.qtfm.cn/live/20211604/64k.mp3
河南-濮阳交通广播,https://lhttp-hw.qtfm.cn/live/1233/64k.mp3
河南-开封综合广播,https://lhttp-hw.qtfm.cn/live/5022653/64k.mp3
河南-动听925,https://lhttp-hw.qtfm.cn/live/20500152/64k.mp3
河南-新野998电台,https://lhttp-hw.qtfm.cn/live/20212406/64k.mp3
河南-濮阳FM1053快乐调频,https://lhttp-hw.qtfm.cn/live/20206/64k.mp3
河南-FM104.4,https://lhttp-hw.qtfm.cn/live/20211597/64k.mp3
河南-洛阳城市993,https://lhttp-hw.qtfm.cn/live/20211321/64k.mp3
河南-尉氏1068,https://lhttp-hw.qtfm.cn/live/20211630/64k.mp3
河南-AI潮流音乐台,https://lhttp-hw.qtfm.cn/live/15318300/64k.mp3
河南-新密人民广播电台,https://lhttp-hw.qtfm.cn/live/20500144/64k.mp3
河南-103.7滑县广播电台,https://lhttp-hw.qtfm.cn/live/20500195/64k.mp3
河南-邓州广播电台,https://lhttp-hw.qtfm.cn/live/20500198/64k.mp3
河南-TOP Radio 安阳881,https://lhttp-hw.qtfm.cn/live/20209339/64k.mp3
河南-卧龙综合广播,https://lhttp-hw.qtfm.cn/live/20500113/64k.mp3
河南-FM105.9项城人民广播电台,https://lhttp-hw.qtfm.cn/live/20210757/64k.mp3
河南-开封祥符广播919,https://lhttp-hw.qtfm.cn/live/20500156/64k.mp3
河南-通许融媒1026,https://lhttp-hw.qtfm.cn/live/20500157/64k.mp3
河南-西华交通广播,https://lhttp-hw.qtfm.cn/live/20211629/64k.mp3
河南-漯河交通广播,https://lhttp-hw.qtfm.cn/live/5022452/64k.mp3
河南-登封综合广播,https://lhttp-hw.qtfm.cn/live/5022077/64k.mp3
河南-新县FM106.2,https://lhttp-hw.qtfm.cn/live/20500056/64k.mp3
河南-郏县886,https://lhttp-hw.qtfm.cn/live/5022022/64k.mp3
河南-FM98.9三门峡交通文艺广播,https://lhttp-hw.qtfm.cn/live/15318227/64k.mp3
河南-乐享1007,https://lhttp-hw.qtfm.cn/live/20500141/64k.mp3
河南-禹州广播电视台 FM93.4,https://lhttp-hw.qtfm.cn/live/20500210/64k.mp3
河南-兰考人民广播电台,https://lhttp-hw.qtfm.cn/live/20500167/64k.mp3
河南-社旗993交通音乐广播,https://lhttp-hw.qtfm.cn/live/20500068/64k.mp3
河南-风尚908,https://lhttp-hw.qtfm.cn/live/20211663/64k.mp3
河南-正阳综合广播,https://lhttp-hw.qtfm.cn/live/20212397/64k.mp3
河南-汤阴融媒综合广播,https://lhttp-hw.qtfm.cn/live/20500205/64k.mp3
湖北-湖北之声,https://lhttp-hw.qtfm.cn/live/1303/64k.mp3
湖北-楚天交通广播,https://lhttp-hw.qtfm.cn/live/1291/64k.mp3
湖北-武汉经济广播,https://lhttp-hw.qtfm.cn/live/20200/64k.mp3
湖北-襄阳交通音乐广播,https://lhttp-hw.qtfm.cn/live/1308/64k.mp3
湖北-湖北经典音乐广播,https://lhttp-hw.qtfm.cn/live/1296/64k.mp3
湖北-武汉新闻广播,https://lhttp-hw.qtfm.cn/live/20198/64k.mp3
湖北-楚天音乐广播,https://lhttp-hw.qtfm.cn/live/1289/64k.mp3
湖北-襄阳之声,https://lhttp-hw.qtfm.cn/live/1307/64k.mp3
湖北-武汉经典音乐广播,https://lhttp-hw.qtfm.cn/live/1297/64k.mp3
湖北-湖北城市之声,https://lhttp-hw.qtfm.cn/live/4671/64k.mp3
湖北-黄石交通广播,https://lhttp-hw.qtfm.cn/live/3964/64k.mp3
湖北-武汉交通广播,https://lhttp-hw.qtfm.cn/live/4665/64k.mp3
湖北-十堰交通音乐广播,https://lhttp-hw.qtfm.cn/live/20342/64k.mp3
湖北-湖北经济广播,https://lhttp-hw.qtfm.cn/live/1295/64k.mp3
湖北-荆州音乐广播自在106.8,https://lhttp-hw.qtfm.cn/live/20075/64k.mp3
湖北-宜昌交通广播,https://lhttp-hw.qtfm.cn/live/20563/64k.mp3
湖北-十堰综合广播,https://lhttp-hw.qtfm.cn/live/20338/64k.mp3
湖北-荆州广播电视台90.1汽车广播,https://lhttp-hw.qtfm.cn/live/1312/64k.mp3
湖北-荆门综合广播,https://lhttp-hw.qtfm.cn/live/20211577/64k.mp3
湖北-鄂州广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/21025/64k.mp3
湖北-宜昌音乐广播,https://lhttp-hw.qtfm.cn/live/20567/64k.mp3
湖北-襄阳文化教育广播,https://lhttp-hw.qtfm.cn/live/5057/64k.mp3
湖北-黄冈新闻综合广播,https://lhttp-hw.qtfm.cn/live/1301/64k.mp3
湖北-随州综合广播,https://lhttp-hw.qtfm.cn/live/20853/64k.mp3
湖北-湖北农村广播,https://lhttp-hw.qtfm.cn/live/1302/64k.mp3
湖北-咸宁综合广播,https://lhttp-hw.qtfm.cn/live/5067/64k.mp3
湖北-魅力FM1064城市生活音乐广播,https://lhttp-hw.qtfm.cn/live/5022716/64k.mp3
湖北-孝感交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022063/64k.mp3
湖北-随州交通经济广播,https://lhttp-hw.qtfm.cn/live/21027/64k.mp3
湖北-宜昌新闻综合广播,https://lhttp-hw.qtfm.cn/live/20565/64k.mp3
湖北-武穴人民广播电台,https://lhttp-hw.qtfm.cn/live/5022071/64k.mp3
湖北-蕲春人民广播电台,https://lhttp-hw.qtfm.cn/live/5022252/64k.mp3
湖北-十堰旅游生活广播,https://lhttp-hw.qtfm.cn/live/20212401/64k.mp3
湖北-仙桃人民广播电台,https://lhttp-hw.qtfm.cn/live/20211562/64k.mp3
湖北-监利人民广播电台,https://lhttp-hw.qtfm.cn/live/15318507/64k.mp3
湖北-荆门交通音乐广播,https://lhttp-hw.qtfm.cn/live/20336/64k.mp3
湖北-黄冈交通音乐广播,https://lhttp-hw.qtfm.cn/live/20207776/64k.mp3
湖北-黄梅之声,https://lhttp-hw.qtfm.cn/live/5022280/64k.mp3
湖北-恩施电台交通音乐频率,https://lhttp-hw.qtfm.cn/live/5022719/64k.mp3
湖北-孝感新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022064/64k.mp3
湖北-公安人民广播电台,https://lhttp-hw.qtfm.cn/live/5063/64k.mp3
湖北-宜昌魅力930,https://lhttp-hw.qtfm.cn/live/20500146/64k.mp3
湖北-恩施电台新闻综合频率,https://lhttp-hw.qtfm.cn/live/5022718/64k.mp3
湖北-天门人民广播电台,https://lhttp-hw.qtfm.cn/live/20500199/64k.mp3
湖北-都市965汽车音乐广播,https://lhttp-hw.qtfm.cn/live/20500108/64k.mp3
湖北-长江之声,https://lhttp-hw.qtfm.cn/live/5021868/64k.mp3
湖北-咸宁交通广播,https://lhttp-hw.qtfm.cn/live/5068/64k.mp3
湖北-汉川电台,https://lhttp-hw.qtfm.cn/live/20212411/64k.mp3
湖北-红安人民广播电台,https://lhttp-hw.qtfm.cn/live/5022646/64k.mp3
湖北-孝昌964电台,https://lhttp-hw.qtfm.cn/live/15318546/64k.mp3
湖北-团风综合广播,https://lhttp-hw.qtfm.cn/live/20500189/64k.mp3
湖北-云梦综合广播,https://lhttp-hw.qtfm.cn/live/20500204/64k.mp3
湖北-江陵综合广播,https://lhttp-hw.qtfm.cn/live/20500203/64k.mp3
湖北-鹤峰人民广播电台,https://lhttp-hw.qtfm.cn/live/20500126/64k.mp3
湖南-湖南交通频道,https://lhttp-hw.qtfm.cn/live/4879/64k.mp3
湖南-长沙FM101.7城市之声,https://lhttp-hw.qtfm.cn/live/4237/64k.mp3
湖南-FM88.6长沙音乐广播,https://lhttp-hw.qtfm.cn/live/20847/64k.mp3
湖南-湖南金鹰955电台,https://lhttp-hw.qtfm.cn/live/4937/64k.mp3
湖南-芒果时空音乐台,https://lhttp-hw.qtfm.cn/live/4981/64k.mp3
湖南-FM102.2亲子智慧电台,https://lhttp-hw.qtfm.cn/live/4930/64k.mp3
湖南-1061长沙交通广播,https://lhttp-hw.qtfm.cn/live/3967/64k.mp3
湖南-FM102.8湖南电台新闻综合频道,https://lhttp-hw.qtfm.cn/live/4978/64k.mp3
湖南-Easy Fm,https://lhttp-hw.qtfm.cn/live/5022391/64k.mp3
湖南-89.3芒果音乐台,https://lhttp-hw.qtfm.cn/live/4979/64k.mp3
湖南-FM106.8常德鼎广电台,https://lhttp-hw.qtfm.cn/live/5021860/64k.mp3
湖南-FM105.0长沙新闻广播,https://lhttp-hw.qtfm.cn/live/4877/64k.mp3
湖南-株洲交通广播,https://lhttp-hw.qtfm.cn/live/3971/64k.mp3
湖南-长沙925电台,https://lhttp-hw.qtfm.cn/live/5022076/64k.mp3
湖南-摩登音乐台,https://lhttp-hw.qtfm.cn/live/4980/64k.mp3
湖南-衡阳综合广播,https://lhttp-hw.qtfm.cn/live/15318386/64k.mp3
湖南-News938潇湘之声,https://lhttp-hw.qtfm.cn/live/4982/64k.mp3
湖南-郴州综合广播,https://lhttp-hw.qtfm.cn/live/20489/64k.mp3
湖南-衡阳交通经济广播,https://lhttp-hw.qtfm.cn/live/15318385/64k.mp3
湖南-湖南经广FM901  ,https://lhttp-hw.qtfm.cn/live/4983/64k.mp3
湖南-怀化电台综合广播,https://lhttp-hw.qtfm.cn/live/5022069/64k.mp3
湖南-FM97.1常德交通广播,https://lhttp-hw.qtfm.cn/live/15318209/64k.mp3
湖南-永州新闻综合广播电台,https://lhttp-hw.qtfm.cn/live/15318594/64k.mp3
湖南-岳阳交通广播,https://lhttp-hw.qtfm.cn/live/20987/64k.mp3
湖南-邵阳综合广播,https://lhttp-hw.qtfm.cn/live/20148/64k.mp3
湖南-FM105.6 常德综合广播,https://lhttp-hw.qtfm.cn/live/15318208/64k.mp3
湖南-FM88.1 益阳电台交通频道,https://lhttp-hw.qtfm.cn/live/15318153/64k.mp3
湖南-邵阳经济广播,https://lhttp-hw.qtfm.cn/live/20500058/64k.mp3
湖南-FM93.1常德音乐广播,https://lhttp-hw.qtfm.cn/live/20212391/64k.mp3
湖南-FM104.2湘潭交通广播,https://lhttp-hw.qtfm.cn/live/21269/64k.mp3
湖南-好朋友926音乐电台,https://lhttp-hw.qtfm.cn/live/5022413/64k.mp3
湖南-FM104.7澧县广播电台,https://lhttp-hw.qtfm.cn/live/15318178/64k.mp3
湖南-1028郴州交通旅游广播,https://lhttp-hw.qtfm.cn/live/20867/64k.mp3
湖南-娄底综合广播,https://lhttp-hw.qtfm.cn/live/21213/64k.mp3
湖南-怀化交通广播,https://lhttp-hw.qtfm.cn/live/5022070/64k.mp3
湖南-娄底交通广播,https://lhttp-hw.qtfm.cn/live/20507/64k.mp3
湖南-FM99.7 益阳电台综合频道,https://lhttp-hw.qtfm.cn/live/20314/64k.mp3
湖南-株洲音乐广播,https://lhttp-hw.qtfm.cn/live/5021481/64k.mp3
湖南-岳阳新闻综合广播,https://lhttp-hw.qtfm.cn/live/20989/64k.mp3
湖南-衡阳县融媒体中心综合广播FM105.6,https://lhttp-hw.qtfm.cn/live/21229/64k.mp3
湖南-浏阳99.5交通广播,https://lhttp-hw.qtfm.cn/live/5022710/64k.mp3
湖南-FM99.6宜章县广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/15318691/64k.mp3
湖南-FM88.2湘潭新闻综合广播,https://lhttp-hw.qtfm.cn/live/15318549/64k.mp3
湖南-桃江人民广播电台,https://lhttp-hw.qtfm.cn/live/20500086/64k.mp3
湖南-湘乡广播电台龙城之声,https://lhttp-hw.qtfm.cn/live/15318180/64k.mp3
湖南-FM99.2岳阳县综合广播,https://lhttp-hw.qtfm.cn/live/20500129/64k.mp3
湖南-靖州综合广播,https://lhttp-hw.qtfm.cn/live/20500011/64k.mp3
广东-广东广播电视台股市广播,https://lhttp-hw.qtfm.cn/live/4847/64k.mp3
广东-广东珠江经济电台,https://lhttp-hw.qtfm.cn/live/1259/64k.mp3
广东-广东广播电视台文体广播,https://lhttp-hw.qtfm.cn/live/471/64k.mp3
广东-深圳先锋898,https://lhttp-hw.qtfm.cn/live/1270/64k.mp3
广东-羊城交通台,https://lhttp-hw.qtfm.cn/live/1262/64k.mp3
广东-广东音乐之声,https://lhttp-hw.qtfm.cn/live/1260/64k.mp3
广东-鹤山电台,https://lhttp-hw.qtfm.cn/live/1286/64k.mp3
广东-广州新闻资讯广播,https://lhttp-hw.qtfm.cn/live/4848/64k.mp3
广东-广东新闻广播,https://lhttp-hw.qtfm.cn/live/1254/64k.mp3
广东-中山电台快乐888,https://lhttp-hw.qtfm.cn/live/1278/64k.mp3
广东-广东城市之声,https://lhttp-hw.qtfm.cn/live/469/64k.mp3
广东-广州交通广播,https://lhttp-hw.qtfm.cn/live/4955/64k.mp3
广东-佛山电台FM906,https://lhttp-hw.qtfm.cn/live/1264/64k.mp3
广东-广东南方生活广播,https://lhttp-hw.qtfm.cn/live/468/64k.mp3
广东-珠海斗门电台,https://lhttp-hw.qtfm.cn/live/15318432/64k.mp3
广东-江门旅游之声,https://lhttp-hw.qtfm.cn/live/1283/64k.mp3
广东-深圳交通频率,https://lhttp-hw.qtfm.cn/live/1272/64k.mp3
广东-广州MYFM 88.0,https://lhttp-hw.qtfm.cn/live/20194/64k.mp3
广东-广州汽车音乐电台,https://lhttp-hw.qtfm.cn/live/20192/64k.mp3
广东-深圳飞扬971,https://lhttp-hw.qtfm.cn/live/1271/64k.mp3
广东-新会人民广播电台,https://lhttp-hw.qtfm.cn/live/5061/64k.mp3
广东-潮州戏曲广播,https://lhttp-hw.qtfm.cn/live/4595/64k.mp3
广东-江门人民广播电台综合广播,https://lhttp-hw.qtfm.cn/live/1282/64k.mp3
广东-番禺电台畅快1017,https://lhttp-hw.qtfm.cn/live/20212427/64k.mp3
广东-云浮电台综合广播,https://lhttp-hw.qtfm.cn/live/5022442/64k.mp3
广东-中山电台新锐967,https://lhttp-hw.qtfm.cn/live/1277/64k.mp3
广东-花都广播电台,https://lhttp-hw.qtfm.cn/live/1263/64k.mp3
广东-FM88.7 清远综合广播,https://lhttp-hw.qtfm.cn/live/15318668/64k.mp3
广东-广东广播电视台珠江之声,https://lhttp-hw.qtfm.cn/live/470/64k.mp3
广东-东莞综合广播,https://lhttp-hw.qtfm.cn/live/1276/64k.mp3
广东-惠州音乐广播,https://lhttp-hw.qtfm.cn/live/5021523/64k.mp3
广东-新兴电台,https://lhttp-hw.qtfm.cn/live/20211602/64k.mp3
广东-FM904台山人民广播电台,https://lhttp-hw.qtfm.cn/live/5022062/64k.mp3
广东-开平广播电台,https://lhttp-hw.qtfm.cn/live/5037/64k.mp3
广东-云浮电台交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022441/64k.mp3
广东-FM97.8清远农村广播,https://lhttp-hw.qtfm.cn/live/15318679/64k.mp3
广东-东莞交通广播,https://lhttp-hw.qtfm.cn/live/1288/64k.mp3
广东-东莞音乐广播,https://lhttp-hw.qtfm.cn/live/21209/64k.mp3
广东-增城电台FM89.0,https://lhttp-hw.qtfm.cn/live/20211702/64k.mp3
广东-阳江旅游环保广播,https://lhttp-hw.qtfm.cn/live/15318428/64k.mp3
广东-澄海人民广播电台,https://lhttp-hw.qtfm.cn/live/5022439/64k.mp3
广东-普宁人民广播电台,https://lhttp-hw.qtfm.cn/live/5022527/64k.mp3
广东-深圳生活广播,https://lhttp-hw.qtfm.cn/live/1273/64k.mp3
广东-潮州综合频率,https://lhttp-hw.qtfm.cn/live/4596/64k.mp3
广东-FM93.5 茂名交通广播,https://lhttp-hw.qtfm.cn/live/20211574/64k.mp3
广东-茂名综合广播,https://lhttp-hw.qtfm.cn/live/20500088/64k.mp3
广东-梅州广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/1257/64k.mp3
广东-恩平FM97.7,https://lhttp-hw.qtfm.cn/live/20701/64k.mp3
广东-潮州交通音乐广播,https://lhttp-hw.qtfm.cn/live/4594/64k.mp3
广东-阳江综合资讯广播,https://lhttp-hw.qtfm.cn/live/15318429/64k.mp3
广东-FM95.9清远交通音乐广播,https://lhttp-hw.qtfm.cn/live/20500067/64k.mp3
广东-英德电台,https://lhttp-hw.qtfm.cn/live/5022392/64k.mp3
广东-珠海电台交通875,https://lhttp-hw.qtfm.cn/live/1275/64k.mp3
广东-湛江经济广播,https://lhttp-hw.qtfm.cn/live/5069/64k.mp3
广东-惠州综合广播FM100,https://lhttp-hw.qtfm.cn/live/5016/64k.mp3
广东-珠海电台先锋951,https://lhttp-hw.qtfm.cn/live/1274/64k.mp3
广东-客都之声 FM103.9,https://lhttp-hw.qtfm.cn/live/5021942/64k.mp3
广东-从化广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/15318698/64k.mp3
广东-龙岗广播FM99.1,https://lhttp-hw.qtfm.cn/live/20160/64k.mp3
广东-梅州电台交通广播,https://lhttp-hw.qtfm.cn/live/1258/64k.mp3
广东-988惠州经济环保广播,https://lhttp-hw.qtfm.cn/live/5017/64k.mp3
广东-韶关综合广播,https://lhttp-hw.qtfm.cn/live/5022074/64k.mp3
广东-湛江广播电视台交通音乐广播,https://lhttp-hw.qtfm.cn/live/20472/64k.mp3
广东-湛江广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20617/64k.mp3
广东-珠海电台活力915,https://lhttp-hw.qtfm.cn/live/5021725/64k.mp3
广东-廉江人民广播电台,https://lhttp-hw.qtfm.cn/live/20211578/64k.mp3
广东-化州人民广播电台,https://lhttp-hw.qtfm.cn/live/15318689/64k.mp3
广东-佛冈电台,https://lhttp-hw.qtfm.cn/live/15318379/64k.mp3
广东-肇庆高新区广播,https://lhttp-hw.qtfm.cn/live/20500213/64k.mp3
广东-遂溪人民广播电台,https://lhttp-hw.qtfm.cn/live/1284/64k.mp3
广东-兴宁市融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500218/64k.mp3
广东-吴川人民广播电台,https://lhttp-hw.qtfm.cn/live/20211643/64k.mp3
广东-东源广播电台,https://lhttp-hw.qtfm.cn/live/20500124/64k.mp3
广西-FM950广西音乐台,https://lhttp-hw.qtfm.cn/live/4875/64k.mp3
广西-广西私家车930,https://lhttp-hw.qtfm.cn/live/1756/64k.mp3
广西-广西电台新闻910,https://lhttp-hw.qtfm.cn/live/1753/64k.mp3
广西-广西970女主播电台,https://lhttp-hw.qtfm.cn/live/1754/64k.mp3
广西-南宁经典1049,https://lhttp-hw.qtfm.cn/live/20769/64k.mp3
广西-广西交通台,https://lhttp-hw.qtfm.cn/live/1758/64k.mp3
广西-玉林交通音乐广播,https://lhttp-hw.qtfm.cn/live/1763/64k.mp3
广西-978玉林城市电台,https://lhttp-hw.qtfm.cn/live/1762/64k.mp3
广西-南宁990新闻台,https://lhttp-hw.qtfm.cn/live/20358/64k.mp3
广西-桂林飞扬调频,https://lhttp-hw.qtfm.cn/live/1760/64k.mp3
广西-南宁1074交通台,https://lhttp-hw.qtfm.cn/live/20767/64k.mp3
广西-梧州广播电视台交通音乐之声,https://lhttp-hw.qtfm.cn/live/4599/64k.mp3
广西-北海新闻综合广播,https://lhttp-hw.qtfm.cn/live/20861/64k.mp3
广西-柳州综合广播,https://lhttp-hw.qtfm.cn/live/21043/64k.mp3
广西-广西北部湾之声,https://lhttp-hw.qtfm.cn/live/1757/64k.mp3
广西-贵港金曲1019,https://lhttp-hw.qtfm.cn/live/20697/64k.mp3
广西-桂林新闻综合广播,https://lhttp-hw.qtfm.cn/live/1759/64k.mp3
广西-飞扬1059（柳州汽车音乐广播）,https://lhttp-hw.qtfm.cn/live/20555/64k.mp3
广西-FM99.10柳州交通广播,https://lhttp-hw.qtfm.cn/live/20571/64k.mp3
广西-北海交通音乐广播,https://lhttp-hw.qtfm.cn/live/20211621/64k.mp3
广西-钦州新闻综合广播,https://lhttp-hw.qtfm.cn/live/5042/64k.mp3
广西-桂林电台最爱912,https://lhttp-hw.qtfm.cn/live/15318228/64k.mp3
广西-畅听882（贺州广播电视台综合广播）,https://lhttp-hw.qtfm.cn/live/5043/64k.mp3
广西-贺州交通音乐广播,https://lhttp-hw.qtfm.cn/live/5044/64k.mp3
广西-贵港风尚调频,https://lhttp-hw.qtfm.cn/live/5021920/64k.mp3
海南-交通954,https://lhttp-hw.qtfm.cn/live/5022079/64k.mp3
海南-海南新闻广播,https://lhttp-hw.qtfm.cn/live/1861/64k.mp3
海南-海南民生广播,https://lhttp-hw.qtfm.cn/live/21243/64k.mp3
海南-三亚天涯之声,https://lhttp-hw.qtfm.cn/live/20450/64k.mp3
海南-海南交通广播,https://lhttp-hw.qtfm.cn/live/4911/64k.mp3
海南-三亚之声,https://lhttp-hw.qtfm.cn/live/15318203/64k.mp3
海南-海南音乐广播,https://lhttp-hw.qtfm.cn/live/4878/64k.mp3
海南-FM101.8海口综合广播,https://lhttp-hw.qtfm.cn/live/5022015/64k.mp3
海南-海口音乐广播,https://lhttp-hw.qtfm.cn/live/20010/64k.mp3
海南-海南旅游广播•国际旅游岛之声,https://lhttp-hw.qtfm.cn/live/1862/64k.mp3
海南-琼海人民广播电台,https://lhttp-hw.qtfm.cn/live/5022287/64k.mp3
重庆-938重庆私家车广播,https://lhttp-hw.qtfm.cn/live/1502/64k.mp3
重庆-重庆交通广播,https://lhttp-hw.qtfm.cn/live/1500/64k.mp3
重庆-重庆之声,https://lhttp-hw.qtfm.cn/live/1498/64k.mp3
重庆-重庆音乐广播,https://lhttp-hw.qtfm.cn/live/647/64k.mp3
重庆-重庆巴渝之声,https://lhttp-hw.qtfm.cn/live/5022385/64k.mp3
重庆-生活1015,https://lhttp-hw.qtfm.cn/live/1499/64k.mp3
重庆-重庆嘉陵之声FM88.7,https://lhttp-hw.qtfm.cn/live/20211692/64k.mp3
重庆-100.7重庆永川之声,https://lhttp-hw.qtfm.cn/live/20210236/64k.mp3
重庆-大足人民广播电台,https://lhttp-hw.qtfm.cn/live/20211676/64k.mp3
重庆-綦江综合广播,https://lhttp-hw.qtfm.cn/live/20500201/64k.mp3
重庆-梁平之声,https://lhttp-hw.qtfm.cn/live/20211646/64k.mp3
重庆-重庆南川97.0,https://lhttp-hw.qtfm.cn/live/15318405/64k.mp3
重庆-万盛融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/15318480/64k.mp3
四川-四川新闻广播FM106.1,https://lhttp-hw.qtfm.cn/live/4906/64k.mp3
四川-四川交通广播FM101.7,https://lhttp-hw.qtfm.cn/live/4886/64k.mp3
四川-成都年代音乐怀旧好声音,https://lhttp-hw.qtfm.cn/live/20211686/64k.mp3
四川-年代音乐1022,https://lhttp-hw.qtfm.cn/live/20500066/64k.mp3
四川-成都交通文艺广播FM91.4,https://lhttp-hw.qtfm.cn/live/4891/64k.mp3
四川-成都经济广播,https://lhttp-hw.qtfm.cn/live/1121/64k.mp3
四川-四川财富生活广播FM94.0,https://lhttp-hw.qtfm.cn/live/4927/64k.mp3
四川-四川城市之音,https://lhttp-hw.qtfm.cn/live/1111/64k.mp3
四川-德阳综合广播,https://lhttp-hw.qtfm.cn/live/4987/64k.mp3
四川-欧美音乐88.7,https://lhttp-hw.qtfm.cn/live/15318703/64k.mp3
四川-成都新闻广播,https://lhttp-hw.qtfm.cn/live/4897/64k.mp3
四川-亚洲音乐成都FM96.5,https://lhttp-hw.qtfm.cn/live/4581/64k.mp3
四川-四川之声981,https://lhttp-hw.qtfm.cn/live/20207767/64k.mp3
四川-四川岷江音乐广播,https://lhttp-hw.qtfm.cn/live/1110/64k.mp3
四川-绵阳交通广播,https://lhttp-hw.qtfm.cn/live/4026/64k.mp3
四川-德阳经济生活广播,https://lhttp-hw.qtfm.cn/live/5022110/64k.mp3
四川-眉山交通音乐广播,https://lhttp-hw.qtfm.cn/live/20207781/64k.mp3
四川-凉山综合广播,https://lhttp-hw.qtfm.cn/live/5022143/64k.mp3
四川-内江交通广播,https://lhttp-hw.qtfm.cn/live/5021907/64k.mp3
四川-成都电台FM946,https://lhttp-hw.qtfm.cn/live/4892/64k.mp3
四川-达州综合广播,https://lhttp-hw.qtfm.cn/live/5022394/64k.mp3
四川-泸州新闻广播,https://lhttp-hw.qtfm.cn/live/5021557/64k.mp3
四川-年代音乐FM88.9,https://lhttp-hw.qtfm.cn/live/20500160/64k.mp3
四川-四川天府之声FM92.5,https://lhttp-hw.qtfm.cn/live/4939/64k.mp3
四川-攀枝花综合广播,https://lhttp-hw.qtfm.cn/live/4904/64k.mp3
四川-自贡综合广播,https://lhttp-hw.qtfm.cn/live/20207784/64k.mp3
四川-泸州交通广播,https://lhttp-hw.qtfm.cn/live/5021559/64k.mp3
四川-广元交通旅游广播,https://lhttp-hw.qtfm.cn/live/5022581/64k.mp3
四川-自贡交通广播,https://lhttp-hw.qtfm.cn/live/20211650/64k.mp3
四川-攀枝花交通音乐广播,https://lhttp-hw.qtfm.cn/live/4905/64k.mp3
四川-绵阳新闻广播,https://lhttp-hw.qtfm.cn/live/4024/64k.mp3
四川-乐山综合广播FM102.8,https://lhttp-hw.qtfm.cn/live/1122/64k.mp3
四川-南充综合广播FM100.4,https://lhttp-hw.qtfm.cn/live/21357/64k.mp3
四川-FM882 成都故事广播,https://lhttp-hw.qtfm.cn/live/5022004/64k.mp3
四川-双流FM1009空港之声,https://lhttp-hw.qtfm.cn/live/20211587/64k.mp3
四川-南充交通音乐广播FM91.5,https://lhttp-hw.qtfm.cn/live/21231/64k.mp3
四川-乐山音乐交通广播FM100.5,https://lhttp-hw.qtfm.cn/live/4864/64k.mp3
四川-阆中人民广播电台,https://lhttp-hw.qtfm.cn/live/20500020/64k.mp3
四川-四川文艺广播,https://lhttp-hw.qtfm.cn/live/4887/64k.mp3
四川-巴中新闻综合广播,https://lhttp-hw.qtfm.cn/live/20210239/64k.mp3
四川-泸州音乐广播,https://lhttp-hw.qtfm.cn/live/5021565/64k.mp3
四川-眉山综合广播,https://lhttp-hw.qtfm.cn/live/4027/64k.mp3
四川-德阳旌阳电台,https://lhttp-hw.qtfm.cn/live/5021933/64k.mp3
四川-成都龙泉人民广播电台FM99.3,https://lhttp-hw.qtfm.cn/live/20207769/64k.mp3
四川-达州交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022395/64k.mp3
四川-江油电台阳光调频,https://lhttp-hw.qtfm.cn/live/20673/64k.mp3
四川-广元综合广播,https://lhttp-hw.qtfm.cn/live/5022580/64k.mp3
四川-四川南部新闻综合广播,https://lhttp-hw.qtfm.cn/live/20525/64k.mp3
四川-绵竹人民广播电台,https://lhttp-hw.qtfm.cn/live/15318098/64k.mp3
四川-富顺人民广播电台,https://lhttp-hw.qtfm.cn/live/5022355/64k.mp3
四川-自贡文化旅游广播,https://lhttp-hw.qtfm.cn/live/20529/64k.mp3
四川-年代音乐994,https://lhttp-hw.qtfm.cn/live/20500148/64k.mp3
四川-935爱旅游,https://lhttp-hw.qtfm.cn/live/20207773/64k.mp3
四川-绵阳音乐广播,https://lhttp-hw.qtfm.cn/live/4025/64k.mp3
四川-遂宁新闻综合台,https://lhttp-hw.qtfm.cn/live/20182/64k.mp3
四川-四川民族频率,https://lhttp-hw.qtfm.cn/live/1115/64k.mp3
四川-西昌人民广播电台,https://lhttp-hw.qtfm.cn/live/20211706/64k.mp3
四川-三台人民广播电台,https://lhttp-hw.qtfm.cn/live/15318544/64k.mp3
四川-巴中交通旅游广播,https://lhttp-hw.qtfm.cn/live/20209340/64k.mp3
四川-成都FM96.5,https://lhttp-hw.qtfm.cn/live/20500159/64k.mp3
四川-FM98.7仪陇综合广播,https://lhttp-hw.qtfm.cn/live/20865/64k.mp3
四川-南部交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022604/64k.mp3
四川-汽车音乐广播FM942,https://lhttp-hw.qtfm.cn/live/20500137/64k.mp3
四川-仁寿人民广播电台,https://lhttp-hw.qtfm.cn/live/5021453/64k.mp3
四川-安岳人民广播电台"柠都之声"FM98.0,https://lhttp-hw.qtfm.cn/live/5022417/64k.mp3
四川-威远综合广播,https://lhttp-hw.qtfm.cn/live/20500102/64k.mp3
四川-FM97.4广汉市广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20212405/64k.mp3
四川-南江人民广播电台,https://lhttp-hw.qtfm.cn/live/20207778/64k.mp3
四川-遂宁交通旅游台,https://lhttp-hw.qtfm.cn/live/20180/64k.mp3
贵州-贵州交通广播,https://lhttp-hw.qtfm.cn/live/20057/64k.mp3
贵州-贵州广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20063/64k.mp3
贵州-贵州FM91.6音乐广播,https://lhttp-hw.qtfm.cn/live/20067/64k.mp3
贵州-遵义交通文艺广播 FM94.1,https://lhttp-hw.qtfm.cn/live/20741/64k.mp3
贵州-FM102.7贵阳交通广播,https://lhttp-hw.qtfm.cn/live/1774/64k.mp3
贵州-贵阳新闻综合广播,https://lhttp-hw.qtfm.cn/live/1773/64k.mp3
贵州-安顺交通广播Fm102.9,https://lhttp-hw.qtfm.cn/live/5022202/64k.mp3
贵州-黔西南FM88.3交通旅游广播,https://lhttp-hw.qtfm.cn/live/5046/64k.mp3
贵州-凯里人民广播电台,https://lhttp-hw.qtfm.cn/live/5022045/64k.mp3
贵州-贵州旅游广播,https://lhttp-hw.qtfm.cn/live/20059/64k.mp3
贵州-七星关综合广播,https://lhttp-hw.qtfm.cn/live/5021866/64k.mp3
贵州-黔东南交通广播 Fm89.8,https://lhttp-hw.qtfm.cn/live/5022285/64k.mp3
贵州-毕节交通音乐广播,https://lhttp-hw.qtfm.cn/live/5022712/64k.mp3
贵州-遵义综合广播FM89.8,https://lhttp-hw.qtfm.cn/live/5022080/64k.mp3
贵州-贵阳广播电视台旅游生活广播,https://lhttp-hw.qtfm.cn/live/4874/64k.mp3
贵州-贵州经济广播,https://lhttp-hw.qtfm.cn/live/20065/64k.mp3
贵州-黔西南FM107.9综合广播,https://lhttp-hw.qtfm.cn/live/5045/64k.mp3
贵州-六盘水广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20211616/64k.mp3
贵州-黔东南新闻综合广播,https://lhttp-hw.qtfm.cn/live/5047/64k.mp3
贵州-六盘水交通广播,https://lhttp-hw.qtfm.cn/live/5021865/64k.mp3
贵州-FM98.0黔南广播,https://lhttp-hw.qtfm.cn/live/5022717/64k.mp3
贵州-织金人民广播电台综合广播,https://lhttp-hw.qtfm.cn/live/20500037/64k.mp3
贵州-安顺新闻综合广播FM105.9,https://lhttp-hw.qtfm.cn/live/5022203/64k.mp3
贵州-习水新闻综合广播FM908,https://lhttp-hw.qtfm.cn/live/15318201/64k.mp3
贵州-威宁阳光945,https://lhttp-hw.qtfm.cn/live/5022342/64k.mp3
贵州-兴义之声,https://lhttp-hw.qtfm.cn/live/20500110/64k.mp3
贵州-桐梓人民广播电台—娄山之声,https://lhttp-hw.qtfm.cn/live/20212410/64k.mp3
贵州-遵义旅游生活广播,https://lhttp-hw.qtfm.cn/live/5022083/64k.mp3
贵州-铜仁交通旅游广播,https://lhttp-hw.qtfm.cn/live/20211615/64k.mp3
贵州-兴仁人民广播电台,https://lhttp-hw.qtfm.cn/live/20500077/64k.mp3
云南-FM954汽车音乐广播,https://lhttp-hw.qtfm.cn/live/1936/64k.mp3
云南-云南交通之声,https://lhttp-hw.qtfm.cn/live/1928/64k.mp3
云南-云南新闻广播,https://lhttp-hw.qtfm.cn/live/1926/64k.mp3
云南-FM105城市资讯,https://lhttp-hw.qtfm.cn/live/1937/64k.mp3
云南-FM1008新闻综合广播,https://lhttp-hw.qtfm.cn/live/1934/64k.mp3
云南-云南私家车电台,https://lhttp-hw.qtfm.cn/live/1927/64k.mp3
云南-FM99香格里拉之声,https://lhttp-hw.qtfm.cn/live/20139/64k.mp3
云南-德宏民语综合广播,https://lhttp-hw.qtfm.cn/live/5021850/64k.mp3
云南-昆明NEW FM102.8,https://lhttp-hw.qtfm.cn/live/1935/64k.mp3
云南-昭通新闻综合广播,https://lhttp-hw.qtfm.cn/live/21249/64k.mp3
云南-红河交通广播 ,https://lhttp-hw.qtfm.cn/live/4994/64k.mp3
云南-云南音乐广播,https://lhttp-hw.qtfm.cn/live/1929/64k.mp3
云南-玉溪新闻综合广播FM102.4,https://lhttp-hw.qtfm.cn/live/5022031/64k.mp3
云南-大理综合广播,https://lhttp-hw.qtfm.cn/live/20207747/64k.mp3
云南-红河综合广播,https://lhttp-hw.qtfm.cn/live/4033/64k.mp3
云南-楚雄音乐广播,https://lhttp-hw.qtfm.cn/live/4035/64k.mp3
云南-曲靖交通广播FM91.0,https://lhttp-hw.qtfm.cn/live/5022188/64k.mp3
云南-楚雄综合广播,https://lhttp-hw.qtfm.cn/live/4030/64k.mp3
云南-大理电台苍洱调频,https://lhttp-hw.qtfm.cn/live/1940/64k.mp3
云南-保山广播电视台FM98.7综合广播,https://lhttp-hw.qtfm.cn/live/5022446/64k.mp3
云南-曲靖综合广播,https://lhttp-hw.qtfm.cn/live/5022189/64k.mp3
云南-大理旅游文化广播,https://lhttp-hw.qtfm.cn/live/20207748/64k.mp3
云南-普洱市广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/1938/64k.mp3
云南-昭通交通旅游广播,https://lhttp-hw.qtfm.cn/live/21247/64k.mp3
云南-镇雄新闻综合广播,https://lhttp-hw.qtfm.cn/live/20210752/64k.mp3
云南-西双版纳民族语广播FM90.6,https://lhttp-hw.qtfm.cn/live/4036/64k.mp3
云南-玉溪交通旅游广播FM87.7,https://lhttp-hw.qtfm.cn/live/20211563/64k.mp3
云南-西双版纳综合广播FM101.4,https://lhttp-hw.qtfm.cn/live/5021709/64k.mp3
云南-文山交通广播,https://lhttp-hw.qtfm.cn/live/5021637/64k.mp3
云南-弥勒广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022531/64k.mp3
云南-云南民族广播,https://lhttp-hw.qtfm.cn/live/1933/64k.mp3
云南-德宏广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5021849/64k.mp3
云南-普洱市广播电视台交通广播,https://lhttp-hw.qtfm.cn/live/20212429/64k.mp3
云南-巧家人民广播电台——白鹤之声,https://lhttp-hw.qtfm.cn/live/20211704/64k.mp3
云南-蒙自广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5021599/64k.mp3
云南-新知100知道分子频道,https://lhttp-hw.qtfm.cn/live/1930/64k.mp3
云南-德宏交通旅游广播,https://lhttp-hw.qtfm.cn/live/5022548/64k.mp3
云南-开远广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/5022383/64k.mp3
云南-文山城市广播,https://lhttp-hw.qtfm.cn/live/20500217/64k.mp3
云南-怒江广播电视台广播综合频率,https://lhttp-hw.qtfm.cn/live/15318176/64k.mp3
云南-芒市广播电台FM105.1,https://lhttp-hw.qtfm.cn/live/15318587/64k.mp3
陕西-陕西都市广播,https://lhttp-hw.qtfm.cn/live/1609/64k.mp3
陕西-陕西交通广播,https://lhttp-hw.qtfm.cn/live/1601/64k.mp3
陕西-陕西秦腔广播,https://lhttp-hw.qtfm.cn/live/1604/64k.mp3
陕西-陕西经济广播·汽车调频,https://lhttp-hw.qtfm.cn/live/1603/64k.mp3
陕西-西安音乐广播,https://lhttp-hw.qtfm.cn/live/1612/64k.mp3
陕西-陕西农村广播,https://lhttp-hw.qtfm.cn/live/1602/64k.mp3
陕西-西安新闻广播,https://lhttp-hw.qtfm.cn/live/1610/64k.mp3
陕西-FM100.7咸阳人民广播电台,https://lhttp-hw.qtfm.cn/live/5022397/64k.mp3
陕西-陕西音乐广播,https://lhttp-hw.qtfm.cn/live/4873/64k.mp3
陕西-陕西新闻广播,https://lhttp-hw.qtfm.cn/live/1600/64k.mp3
陕西-陕西戏曲广播,https://lhttp-hw.qtfm.cn/live/1606/64k.mp3
陕西-陕西青少广播·好听1055,https://lhttp-hw.qtfm.cn/live/4885/64k.mp3
陕西-陕西故事广播·年代878,https://lhttp-hw.qtfm.cn/live/1608/64k.mp3
陕西-西安交通广播,https://lhttp-hw.qtfm.cn/live/1611/64k.mp3
陕西-渭南广播FM90.9,https://lhttp-hw.qtfm.cn/live/5022389/64k.mp3
陕西-宝鸡新闻广播,https://lhttp-hw.qtfm.cn/live/15318125/64k.mp3
陕西-安康综合广播,https://lhttp-hw.qtfm.cn/live/5021861/64k.mp3
陕西-宝鸡交通旅游,https://lhttp-hw.qtfm.cn/live/15318128/64k.mp3
陕西-宝鸡音乐广播,https://lhttp-hw.qtfm.cn/live/15318127/64k.mp3
陕西-宝鸡经济广播,https://lhttp-hw.qtfm.cn/live/15318126/64k.mp3
陕西-西安资讯广播·快乐1061,https://lhttp-hw.qtfm.cn/live/1613/64k.mp3
陕西-安康交通广播,https://lhttp-hw.qtfm.cn/live/5021862/64k.mp3
陕西-渭南广播FM102.6,https://lhttp-hw.qtfm.cn/live/5022388/64k.mp3
陕西-铜川音乐交通广播FM101.5,https://lhttp-hw.qtfm.cn/live/20207736/64k.mp3
陕西-彬州之声,https://lhttp-hw.qtfm.cn/live/20500035/64k.mp3
陕西-韩城交通音乐广播,https://lhttp-hw.qtfm.cn/live/15318413/64k.mp3
甘肃-甘肃交通广播,https://lhttp-hw.qtfm.cn/live/3939/64k.mp3
甘肃-甘肃新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022622/64k.mp3
甘肃-甘肃都市调频快乐1066,https://lhttp-hw.qtfm.cn/live/5021819/64k.mp3
甘肃-天水综合广播,https://lhttp-hw.qtfm.cn/live/20460/64k.mp3
甘肃-甘肃青春调频,https://lhttp-hw.qtfm.cn/live/4675/64k.mp3
甘肃-张掖新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022096/64k.mp3
甘肃-甘肃经济广播,https://lhttp-hw.qtfm.cn/live/4045/64k.mp3
甘肃-天水交通广播FM91.9,https://lhttp-hw.qtfm.cn/live/20211613/64k.mp3
甘肃-FM106.6综合广播,https://lhttp-hw.qtfm.cn/live/15318602/64k.mp3
甘肃-经典937天水音乐文艺广播,https://lhttp-hw.qtfm.cn/live/21251/64k.mp3
甘肃-定西交通广播,https://lhttp-hw.qtfm.cn/live/20212230/64k.mp3
宁夏-宁夏交通广播,https://lhttp-hw.qtfm.cn/live/1840/64k.mp3
宁夏-宁夏音乐广播,https://lhttp-hw.qtfm.cn/live/15318294/64k.mp3
宁夏-宁夏经济广播,https://lhttp-hw.qtfm.cn/live/1841/64k.mp3
宁夏-石嘴山综合广播,https://lhttp-hw.qtfm.cn/live/5022563/64k.mp3
宁夏-宁夏旅游广播,https://lhttp-hw.qtfm.cn/live/1842/64k.mp3
新疆-新疆电台维语交通文艺广播,https://lhttp-hw.qtfm.cn/live/20639/64k.mp3
新疆-新疆交通广播,https://lhttp-hw.qtfm.cn/live/1910/64k.mp3
新疆-新疆新闻广播FM96.1,https://lhttp-hw.qtfm.cn/live/1902/64k.mp3
新疆-伊犁广播电视台维吾尔语综合广播FM95.3,https://lhttp-hw.qtfm.cn/live/5022688/64k.mp3
新疆-乌鲁木齐维吾尔语广播,https://lhttp-hw.qtfm.cn/live/1923/64k.mp3
新疆-兵团882综合广播,https://lhttp-hw.qtfm.cn/live/5022410/64k.mp3
新疆-新疆929文化旅游广播,https://lhttp-hw.qtfm.cn/live/1909/64k.mp3
新疆-乌鲁木齐新闻广播,https://lhttp-hw.qtfm.cn/live/1918/64k.mp3
新疆-乌鲁木齐974交通广播,https://lhttp-hw.qtfm.cn/live/1919/64k.mp3
新疆-伊犁广播电视台哈萨克语综合广播FM88.4,https://lhttp-hw.qtfm.cn/live/5022692/64k.mp3
新疆-新疆哈萨克语广播,https://lhttp-hw.qtfm.cn/live/1908/64k.mp3
新疆-新疆故事广播,https://lhttp-hw.qtfm.cn/live/1911/64k.mp3
新疆-新疆MIXFM1039,https://lhttp-hw.qtfm.cn/live/4029/64k.mp3
新疆-新疆昌吉 FM103.3综合广播,https://lhttp-hw.qtfm.cn/live/20440/64k.mp3
新疆-察布查尔FM99.5,https://lhttp-hw.qtfm.cn/live/5022610/64k.mp3
新疆-巴音郭楞广播电视台1077交通文艺广播,https://lhttp-hw.qtfm.cn/live/5022104/64k.mp3
新疆-阿克苏维语综合广播FM101.6,https://lhttp-hw.qtfm.cn/live/15318551/64k.mp3
新疆-乌鲁木齐旅游音乐,https://lhttp-hw.qtfm.cn/live/1920/64k.mp3
新疆-第二师融媒体中心综合广播FM88.5,https://lhttp-hw.qtfm.cn/live/20211703/64k.mp3
新疆-新疆990音乐广播,https://lhttp-hw.qtfm.cn/live/21001/64k.mp3
新疆-新疆924民生广播,https://lhttp-hw.qtfm.cn/live/20480/64k.mp3
新疆-石河子广播电视台综合广播,https://lhttp-hw.qtfm.cn/live/20500118/64k.mp3
新疆-伊犁广播电视台汉语综合广播FM90.5,https://lhttp-hw.qtfm.cn/live/20211711/64k.mp3
新疆-奎屯市融媒体中心综合广播,https://lhttp-hw.qtfm.cn/live/20500121/64k.mp3
新疆-伊犁之声FM89.7,https://lhttp-hw.qtfm.cn/live/20500054/64k.mp3
新疆-新疆蒙古语广播,https://lhttp-hw.qtfm.cn/live/1903/64k.mp3
新疆-巴音郭楞广播电视台FM966综合广播,https://lhttp-hw.qtfm.cn/live/5022108/64k.mp3
新疆-阿克苏市1029,https://lhttp-hw.qtfm.cn/live/20500041/64k.mp3
新疆-库尔勒1053梨城之声,https://lhttp-hw.qtfm.cn/live/20212425/64k.mp3
新疆-托峰明珠交通音乐,https://lhttp-hw.qtfm.cn/live/20207780/64k.mp3
新疆-FM96.0 阿拉尔人民广播电台新闻综合广播,https://lhttp-hw.qtfm.cn/live/20500209/64k.mp3
新疆-伊犁广播电视台交通音乐广播FM105.9,https://lhttp-hw.qtfm.cn/live/5022689/64k.mp3
新疆-伊犁广播电视台经济广播FM89.1,https://lhttp-hw.qtfm.cn/live/5022691/64k.mp3
新疆-阿克苏汉语综合广播FM94,https://lhttp-hw.qtfm.cn/live/15318550/64k.mp3
新疆-轮台之声,https://lhttp-hw.qtfm.cn/live/20500099/64k.mp3
新疆-塔城市广播电视台FM104.2,https://lhttp-hw.qtfm.cn/live/20500145/64k.mp3
新疆-FM100.6 双河综合广播,https://lhttp-hw.qtfm.cn/live/20207772/64k.mp3
新疆-兵团七师综合广播,https://lhttp-hw.qtfm.cn/live/20500095/64k.mp3
新疆-FM94.3综合广播,https://lhttp-hw.qtfm.cn/live/20500064/64k.mp3
新疆-第三师图木舒克市人民广播电台,https://lhttp-hw.qtfm.cn/live/20500135/64k.mp3
新疆-塔城人民广播电台汉语综合广播,https://lhttp-hw.qtfm.cn/live/20500031/64k.mp3
新疆-呼图壁人民广播电台,https://lhttp-hw.qtfm.cn/live/20500188/64k.mp3
新疆-新疆兵团第十三师调频广播,https://lhttp-hw.qtfm.cn/live/5022506/64k.mp3
西藏-拉萨人民广播电台914,https://lhttp-hw.qtfm.cn/live/5022138/64k.mp3
青海-青海交通音乐,https://lhttp-hw.qtfm.cn/live/5009/64k.mp3
青海-西宁新闻综合广播,https://lhttp-hw.qtfm.cn/live/5022282/64k.mp3
青海-青海经济广播,https://lhttp-hw.qtfm.cn/live/5008/64k.mp3
青海-青海生活广播 花儿调频,https://lhttp-hw.qtfm.cn/live/5021413/64k.mp3
青海-FM104.3西宁交通文艺广播,https://lhttp-hw.qtfm.cn/live/5022283/64k.mp3
EOF

        # 3. 生成静态网页并建立 CGI 链接
        ln -sf "$SCRIPT_PATH" "$CGI_DIR/fm"
        $SCRIPT_PATH gen_html > "$WWW_DIR/index.html"

        # 4. 启动 Web 服务器
        "$CUSTOM_BUSYBOX" httpd -p 0.0.0.0:80 -h "$WWW_DIR"

        # 获取本机 IP
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
        pkill -f "$(basename "$SCRIPT_PATH") daemon" > /dev/null 2>&1
        rm -rf "$WWW_DIR" 2>/dev/null
        echo "服务已彻底关闭。"
        exit 0
        ;;
    "gen_html") true ;;   # 用于内部生成 HTML，直接执行后续代码
    "") true ;;           # 无参数时充当 CGI
    *)
        echo "用法: $0 {start|stop} [-auth 密钥]"
        exit 1
        ;;
esac

# ==================================================================
# 角色 2：生成纯 HTML 控制面板
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
        .btn { background: #f0f2f5; border: none; padding: 12px 8px; border-radius: 10px; font-size: 0.9rem; font-weight: 500; cursor: pointer; text-align: center; transition: all 0.2s; -webkit-tap-highlight-color: transparent; }
        .btn:active { background: #e2e5ec; transform: scale(0.95); }
        .btn.primary { background: var(--primary); color: white; }
        .btn.primary:active { background: #0d56c6; }
        .btn.danger { background: #ff3b30; color: white; }
        .btn.danger:active { background: #d32f2f; }
        .btn.random { background: #ff9800; color: white; }
        .btn.random:active { background: #e68900; }
        
        .vol-container { display: flex; align-items: center; gap: 12px; margin-top: 15px; position: relative; }
        input[type="range"] { flex: 1; height: 8px; border-radius: 4px; background: #ddd; -webkit-appearance: none; outline: none; }
        input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; width: 20px; height: 20px; border-radius: 50%; background: var(--primary); cursor: pointer; }
        .vol-display { font-size: 1.1rem; font-weight: bold; color: var(--primary); width: 45px; text-align: right; }
        
        input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 10px; font-size: 0.95rem; outline: none; background: #f9f9f9; transition: all 0.2s; box-sizing: border-box; }
        input[type="password"]:focus { border-color: var(--primary); box-shadow: 0 0 5px rgba(16,103,238,0.3); background: #fff; }
        
        .input-group { display: flex; gap: 10px; }
        .input-group .btn { padding: 12px 16px; white-space: nowrap; }

        .custom-select-wrapper { position: relative; flex: 1; display: flex; align-items: center; background: #f9f9f9; border: 1px solid #ddd; border-radius: 10px; transition: all 0.2s; }
        .custom-select-wrapper:focus-within { border-color: var(--primary); box-shadow: 0 0 5px rgba(16,103,238,0.3); background: #fff; }
        .custom-select-wrapper input { flex: 1; border: none; background: transparent; padding: 12px; outline: none; border-radius: 10px 0 0 10px; font-size: 0.95rem; width: 100%; min-width: 0; }
        .drop-icon { padding: 0 12px; color: #999; cursor: pointer; font-size: 0.8rem; display: flex; align-items: center; justify-content: center; height: 100%; }
        
        .dropdown-content { display: none; position: absolute; top: calc(100% + 5px); left: 0; right: 0; background: #fff; max-height: 220px; overflow-y: auto; box-shadow: 0 8px 24px rgba(0,0,0,0.15); border-radius: 8px; z-index: 100; border: 1px solid #eee; }
        .dropdown-content.show { display: block; }
        .dropdown-item { padding: 12px 16px; font-size: 0.9rem; color: #333; border-bottom: 1px solid #f5f5f5; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .dropdown-item:last-child { border-bottom: none; }
        .dropdown-item:active { background: #f0f6ff; color: var(--primary); }

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
        
        <!-- 随机播放 与 停止播放 合并为一行 -->
        <div class="section">
            <div class="section-title">控制</div>
            <div style="display: flex; gap: 12px;">
                <button class="btn random" style="flex: 1; padding: 14px;" onclick="randomPlay()">🎲 随机播放</button>
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
                <span style="font-size:0.85rem;color:#999;">MIN</span>
                <input type="range" min="5" max="100" step="5" value="50" id="volSlider" oninput="updateLabel(this.value)" onchange="sendCmd(this.value + '%')">
                <span class="vol-display" id="volVal">50%</span>
            </div>
            <div class="section-title">音量微调</div>
            <div style="display: flex; gap: 12px;">
                <button class="btn" style="flex:1;" onclick="sendCmd('-')">🔉 －</button>
                <button class="btn" style="flex:1;" onclick="sendCmd('+')">🔊 ＋</button>
            </div>
        </div>
    </div>
    
    <div class="toast" id="toast">指令已发送</div>

    <script>
        // 全局电台列表（从服务器 fmlist.txt 加载，格式 {name, url}）
        let stations = [];

        // 页面初始化
        document.addEventListener("DOMContentLoaded", async () => {
            // 恢复保存的认证密钥
            const savedAuth = localStorage.getItem('lx06_auth_key');
            if(savedAuth) document.getElementById('authKey').value = savedAuth;
            
            document.getElementById('authKey').addEventListener('input', (e) => {
                localStorage.setItem('lx06_auth_key', e.target.value.trim());
            });

            // 加载电台列表
            try {
                const resp = await fetch('/fmlist.txt');
                const text = await resp.text();
                stations = text.split('\n').filter(line => line.trim() !== '').map(line => {
                    const idx = line.indexOf(',');
                    if (idx > 0) {
                        return {
                            name: line.substring(0, idx).trim(),
                            url: line.substring(idx+1).trim()
                        };
                    }
                    return null;
                }).filter(item => item !== null);
            } catch (e) {
                console.error('加载电台列表失败', e);
                showToast('⚠️ 电台列表加载失败，请刷新重试');
            }

            // 点击页面任意位置关闭下拉框
            document.addEventListener('click', (e) => {
                if (!document.getElementById('selectWrapper').contains(e.target)) {
                    document.getElementById('customDropdown').classList.remove('show');
                }
            });
        });

        // 获取历史自定义 URL 列表
        function getHistoryUrls() {
            return JSON.parse(localStorage.getItem('lx06_custom_urls') || '[]');
        }

        // 保存一个新的 URL 到历史（去重，最多保留100个）
        function saveHistoryUrl(url) {
            let history = getHistoryUrls();
            if (!history.includes(url)) {
                history.unshift(url);
                if (history.length > 100) history.pop();
                localStorage.setItem('lx06_custom_urls', JSON.stringify(history));
            }
        }

        // 根据输入或选中项获取最终要播放的 URL
        function resolveUrl(text) {
            // 首先尝试在 stations 中按名称匹配
            const station = stations.find(s => s.name === text);
            if (station) return station.url;
            // 不是已知名称，则当作自定义 URL 处理
            if (text.startsWith('http://') || text.startsWith('https://')) {
                return text;
            }
            return null; // 无法识别
        }

        // 渲染下拉框（合并电台和自定义历史）
        function renderDropdown(filterText = '') {
            const history = getHistoryUrls();
            const items = [];
            // 加入 stations
            stations.forEach(s => {
                items.push({ display: s.name, url: s.url });
            });
            // 加入历史 URL（如果未在 stations 中出现过）
            history.forEach(url => {
                if (!stations.some(s => s.url === url)) {
                    items.push({ display: url, url: url });
                }
            });

            const filtered = items.filter(item =>
                item.display.toLowerCase().includes(filterText.toLowerCase())
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
                div.innerText = item.display;
                div.onclick = (e) => {
                    document.getElementById('mediaInput').value = item.display;
                    drop.classList.remove('show');
                    e.stopPropagation();
                };
                drop.appendChild(div);
            });
            drop.classList.add('show');
        }

        function openDropdown(e) {
            e.stopPropagation();
            renderDropdown(document.getElementById('mediaInput').value);
        }

        function filterDropdown() {
            renderDropdown(document.getElementById('mediaInput').value);
        }

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

        // 随机播放：从 stations 中随机选取一个
        function randomPlay() {
            if (stations.length === 0) {
                showToast('❌ 电台列表为空，请稍后重试');
                return;
            }
            const randomStation = stations[Math.floor(Math.random() * stations.length)];
            document.getElementById('mediaInput').value = randomStation.name;
            playByUrl(randomStation.url);
        }

        // 根据 URL 发送播放指令
        function playByUrl(url) {
            if (!url) return;
            sendCmd('playurl_' + url);
        }

        // 手动播放（从输入框或下拉选择）
        function playMedia() {
            const val = document.getElementById('mediaInput').value.trim();
            if (!val) {
                showToast("请选择频道或输入直链");
                return;
            }
            document.getElementById('customDropdown').classList.remove('show');
            const url = resolveUrl(val);
            if (url) {
                if (!stations.some(s => s.url === url)) {
                    saveHistoryUrl(url);
                }
                playByUrl(url);
            } else {
                showToast("❌ 无效的链接或频道名");
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

        function showToast(msg) {
            const t = document.getElementById('toast');
            t.innerText = msg;
            t.style.opacity = 1;
            setTimeout(() => t.style.opacity = 0, 1500);
        }
    </script>
</body>
</html>
EOF
    exit 0
fi

# ==================================================================
# 角色 3：CGI 指令处理（轻量化，只处理音量、停止、自定义播放）
# ==================================================================

# 1. 从 QUERY_STRING 中提取参数
cmd_raw=$(echo "$QUERY_STRING" | awk -F'cmd=' '{print $2}' | awk -F'&' '{print $1}')
auth_raw=$(echo "$QUERY_STRING" | awk -F'auth=' '{print $2}' | awk -F'&' '{print $1}')

# 2. 芝麻开门认证（如果设置了密钥文件）
if [ -s "$AUTH_FILE" ]; then
    real_auth=$(cat "$AUTH_FILE")
    decoded_auth=$(echo "$auth_raw" | sed 's/%2B/+/g' | sed 's/%2b/+/g' | sed 's/%25/%/g')
    if [ "$decoded_auth" != "$real_auth" ]; then
        printf "Content-Type: text/plain\r\n\r\nAuth Failed\r\n"
        exit 0
    fi
fi

# 3. 解码指令（支持 + 号等）
cmd=$(echo "$cmd_raw" | sed 's/%2B/+/g' | sed 's/%2b/+/g' | sed 's/%3A/:/gi' | sed 's/%2F/\//gi' | sed 's/%3F/?/gi' | sed 's/%3D/=/gi' | sed 's/%26/\&/gi' | sed 's/%25/%/g')

# 4. 播放器控制函数
play_url() {
    kill -9 $(pidof miplayer) > /dev/null 2>&1
    miplayer -f "$1" > /dev/null 2>&1 &
}

# 5. 指令分发
case "$cmd" in
    "+") amixer sset "mysoftvol" 2%+ > /dev/null 2>&1 & ;;
    "-") amixer sset "mysoftvol" 2%- > /dev/null 2>&1 & ;;
    *[1-9]% | *[1-9][0-9]% | *100% )
        clean_vol=$(echo "$cmd" | tr -cd '0-9')
        amixer sset "mysoftvol" "${clean_vol}%" > /dev/null 2>&1 & ;;
    "s")
        kill -9 $(pidof miplayer) > /dev/null 2>&1
        ;;
    playurl_*)
        custom_url="${cmd#playurl_}"
        play_url "$custom_url"
        ;;
    *)
        ;;
esac

# 6. 返回空响应
printf "Content-Type: text/plain\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
exit 0