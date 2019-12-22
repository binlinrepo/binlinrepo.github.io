import os
from pypinyin import pinyin,lazy_pinyin,Style

fileNameRead=input("请输入文件地址：");
print("Info:fileNameRead:",fileNameRead);

if fileNameRead!="":
    try:
        fileRead=open(fileNameRead,'r');
        print("Info:文件打开成功！");
        fileNameWrite=fileNameRead+"-pinyin.txt";
        print("Info:fileNameWrite:",fileNameWrite);
        try:
            fileWrite=open(fileNameWrite,'w');
            for eachLine in fileRead:
                eachLineList=pinyin(eachLine.strip(),style=Style.NORMAL);
                #print(eachLineList);
                eachListStr="";
                for eachList in eachLineList:
                    for i in eachList:
                        eachListStr+="'";
                        eachListStr+=i;
                        
                
                #print(eachListStr[1:]);
                eachLineStr=eachLine.strip()+" "+eachListStr[1:]+"\n";
                fileWrite.write(eachLineStr);
                
            print("Info:文件写入成功！");
            fileWrite.close();
        except IOError:
            print("Error:文件写入失败！");

        fileRead.close();

    except IOError:
        print("Error:没有找到文件或打开文件失败！");

else:
    print("Error:输入文件地址有误！");

