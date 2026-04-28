---
title: 下载网页中不能下载的PDF和Word文档
categories:
  - Help Docs
tags:
  - Tools
comments: true
top: false
hidden: false
abbrlink: b7e9e19
date: 2023-08-14 17:49:45
updated:
---

&emsp;&emsp;日常中我许多时候会遇到网页中的PDF或者Word文档需要下载却找到不到下载按钮。查找了一些方法，自测在自己需要下载的环境内有用，在此分享一下。方法不能针对所有不能下载的pdf进行下载，我只把我遇到的情况写入了。欢迎评论交流！

<!-- more -->

<!-- toc -->

&emsp;&emsp;文件下载常用方法有进入F12界面的Network(网络)块，查看Fetch/XHR中的源文档地址。但我自己实践所需的环境大多找不到对应的文件。可能是网站的安全系数比较高，也可能是我自己的浏览器兼容问题。总之用不了的时候我使用以下方法通常都是有效的：

## PDF下载

**&emsp;&emsp;F12→控制台→复制粘贴代码回车，PDF上或者代码区域就会出现PDF链接。复制链接后打开或下载就可以了。**

    ```javascript
    (function(){
    let i=0
    while (i<100){
        for (let iframe of document.getElementsByTagName('iframe')){
            try {
                if (iframe){
                    let pdf_src=iframe.getAttribute("src")
                    let pdf_src_params = pdf_src.split("?")[1]
                    let obj = {};
                    let arr = pdf_src_params.split("&");
                    for (let i = 0; i < arr.length; i++) {
                        let arrNew = arr[i].split("=");
                        obj[arrNew[0]] = arrNew[1];
                    }
                    console.log(obj)
                    for (let key in obj) {
                        let src=obj[key].replace(/%2F/g,'/')
                        if (src.endsWith(".pdf")){
                            $('iframe').before(src);
                            return
                        }
                        else if (src.endsWith(".PDF")){
                            $('iframe').before(src);
                            return
                        }
                    }
                }
            } catch (error) {}    
        }
        i+=1
    }
    }())
    ```

## Word下载

&emsp;&emsp;Word文档反而更简单一点。如果网页是直接嵌入MS Office调用文档的那点到文档的位置按Ctrl+P组合键，MS Office会自动合并生成PDF文档供打印下载。