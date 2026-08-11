Java Agent mods 放这里

部分 mod 未添加许可证(License)或许可证严格，不能直接包含在此项目

1. [ChunkGuardAgent](https://github.com/kuohsuanlo/ChunkGuardAgent) (Java Agent):
    - "一個 Java agent：在 chunk 存檔的最後一刻攔截,如果發現要寫入的是「載入失敗的空白產物」、 而硬碟上還是好資料,就 SKIP 這次寫入 —— 好資料因此存活。專治高壓/OOM 下「4KB 空殼蓋掉好 chunk」的真毀損。判斷用內容來歷(chunk status)不是檔案大小,零誤殺。"
    - 查看介绍视频: [多年心血 ... 化為烏有 ...](https://www.youtube.com/watch?v=w19UHe3DCyA&t=7s)
    - 下载: https://github.com/kuohsuanlo/ChunkGuardAgent/tree/main/dist
    - 需要添加JVM参数: `-javaagent:ChunkGuardAgent.jar -Dchunkguard.shadow=true`
        - `-javaagent:ChunkGuardAgent.jar`: 加载这个 Java Agent
        - `-Dchunkguard.shadow=true`: "dry-run" 模式 (只記錄、不攔截,伺服器行為與沒裝時 100% 相同,建議先跑幾天)
            - 試跑判讀:log 出現 `SHADOW would-skip` = 它抓到一次毀損寫入(正式模式下會被擋);關機時 `inspectErrors=0`、平常存檔無異狀 → 可安心轉正式。
    - License=none(ARR?)
2. [LazyContainerAgent](https://github.com/kuohsuanlo/LazyContainerAgent):
    - "箱子物品「延遲反序列化(不急著把資料拆解成遊戲內物件,拖到真的要用才拆)+ 沒碰過就原樣寫回」的 Java agent。 針對 Paper 26.2,把 chunk(遊戲世界切成一塊一塊的地圖區域,伺服器以此為單位載入/卸載)載入時「立刻把每個箱子的物品從 NBT(Minecraft 儲存物品/方塊資料的二進位格式)解包」與卸載時「重新打包」這兩筆白工砍掉。" (区块加载时，不要立即解析箱子内的NBT/组件，需要使用时才解析，改善在多箱子场景下的性能)
    - 查看介绍视频: [我的老天 ... Minecraft「讀取一個方塊」呼叫了200層函數 ...](https://www.youtube.com/watch?v=eZEZo0sE1L4)
    - 下载: https://github.com/kuohsuanlo/LazyContainerAgent/releases
    - 需要添加JVM参数: `-javaagent:LazyContainerAgent.jar -Dlazycontainer.shadow=true -Dlazycontainer.verbose=true`
        - `-javaagent:LazyContainerAgent.jar`: 加载这个 Java Agent
        - `-Dlazycontainer.shadow=true`: "dry-run" 模式 (**先驗證,別急著上真效能** —— 開著 `shadow=true` 跑個幾天。它會把優化後的輸出跟原版做法**逐位元組對照**:只要 `shadowMismatch` 一直是 0,就代表輸出跟原版完全一致、**資料零風險**。代價是這階段兩套都做、暫時不會變快。)
            - **確認沒問題,再換真效能** —— 跑數天 `shadowMismatch=0`、也沒玩家回報少東西,就拿掉、重啟。這時「沒人碰過的箱子」會直接原樣寫回(跳過打包),效能才真正省下來。