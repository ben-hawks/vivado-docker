y2k22_url=$(curl 'https://support.xilinx.com/s/sfsites/aura?r=15&NEILON.edFileDetail.getFileDownloadInformation=1' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: https://support.xilinx.com/s/article/76960?language=en_US' -H 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8' -H 'Origin: https://support.xilinx.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-GPC: 1' -H 'TE: trailers' --data-raw 'message=%7B%22actions%22%3A%5B%7B%22id%22%3A%22519%3Ba%22%2C%22descriptor%22%3A%22apex%3A%2F%2FNEILON.edFileDetailController%2FACTION%24getFileDownloadInformation%22%2C%22callingDescriptor%22%3A%22markup%3A%2F%2FNEILON%3AedLightningFileDownload%22%2C%22params%22%3A%7B%22recordId%22%3A%22a1V2E00000GvwmpUAB%22%7D%7D%5D%7D&aura.context=%7B%22mode%22%3A%22PROD%22%2C%22fwuid%22%3A%22MFZGMnNxcWxxQVZkaERsVUY3RzNmZzBXM295ZTJ1MzlOT0pndTRaeTZnNEEyNDguMTAuMi01LjAuOA%22%2C%22app%22%3A%22siteforce%3AcommunityApp%22%2C%22loaded%22%3A%7B%22APPLICATION%40markup%3A%2F%2Fsiteforce%3AcommunityApp%22%3A%22MjIgGOAP9KfmIHP0sRc5nw%22%2C%22COMPONENT%40markup%3A%2F%2Fforce%3AoutputField%22%3A%22UJZzE-gmOUcoBB_9KubOsA%22%2C%22COMPONENT%40markup%3A%2F%2Finstrumentation%3Ao11ySecondaryLoader%22%3A%22VZ2Rg7MN_BaoV_0Qlk5pAw%22%7D%2C%22dn%22%3A%5B%5D%2C%22globals%22%3A%7B%7D%2C%22uad%22%3Afalse%7D&aura.pageURI=%2Fs%2Farticle%2F76960%3Flanguage%3Den_US&aura.token=null' | python3 -c "import sys, json; print(json.load(sys.stdin)['actions'][0]['returnValue']['fileDownloadURL'])")
curl $y2k22_url > /tmp/y2k22_fix.zip

